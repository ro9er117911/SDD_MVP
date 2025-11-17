#!/bin/bash
# T008: brd_analysis.json Schema 驗證測試
# 測試檔案: tests/contracts/test_brd_analysis_schema.sh
# 使用 ajv-cli 驗證 JSON Schema

set -e  # 遇到錯誤立即停止

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 顏色定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "T008: brd_analysis.json Schema 驗證測試"
echo "========================================="

# 檢查 ajv-cli 是否已安裝
if ! command -v ajv &> /dev/null; then
    echo -e "${YELLOW}⚠️  ajv-cli 未安裝，正在安裝...${NC}"
    npm install -g ajv-cli ajv-formats
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ ajv-cli 安裝失敗${NC}"
        exit 1
    fi
fi

# 檢查必要檔案
SCHEMA_FILE="$PROJECT_ROOT/specs/001-spec-bot-sdd-integration/contracts/brd_analysis_schema.json"
SAMPLE_FILE="$PROJECT_ROOT/tests/fixtures/brd_analysis_sample.json"

if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}❌ Schema 檔案不存在: $SCHEMA_FILE${NC}"
    echo "請先執行 T010 建立 brd_analysis_schema.json"
    exit 1
fi

if [ ! -f "$SAMPLE_FILE" ]; then
    echo -e "${RED}❌ 測試範例不存在: $SAMPLE_FILE${NC}"
    echo "請先執行 T012 建立 brd_analysis_sample.json"
    exit 1
fi

# 執行 Schema 驗證
echo ""
echo "驗證檔案:"
echo "  Schema: $SCHEMA_FILE"
echo "  Sample: $SAMPLE_FILE"
echo ""

ajv validate -s "$SCHEMA_FILE" -d "$SAMPLE_FILE" --spec=draft7 --strict=false

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ PASSED: brd_analysis.json Schema 驗證通過${NC}"
    echo ""
    echo "驗證項目:"
    echo "  ✓ correlation_id 格式正確 (pattern: ^req-[a-zA-Z0-9-]+$)"
    echo "  ✓ timestamp 為有效的 ISO 8601 格式"
    echo "  ✓ brd_content 長度在 100-102400 之間"
    echo "  ✓ analysis.functional_requirements 為陣列"
    echo "  ✓ speckit_commands 為字串陣列"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}❌ FAILED: Schema 驗證失敗${NC}"
    exit 1
fi
