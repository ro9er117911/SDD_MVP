#!/usr/bin/env bash
# T018: SpecKit 指令執行模擬測試

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/shared.sh"

TARGET_SCRIPT="$REPO_ROOT/docker/scripts/run_speckit.sh"

echo "🧪 T018: SpecKit 指令執行模擬"
echo "================================"

if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo "❌ 失敗: 找不到 $TARGET_SCRIPT，請先完成 T019。"
    exit 1
fi

create_run_env
trap cleanup_run_env EXIT

pushd "$REPO_ROOT" >/dev/null
if ! bash "$TARGET_SCRIPT"; then
    echo "❌ 失敗: run_speckit.sh 執行失敗。"
    exit 1
fi
popd >/dev/null

if [[ ! -f "$MOCK_CLAUDE_LOG" ]]; then
    echo "❌ 失敗: 未偵測到 claude-cli 執行紀錄。"
    exit 1
fi

EXECUTED_COMMANDS=()
while IFS= read -r command_line; do
    EXECUTED_COMMANDS+=("$command_line")
done < "$MOCK_CLAUDE_LOG"
if [[ "${#EXECUTED_COMMANDS[@]}" -ne 3 ]]; then
    echo "❌ 失敗: 預期執行 3 個 SpecKit 指令，實際為 ${#EXECUTED_COMMANDS[@]}。"
    exit 1
fi

EXPECTED_COMMANDS=(
    "/speckit.specify"
    "/speckit.plan"
    "/speckit.tasks --mode tdd --no-parallel"
)

for idx in "${!EXPECTED_COMMANDS[@]}"; do
    if [[ "${EXECUTED_COMMANDS[$idx]}" != *"${EXPECTED_COMMANDS[$idx]}"* ]]; then
        echo "❌ 失敗: 第 $((idx + 1)) 個指令應包含 '${EXPECTED_COMMANDS[$idx]}', 實際為 '${EXECUTED_COMMANDS[$idx]}'。"
        exit 1
    fi
done
echo "✅ SpecKit 指令依序執行成功"

SPEC_DIR="$WORKSPACE_DIR/specs/001-spec-bot-sdd-integration"
for file in spec.md plan.md tasks.md; do
    if [[ ! -s "$SPEC_DIR/$file" ]]; then
        echo "❌ 失敗: 找不到或內容為空的輸出檔案 $SPEC_DIR/$file"
        exit 1
    fi
done
echo "✅ SpecKit 輸出檔案已生成 (spec/plan/tasks)"

RESULT_FILE="$OUTPUT_DIR/result.json"
if [[ ! -f "$RESULT_FILE" ]]; then
    echo "❌ 失敗: 未找到輸出檔案 $RESULT_FILE"
    exit 1
fi

STATUS="$(jq -r '.status' "$RESULT_FILE")"
if [[ "$STATUS" != "success" ]]; then
    echo "❌ 失敗: result.json 應為 success，實際為 $STATUS。"
    exit 1
fi

EXEC_TIME="$(jq -r '.execution_time_seconds' "$RESULT_FILE")"
if [[ "$EXEC_TIME" -lt 0 || "$EXEC_TIME" -gt 600 ]]; then
    echo "❌ 失敗: execution_time_seconds 超出合理範圍 (0-600)，實際為 $EXEC_TIME。"
    exit 1
fi

for output_key in spec_md plan_md tasks_md; do
    REL_PATH="$(jq -r ".outputs.$output_key.path" "$RESULT_FILE")"
    SIZE_BYTES="$(jq -r ".outputs.$output_key.size_bytes" "$RESULT_FILE")"
    CHECKSUM="$(jq -r ".outputs.$output_key.checksum" "$RESULT_FILE")"

    if [[ "$REL_PATH" == "null" || -z "$REL_PATH" ]]; then
        echo "❌ 失敗: outputs.$output_key.path 未設定。"
        exit 1
    fi

    if [[ ! -f "$WORKSPACE_DIR/$REL_PATH" ]]; then
        echo "❌ 失敗: 指定的檔案不存在：$WORKSPACE_DIR/$REL_PATH"
        exit 1
    fi

    if [[ "$SIZE_BYTES" -le 0 ]]; then
        echo "❌ 失敗: outputs.$output_key.size_bytes 應大於 0。"
        exit 1
    fi

    if [[ ! "$CHECKSUM" =~ ^sha256:[a-f0-9]{64}$ ]]; then
        echo "❌ 失敗: outputs.$output_key.checksum 格式錯誤：$CHECKSUM"
        exit 1
    fi
done
echo "✅ result.json outputs 區塊資訊完整"

LOG_COUNT="$(jq -r '.logs | length' "$RESULT_FILE")"
if [[ "$LOG_COUNT" -le 0 ]]; then
    echo "❌ 失敗: result.json 應包含至少一筆執行日誌。"
    exit 1
fi

echo "✅ result.json 基本欄位驗證通過 (status/execution_time/logs)"
echo ""
echo "✅ T018 測試通過：SpecKit 指令模擬與輸出驗證成功"
