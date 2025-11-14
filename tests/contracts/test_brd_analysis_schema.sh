#!/bin/bash
# T008: brd_analysis.json Schema 驗證測試
# 使用 ajv-cli 驗證 JSON Schema

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SCHEMA_FILE="$PROJECT_ROOT/specs/001-spec-bot-sdd-integration/contracts/brd_analysis_schema.json"
SAMPLE_FILE="$PROJECT_ROOT/tests/fixtures/brd_analysis_sample.json"

echo "========================================="
echo "測試: brd_analysis.json Schema 驗證"
echo "========================================="

# 檢查 Schema 檔案是否存在
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ FAILED: Schema 檔案不存在: $SCHEMA_FILE"
    exit 1
fi

# 檢查測試範例檔案是否存在
if [ ! -f "$SAMPLE_FILE" ]; then
    echo "❌ FAILED: 測試範例檔案不存在: $SAMPLE_FILE"
    exit 1
fi

# 檢查 ajv-cli 是否已安裝
if ! command -v ajv &> /dev/null; then
    echo "⚠️  警告: ajv-cli 未安裝，正在安裝..."
    npm install -g ajv-cli ajv-formats
fi

# 使用 ajv-cli 驗證 Schema
echo ""
echo "驗證 JSON Schema 語法..."
ajv compile -s "$SCHEMA_FILE"

if [ $? -ne 0 ]; then
    echo "❌ FAILED: Schema 語法錯誤"
    exit 1
fi

echo "✅ Schema 語法正確"

# 驗證測試範例是否符合 Schema
echo ""
echo "驗證測試範例是否符合 Schema..."
ajv validate -s "$SCHEMA_FILE" -d "$SAMPLE_FILE"

if [ $? -ne 0 ]; then
    echo "❌ FAILED: 測試範例不符合 Schema"
    exit 1
fi

echo "✅ 測試範例符合 Schema"

# 驗證必要欄位
echo ""
echo "驗證必要欄位..."
REQUIRED_FIELDS=("correlation_id" "timestamp" "brd_content" "analysis" "speckit_commands")

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$SAMPLE_FILE" > /dev/null 2>&1; then
        echo "❌ FAILED: 缺少必要欄位: $field"
        exit 1
    fi
    echo "  ✓ $field"
done

# 驗證 correlation_id 格式 (^req-[a-zA-Z0-9-]+$)
echo ""
echo "驗證 correlation_id 格式..."
CORRELATION_ID=$(jq -r '.correlation_id' "$SAMPLE_FILE")
if [[ ! "$CORRELATION_ID" =~ ^req-[a-zA-Z0-9-]+$ ]]; then
    echo "❌ FAILED: correlation_id 格式不正確: $CORRELATION_ID"
    exit 1
fi
echo "  ✓ correlation_id 格式正確: $CORRELATION_ID"

# 驗證 analysis.functional_requirements 陣列
echo ""
echo "驗證 analysis.functional_requirements..."
if ! jq -e '.analysis.functional_requirements | type == "array"' "$SAMPLE_FILE" > /dev/null 2>&1; then
    echo "❌ FAILED: analysis.functional_requirements 必須是陣列"
    exit 1
fi
echo "  ✓ analysis.functional_requirements 是陣列"

# 驗證功能需求編號格式 (FR-xxx)
FR_COUNT=$(jq -r '.analysis.functional_requirements | length' "$SAMPLE_FILE")
echo "  ✓ 功能需求數量: $FR_COUNT"

for ((i=0; i<$FR_COUNT; i++)); do
    FR_ID=$(jq -r ".analysis.functional_requirements[$i].id" "$SAMPLE_FILE")
    if [[ ! "$FR_ID" =~ ^FR-[0-9]{3}$ ]]; then
        echo "❌ FAILED: 功能需求編號格式不正確: $FR_ID"
        exit 1
    fi
done
echo "  ✓ 所有功能需求編號格式正確"

# 驗證 speckit_commands 陣列
echo ""
echo "驗證 speckit_commands..."
if ! jq -e '.speckit_commands | type == "array"' "$SAMPLE_FILE" > /dev/null 2>&1; then
    echo "❌ FAILED: speckit_commands 必須是陣列"
    exit 1
fi
echo "  ✓ speckit_commands 是陣列"

echo ""
echo "========================================="
echo "✅ PASSED: 所有驗證通過"
echo "========================================="
exit 0
