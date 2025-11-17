#!/bin/bash
# T009: result.json Schema 驗證測試
# 測試檔案: tests/contracts/test_result_schema.sh
# 驗證必要欄位: correlation_id, status, git_operations, logs

set -e  # 遇到錯誤立即停止

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 顏色定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "T009: result.json Schema 驗證測試"
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
SCHEMA_FILE="$PROJECT_ROOT/specs/001-spec-bot-sdd-integration/contracts/result_schema.json"
SUCCESS_SAMPLE="$PROJECT_ROOT/tests/fixtures/result_success_sample.json"
ERROR_SAMPLE="$PROJECT_ROOT/tests/fixtures/result_error_sample.json"

if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}❌ Schema 檔案不存在: $SCHEMA_FILE${NC}"
    echo "請先執行 T011 建立 result_schema.json"
    exit 1
fi

if [ ! -f "$SUCCESS_SAMPLE" ]; then
    echo -e "${RED}❌ 成功案例不存在: $SUCCESS_SAMPLE${NC}"
    echo "請先執行 T013 建立 result_success_sample.json"
    exit 1
fi

if [ ! -f "$ERROR_SAMPLE" ]; then
    echo -e "${RED}❌ 錯誤案例不存在: $ERROR_SAMPLE${NC}"
    echo "請先執行 T013 建立 result_error_sample.json"
    exit 1
fi

# 測試成功案例
echo ""
echo "【測試 1/2】驗證成功案例"
echo "  Schema: $SCHEMA_FILE"
echo "  Sample: $SUCCESS_SAMPLE"
echo ""

ajv validate -s "$SCHEMA_FILE" -d "$SUCCESS_SAMPLE" --spec=draft7 --strict=false

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 成功案例驗證通過${NC}"
else
    echo -e "${RED}❌ 成功案例驗證失敗${NC}"
    exit 1
fi

# 測試錯誤案例
echo ""
echo "【測試 2/2】驗證錯誤案例"
echo "  Schema: $SCHEMA_FILE"
echo "  Sample: $ERROR_SAMPLE"
echo ""

ajv validate -s "$SCHEMA_FILE" -d "$ERROR_SAMPLE" --spec=draft7 --strict=false

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 錯誤案例驗證通過${NC}"
else
    echo -e "${RED}❌ 錯誤案例驗證失敗${NC}"
    exit 1
fi

# 所有測試通過
echo ""
echo -e "${GREEN}✅ PASSED: 所有 result.json Schema 驗證通過${NC}"
echo ""
echo "驗證項目:"
echo "  ✓ correlation_id 格式正確"
echo "  ✓ status 為 'success' 或 'error'"
echo "  ✓ 成功案例包含 git_operations (branch, commit_sha, pr_url)"
echo "  ✓ 錯誤案例包含 error_type 與 error_message"
echo "  ✓ logs 為陣列格式"
echo ""
exit 0
