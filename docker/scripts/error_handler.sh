#!/usr/bin/env bash
# Claude CLI 執行腳本錯誤處理模組

set -Eeuo pipefail

collect_logs_json() {
    if [[ -n "${LOG_FILE:-}" && -s "${LOG_FILE:-}" ]]; then
        jq -s '.' "$LOG_FILE"
    else
        echo "[]"
    fi
}

current_execution_time() {
    local end_time
    end_time="$(date +%s)"

    if [[ -z "${START_TIME:-}" ]]; then
        echo 0
    else
        echo $((end_time - START_TIME))
    fi
}

handle_error() {
    local error_type="${1:-UNEXPECTED_ERROR}"
    local error_message="${2:-未預期錯誤}"
    local exit_code="${3:-1}"
    local line_no="${4:-unknown}"

    local logs_json
    logs_json="$(collect_logs_json)"
    local execution_time_seconds
    execution_time_seconds="$(current_execution_time)"

    local stack_trace="line ${line_no}, exit code ${exit_code}"
    if [[ -n "${BASH_COMMAND:-}" ]]; then
        stack_trace+=" | command: ${BASH_COMMAND}"
    fi

    mkdir -p "${OUTPUT_DIR:-/output}"
    local result_path="${RESULT_FILE:-${OUTPUT_DIR:-/output}/result.json}"
    local correlation_id_value="${CORRELATION_ID:-unknown}"

    jq -n \
        --arg correlation_id "$correlation_id_value" \
        --arg status "error" \
        --arg error_type "$error_type" \
        --arg error_message "$error_message" \
        --arg stack_trace "$stack_trace" \
        --argjson logs "$logs_json" \
        --arg execution_time_seconds "$execution_time_seconds" \
        '{
            correlation_id: $correlation_id,
            status: $status,
            execution_time_seconds: ($execution_time_seconds | tonumber),
            error_type: $error_type,
            error_message: $error_message,
            stack_trace: $stack_trace,
            logs: $logs
        }' > "$result_path"

    exit "$exit_code"
}
