#!/usr/bin/env bash

# T016: Claude CLI 腳本語法測試
# 目的: 驗證 run_speckit.sh 的 Bash 語法、變數定義、錯誤處理

set -euo pipefail

# 測試結果追蹤
TESTS_PASSED=0
TESTS_FAILED=0
TEST_NAME="T016: Claude CLI 腳本語法測試"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 測試腳本路徑
SCRIPT_PATH="docker/scripts/run_speckit.sh"

echo "========================================="
echo "$TEST_NAME"
echo "========================================="
echo ""

# ========================================
# Test 1: 檢查檔案是否存在
# ========================================
test_file_exists() {
    echo -n "Test 1: 檢查 $SCRIPT_PATH 是否存在... "
    if [ -f "$SCRIPT_PATH" ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 檔案不存在"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 2: 驗證 Bash 語法正確性
# ========================================
test_bash_syntax() {
    echo -n "Test 2: 驗證 Bash 語法正確性 (bash -n)... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if bash -n "$SCRIPT_PATH" 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: Bash 語法檢查失敗"
        bash -n "$SCRIPT_PATH" 2>&1 | head -10
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 3: 檢查錯誤處理機制 (set -e)
# ========================================
test_error_handling_set_e() {
    echo -n "Test 3: 檢查錯誤處理 (set -e)... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 匹配 set -e, set -Eeuo, set -euo 等各種形式
    if grep -q "^set -.*e" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'set -e' 錯誤處理"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 4: 檢查 trap 錯誤捕捉機制
# ========================================
test_trap_mechanism() {
    echo -n "Test 4: 檢查 trap 錯誤捕捉機制... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "^trap" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'trap' 錯誤捕捉機制"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 5: 檢查必要變數定義
# ========================================
test_required_variables() {
    echo -n "Test 5: 檢查必要變數定義... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 必要變數清單
    REQUIRED_VARS=(
        "CORRELATION_ID"
        "INPUT_DIR"
        "OUTPUT_DIR"
        "WORKSPACE"
    )

    MISSING_VARS=()

    for var in "${REQUIRED_VARS[@]}"; do
        # 檢查變數是否在腳本中定義或使用
        if ! grep -q "\$$var\|$var=" "$SCRIPT_PATH"; then
            MISSING_VARS+=("$var")
        fi
    done

    if [ ${#MISSING_VARS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少以下變數定義或使用:"
        for var in "${MISSING_VARS[@]}"; do
            echo "    - $var"
        done
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 6: 檢查 Shebang 正確性
# ========================================
test_shebang() {
    echo -n "Test 6: 檢查 Shebang 行... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    FIRST_LINE=$(head -1 "$SCRIPT_PATH")

    if [[ "$FIRST_LINE" == "#!/usr/bin/env bash" ]] || [[ "$FIRST_LINE" == "#!/bin/bash" ]]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: Shebang 不正確，應為 '#!/usr/bin/env bash' 或 '#!/bin/bash'"
        echo "  實際: $FIRST_LINE"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 7: 檢查檔案可執行權限
# ========================================
test_executable_permission() {
    echo -n "Test 7: 檢查檔案可執行權限... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if [ -x "$SCRIPT_PATH" ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: 檔案不具可執行權限（可使用 chmod +x 修正）"
        # 不計入失敗，因為可以稍後修正
        return 0
    fi
}

# ========================================
# 執行所有測試
# ========================================
echo "開始執行測試..."
echo ""

test_file_exists
test_bash_syntax
test_error_handling_set_e
test_trap_mechanism
test_required_variables
test_shebang
test_executable_permission

# ========================================
# 測試結果摘要
# ========================================
echo ""
echo "========================================="
echo "測試結果摘要"
echo "========================================="
echo -e "通過: ${GREEN}$TESTS_PASSED${NC}"
echo -e "失敗: ${RED}$TESTS_FAILED${NC}"
echo "總計: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 所有測試通過！${NC}"
    echo ""
    echo "下一步: 執行 T017 測試 (Git 操作模擬測試)"
    exit 0
else
    echo -e "${RED}❌ 有 $TESTS_FAILED 個測試失敗${NC}"
    echo ""
    echo "TDD 紅燈階段 ✓ - 測試失敗符合預期"
    echo "下一步: 實作 $SCRIPT_PATH 以通過測試"
    exit 1
fi
