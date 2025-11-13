#!/bin/bash
# 測試檔案: test_brd_analysis_schema.sh
# 目的: 驗證 brd_analysis.json Schema 格式與必要欄位
# TDD 階段: 紅燈 (預期失敗，因為 schema 尚未建立)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SCHEMA_FILE="$PROJECT_ROOT/specs/001-spec-bot-sdd-integration/contracts/brd_analysis_schema.json"
SAMPLE_FILE="$PROJECT_ROOT/tests/fixtures/brd_analysis_sample.json"

echo "========================================="
echo "測試: brd_analysis.json Schema 驗證"
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

# 測試 3: 檢查測試範例檔案是否存在
echo ""
echo "[TEST 3] 檢查測試範例檔案存在..."
if [ ! -f "$SAMPLE_FILE" ]; then
    echo "❌ FAILED: 測試範例檔案不存在: $SAMPLE_FILE"
    exit 1
fi
echo "✅ PASSED: 測試範例檔案存在"

# 測試 4: 驗證測試範例符合 Schema
echo ""
echo "[TEST 4] 驗證測試範例符合 Schema..."
if ! ajv validate -s "$SCHEMA_FILE" -d "$SAMPLE_FILE" --spec=draft7 -c ajv-formats; then
    echo "❌ FAILED: 測試範例不符合 Schema"
    exit 1
fi
echo "✅ PASSED: 測試範例符合 Schema"

# 測試 5: 驗證必要欄位 (correlation_id, timestamp, brd_content, analysis, speckit_commands)
echo ""
echo "[TEST 5] 驗證必要欄位存在..."
REQUIRED_FIELDS=("correlation_id" "timestamp" "brd_content" "analysis" "speckit_commands")

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$SAMPLE_FILE" > /dev/null 2>&1; then
        echo "❌ FAILED: 缺少必要欄位: $field"
        exit 1
    fi
done
echo "✅ PASSED: 所有必要欄位存在"

# 測試 6: 驗證 correlation_id 格式 (^req-[a-zA-Z0-9-]+$)
echo ""
echo "[TEST 6] 驗證 correlation_id 格式..."
CORRELATION_ID=$(jq -r '.correlation_id' "$SAMPLE_FILE")
if ! echo "$CORRELATION_ID" | grep -qE '^req-[a-zA-Z0-9-]+$'; then
    echo "❌ FAILED: correlation_id 格式錯誤: $CORRELATION_ID"
    exit 1
fi
echo "✅ PASSED: correlation_id 格式正確: $CORRELATION_ID"

# 測試 7: 驗證 analysis 包含必要子欄位
echo ""
echo "[TEST 7] 驗證 analysis 子欄位..."
ANALYSIS_FIELDS=("functional_requirements" "non_functional_requirements" "constraints")

for field in "${ANALYSIS_FIELDS[@]}"; do
    if ! jq -e ".analysis.$field" "$SAMPLE_FILE" > /dev/null 2>&1; then
        echo "❌ FAILED: analysis 缺少欄位: $field"
        exit 1
    fi
done
echo "✅ PASSED: analysis 包含所有必要欄位"

echo ""
echo "========================================="
echo "✅ 所有測試通過"
echo "========================================="
