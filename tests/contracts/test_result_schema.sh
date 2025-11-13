#!/bin/bash
# 測試檔案: test_result_schema.sh
# 目的: 驗證 result.json Schema 格式與必要欄位（成功與錯誤案例）
# TDD 階段: 紅燈 (預期失敗，因為 schema 尚未建立)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SCHEMA_FILE="$PROJECT_ROOT/specs/001-spec-bot-sdd-integration/contracts/result_schema.json"
SUCCESS_SAMPLE="$PROJECT_ROOT/tests/fixtures/result_success_sample.json"
ERROR_SAMPLE="$PROJECT_ROOT/tests/fixtures/result_error_sample.json"

echo "========================================="
echo "測試: result.json Schema 驗證"
echo "========================================="

# 測試 1: 檢查 Schema 檔案是否存在
echo ""
echo "[TEST 1] 檢查 Schema 檔案存在..."
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ FAILED: Schema 檔案不存在: $SCHEMA_FILE"
    exit 1
fi
echo "✅ PASSED: Schema 檔案存在"

# 測試 2: 檢查 Schema 語法是否有效
echo ""
echo "[TEST 2] 驗證 Schema 語法..."
if ! ajv compile -s "$SCHEMA_FILE" --spec=draft7 -c ajv-formats 2>/dev/null; then
    echo "❌ FAILED: Schema 語法無效"
    exit 1
fi
echo "✅ PASSED: Schema 語法有效"

# 測試 3: 檢查成功案例測試範例檔案是否存在
echo ""
echo "[TEST 3] 檢查成功案例測試範例存在..."
if [ ! -f "$SUCCESS_SAMPLE" ]; then
    echo "❌ FAILED: 成功案例測試範例不存在: $SUCCESS_SAMPLE"
    exit 1
fi
echo "✅ PASSED: 成功案例測試範例存在"

# 測試 4: 檢查錯誤案例測試範例檔案是否存在
echo ""
echo "[TEST 4] 檢查錯誤案例測試範例存在..."
if [ ! -f "$ERROR_SAMPLE" ]; then
    echo "❌ FAILED: 錯誤案例測試範例不存在: $ERROR_SAMPLE"
    exit 1
fi
echo "✅ PASSED: 錯誤案例測試範例存在"

# 測試 5: 驗證成功案例符合 Schema
echo ""
echo "[TEST 5] 驗證成功案例符合 Schema..."
if ! ajv validate -s "$SCHEMA_FILE" -d "$SUCCESS_SAMPLE" --spec=draft7 -c ajv-formats; then
    echo "❌ FAILED: 成功案例不符合 Schema"
    exit 1
fi
echo "✅ PASSED: 成功案例符合 Schema"

# 測試 6: 驗證錯誤案例符合 Schema
echo ""
echo "[TEST 6] 驗證錯誤案例符合 Schema..."
if ! ajv validate -s "$SCHEMA_FILE" -d "$ERROR_SAMPLE" --spec=draft7 -c ajv-formats; then
    echo "❌ FAILED: 錯誤案例不符合 Schema"
    exit 1
fi
echo "✅ PASSED: 錯誤案例符合 Schema"

# 測試 7: 驗證成功案例必要欄位 (correlation_id, status, git_operations, logs)
echo ""
echo "[TEST 7] 驗證成功案例必要欄位..."
REQUIRED_FIELDS=("correlation_id" "status" "git_operations" "logs")

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$SUCCESS_SAMPLE" > /dev/null 2>&1; then
        echo "❌ FAILED: 成功案例缺少必要欄位: $field"
        exit 1
    fi
done
echo "✅ PASSED: 成功案例包含所有必要欄位"

# 測試 8: 驗證成功案例 status 值為 "success"
echo ""
echo "[TEST 8] 驗證成功案例 status 值..."
STATUS=$(jq -r '.status' "$SUCCESS_SAMPLE")
if [ "$STATUS" != "success" ]; then
    echo "❌ FAILED: 成功案例 status 值錯誤: $STATUS (預期: success)"
    exit 1
fi
echo "✅ PASSED: 成功案例 status 值正確: $STATUS"

# 測試 9: 驗證錯誤案例必要欄位 (correlation_id, status, error_type, error_message, logs)
echo ""
echo "[TEST 9] 驗證錯誤案例必要欄位..."
ERROR_REQUIRED_FIELDS=("correlation_id" "status" "error_type" "error_message" "logs")

for field in "${ERROR_REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$ERROR_SAMPLE" > /dev/null 2>&1; then
        echo "❌ FAILED: 錯誤案例缺少必要欄位: $field"
        exit 1
    fi
done
echo "✅ PASSED: 錯誤案例包含所有必要欄位"

# 測試 10: 驗證錯誤案例 status 值為 "error"
echo ""
echo "[TEST 10] 驗證錯誤案例 status 值..."
ERROR_STATUS=$(jq -r '.status' "$ERROR_SAMPLE")
if [ "$ERROR_STATUS" != "error" ]; then
    echo "❌ FAILED: 錯誤案例 status 值錯誤: $ERROR_STATUS (預期: error)"
    exit 1
fi
echo "✅ PASSED: 錯誤案例 status 值正確: $ERROR_STATUS"

# 測試 11: 驗證 git_operations 子欄位 (成功案例)
echo ""
echo "[TEST 11] 驗證成功案例 git_operations 子欄位..."
GIT_FIELDS=("branch" "commit_sha" "pr_url")

for field in "${GIT_FIELDS[@]}"; do
    if ! jq -e ".git_operations.$field" "$SUCCESS_SAMPLE" > /dev/null 2>&1; then
        echo "❌ FAILED: git_operations 缺少欄位: $field"
        exit 1
    fi
done
echo "✅ PASSED: git_operations 包含所有必要欄位"

# 測試 12: 驗證 correlation_id 格式 (兩個案例)
echo ""
echo "[TEST 12] 驗證 correlation_id 格式..."
for sample in "$SUCCESS_SAMPLE" "$ERROR_SAMPLE"; do
    CORRELATION_ID=$(jq -r '.correlation_id' "$sample")
    if ! echo "$CORRELATION_ID" | grep -qE '^req-[a-zA-Z0-9-]+$'; then
        echo "❌ FAILED: correlation_id 格式錯誤: $CORRELATION_ID (檔案: $(basename $sample))"
        exit 1
    fi
done
echo "✅ PASSED: correlation_id 格式正確"

echo ""
echo "========================================="
echo "✅ 所有測試通過"
echo "========================================="
