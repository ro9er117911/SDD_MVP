#!/usr/bin/env bash
# Claude CLI 執行腳本：整合 SpecKit 指令與 Git/GitHub 操作

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/error_handler.sh"

on_error() {
    local line_no="$1"
    local exit_code="$?"
    handle_error "UNEXPECTED_ERROR" "腳本在第 ${line_no:-unknown} 行失敗 (exit code: $exit_code)" "$exit_code" "$line_no"
}
trap 'on_error $LINENO' ERR

INPUT_DIR="${INPUT_DIR:-/input}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
BRD_FILE="$INPUT_DIR/brd_analysis.json"
RESULT_FILE="${RESULT_FILE:-$OUTPUT_DIR/result.json}"
LOG_FILE="${LOG_FILE:-$OUTPUT_DIR/run_speckit_logs.jsonl}"
CLAUDE_CLI_BIN="${CLAUDE_CLI_BIN:-claude-cli}"
GH_BIN="${GH_BIN:-gh}"
VALIDATE_MERMAID_SCRIPT="$SCRIPT_DIR/validate_mermaid.sh"

mkdir -p "$OUTPUT_DIR" "$WORKSPACE_DIR"
: > "$LOG_FILE"

START_TIME="$(date +%s)"
export START_TIME RESULT_FILE LOG_FILE OUTPUT_DIR

REQUIRED_ENV_VARS=(GITHUB_REPO GITHUB_TOKEN ANTHROPIC_API_KEY CLAUDE_MODEL)
export GIT_TERMINAL_PROMPT=0

log_event() {
    local level="$1"
    local message="$2"
    local context_json="${3:-}"
    if [[ -z "$context_json" ]]; then
        context_json="{}"
    fi
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    jq -n \
        --arg level "$level" \
        --arg message "$message" \
        --arg timestamp "$timestamp" \
        --argjson context "$context_json" \
        '{level:$level,message:$message,timestamp:$timestamp,context:$context}' >> "$LOG_FILE"
}

require_env_vars() {
    for var in "${REQUIRED_ENV_VARS[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log_event "ERROR" "缺少必要環境變數" "$(jq -n --arg var "$var" '{missing_var:$var}')"
            handle_error "VALIDATION_ERROR" "缺少必要環境變數：$var"
        fi
    done
}

file_size_bytes() {
    local file_path="$1"
    if stat -c%s "$file_path" >/dev/null 2>&1; then
        stat -c%s "$file_path"
    else
        stat -f%z "$file_path"
    fi
}

sha256_checksum() {
    local file_path="$1"
    sha256sum "$file_path" | awk '{print $1}'
}

relative_to_workspace() {
    local abs_path="$1"
    echo "${abs_path#$WORKSPACE_DIR/}"
}

ensure_git_identity() {
    if ! git config user.name >/dev/null 2>&1; then
        git config user.name "Spec Bot"
    fi
    if ! git config user.email >/dev/null 2>&1; then
        git config user.email "spec-bot@example.com"
    fi
}

normalize_command() {
    local command="$1"
    if [[ "$command" == "/speckit.specify"* && "$command" != *"--input"* ]]; then
        command="$command --input $BRD_FILE"
    fi
    echo "$command"
}

discover_feature_dir() {
    if [[ -d "$WORKSPACE_DIR/specs/001-spec-bot-sdd-integration" ]]; then
        echo "specs/001-spec-bot-sdd-integration"
        return
    fi
    if [[ ! -d "$WORKSPACE_DIR/specs" ]]; then
        echo ""
        return
    fi
    local first_spec=""
    while IFS= read -r spec_file; do
        first_spec="$spec_file"
        break
    done < <(find "$WORKSPACE_DIR/specs" -type f -name "spec.md" 2>/dev/null)
    if [[ -n "$first_spec" ]]; then
        local spec_dir
        spec_dir="$(dirname "$first_spec")"
        echo "${spec_dir#$WORKSPACE_DIR/}"
        return
    fi
    echo ""
}

build_output_entry() {
    local relative_path="$1"
    local absolute_path="$WORKSPACE_DIR/$relative_path"
    if [[ ! -f "$absolute_path" ]]; then
        handle_error "VALIDATION_ERROR" "找不到輸出檔案：$relative_path"
    fi
    local size_bytes
    size_bytes="$(file_size_bytes "$absolute_path")"
    local checksum
    checksum="$(sha256_checksum "$absolute_path")"

    jq -n \
        --arg path "$relative_path" \
        --arg size "$size_bytes" \
        --arg checksum "sha256:$checksum" \
        '{path:$path,size_bytes:($size|tonumber),checksum:$checksum}'
}

write_success_result() {
    local branch="$1"
    local commit_sha="$2"
    local commit_message="$3"
    local pr_url="$4"
    local spec_path="$5"
    local plan_path="$6"
    local tasks_path="$7"

    local spec_entry
    spec_entry="$(build_output_entry "$spec_path")"
    local plan_entry
    plan_entry="$(build_output_entry "$plan_path")"
    local tasks_entry
    tasks_entry="$(build_output_entry "$tasks_path")"

    local outputs_json
    outputs_json="$(jq -n \
        --argjson spec "$spec_entry" \
        --argjson plan "$plan_entry" \
        --argjson tasks "$tasks_entry" \
        '{spec_md:$spec,plan_md:$plan,tasks_md:$tasks}')"

    local logs_json
    logs_json="$(collect_logs_json)"
    local execution_time_seconds
    execution_time_seconds="$(current_execution_time)"

    jq -n \
        --arg correlation_id "$CORRELATION_ID" \
        --arg status "success" \
        --arg branch "$branch" \
        --arg commit_sha "$commit_sha" \
        --arg commit_message "$commit_message" \
        --arg pr_url "$pr_url" \
        --argjson outputs "$outputs_json" \
        --argjson logs "$logs_json" \
        --arg execution_time_seconds "$execution_time_seconds" \
        '{
            correlation_id: $correlation_id,
            status: $status,
            execution_time_seconds: ($execution_time_seconds | tonumber),
            outputs: $outputs,
            git_operations: {
                branch: $branch,
                commit_sha: $commit_sha,
                commit_message: $commit_message,
                push_status: "success",
                pr_url: $pr_url
            },
            logs: $logs
        }' > "$RESULT_FILE"
}

require_env_vars
export GH_TOKEN="${GH_TOKEN:-$GITHUB_TOKEN}"

if [[ ! -f "$BRD_FILE" ]]; then
    log_event "ERROR" "找不到 brd_analysis.json" "$(jq -n --arg path "$BRD_FILE" '{path:$path}')"
    handle_error "VALIDATION_ERROR" "找不到輸入檔案：$BRD_FILE"
fi

CORRELATION_ID="$(jq -r '.correlation_id // empty' "$BRD_FILE")"
if [[ -z "$CORRELATION_ID" ]]; then
    handle_error "VALIDATION_ERROR" "brd_analysis.json 缺少 correlation_id"
fi
export CORRELATION_ID

log_event "INFO" "開始處理請求" "$(jq -n --arg id "$CORRELATION_ID" '{correlation_id:$id}')"

EXECUTION_REPO="$(jq -r '.execution_context.github_repo // empty' "$BRD_FILE")"
if [[ -n "$EXECUTION_REPO" ]]; then
    GITHUB_REPO="$EXECUTION_REPO"
fi

BRANCH_PREFIX="$(jq -r '.execution_context.feature_branch_prefix // "bot/spec"' "$BRD_FILE")"
BRANCH_PREFIX="${BRANCH_PREFIX// /-}"
TIMESTAMP="$(date -u +"%Y%m%d-%H%M%S")"
BRANCH_NAME="${BRANCH_PREFIX}-${TIMESTAMP}"

SPECKIT_COMMANDS=()
while IFS= read -r speckit_command; do
    [[ -z "$speckit_command" ]] && continue
    SPECKIT_COMMANDS+=("$speckit_command")
done < <(jq -r '.speckit_commands[]?' "$BRD_FILE" 2>/dev/null)
if [[ "${#SPECKIT_COMMANDS[@]}" -eq 0 ]]; then
    SPECKIT_COMMANDS=(
        "/speckit.specify --input $BRD_FILE"
        "/speckit.plan"
        "/speckit.tasks --mode tdd --no-parallel"
    )
fi

log_event "INFO" "初始化 Git 倉庫" "$(jq -n --arg repo "$GITHUB_REPO" '{repo:$repo}')"
if [[ ! -d "$WORKSPACE_DIR/.git" ]]; then
    rm -rf "$WORKSPACE_DIR"
    git clone "https://github.com/${GITHUB_REPO}.git" "$WORKSPACE_DIR"
fi
cd "$WORKSPACE_DIR"

git fetch origin main >/dev/null 2>&1
if ! git checkout main >/dev/null 2>&1; then
    handle_error "GIT_ERROR" "無法切換至 main 分支"
fi
ensure_git_identity

if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    BRANCH_NAME="${BRANCH_NAME}-$(date +%s)"
fi

git checkout -b "$BRANCH_NAME"
log_event "INFO" "建立新分支" "$(jq -n --arg branch "$BRANCH_NAME" '{branch:$branch}')"

for command in "${SPECKIT_COMMANDS[@]}"; do
    NORMALIZED_COMMAND="$(normalize_command "$command")"
    log_event "INFO" "執行 SpecKit 指令" "$(jq -n --arg command "$NORMALIZED_COMMAND" '{command:$command}')"
    "$CLAUDE_CLI_BIN" execute "$NORMALIZED_COMMAND"
done

log_event "INFO" "執行 Mermaid 驗證" "$(jq -n '{script:"validate_mermaid"}')"
bash "$VALIDATE_MERMAID_SCRIPT" "$WORKSPACE_DIR"

SPEC_DIR_RELATIVE="$(discover_feature_dir)"
if [[ -z "$SPEC_DIR_RELATIVE" ]]; then
    handle_error "VALIDATION_ERROR" "找不到 Spec 產出目錄"
fi

git add specs/
if ! git diff --cached --quiet; then
    COMMIT_MESSAGE=$'feat: 新增 Spec Bot SDD 文件\n\n由 Claude CLI 自動產生\nCorrelation ID: '"$CORRELATION_ID"
    git commit -m "$COMMIT_MESSAGE"
else
    handle_error "VALIDATION_ERROR" "沒有可提交的變更"
fi

COMMIT_SHA="$(git rev-parse HEAD)"
log_event "INFO" "Git commit 完成" "$(jq -n --arg sha "$COMMIT_SHA" '{commit_sha:$sha}')"

git push origin "$BRANCH_NAME"
log_event "INFO" "Git push 成功" "$(jq -n --arg branch "$BRANCH_NAME" '{branch:$branch}')"

PR_TITLE="feat: 新增 Spec Bot SDD 文件"
PR_BODY=$'由 GPT-5 nano 協調，Claude CLI 產生。\n\nCorrelation ID: '"$CORRELATION_ID"$'\n\n請審核 Spec/Plan/Tasks。'
PR_RESPONSE="$("$GH_BIN" pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --base main \
    --head "$BRANCH_NAME")"
PR_URL="$(grep -Eo 'https://[^[:space:]]+' <<< "$PR_RESPONSE" | head -n 1)"
if [[ -z "$PR_URL" ]]; then
    handle_error "GITHUB_API_ERROR" "gh pr create 未回傳 PR URL"
fi

log_event "INFO" "GitHub PR 建立成功" "$(jq -n --arg pr "$PR_URL" '{pr_url:$pr}')"

SPEC_PATH="$SPEC_DIR_RELATIVE/spec.md"
PLAN_PATH="$SPEC_DIR_RELATIVE/plan.md"
TASKS_PATH="$SPEC_DIR_RELATIVE/tasks.md"

log_event "INFO" "產出 result.json" "$(jq -n --arg branch "$BRANCH_NAME" '{branch:$branch}')"
write_success_result "$BRANCH_NAME" "$COMMIT_SHA" "$COMMIT_MESSAGE" "$PR_URL" "$SPEC_PATH" "$PLAN_PATH" "$TASKS_PATH"
echo "✅ 完成：$CORRELATION_ID"
