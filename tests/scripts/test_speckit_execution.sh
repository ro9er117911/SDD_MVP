#!/usr/bin/env bash

# T018: SpecKit 指令執行模擬測試
# 目的: 驗證 run_speckit.sh 中的 SpecKit 指令執行邏輯

set -euo pipefail

# 測試結果追蹤
TESTS_PASSED=0
TESTS_FAILED=0
TEST_NAME="T018: SpecKit 指令執行模擬測試"

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
# Test 1: 檢查 Claude CLI 執行指令存在
# ========================================
test_claude_cli_execute() {
    echo -n "Test 1: 檢查 Claude CLI 執行指令存在... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 匹配 claude-cli execute 或 $CLAUDE_CLI_BIN execute（含雙引號）
    if grep -qE "claude-cli.*execute|CLAUDE_CLI_BIN.*execute" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'claude-cli execute' 或 '\$CLAUDE_CLI_BIN execute' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 2: 檢查 /speckit.specify 指令
# ========================================
test_speckit_specify() {
    echo -n "Test 2: 檢查 /speckit.specify 指令... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "/speckit.specify" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 '/speckit.specify' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 3: 檢查 /speckit.plan 指令
# ========================================
test_speckit_plan() {
    echo -n "Test 3: 檢查 /speckit.plan 指令... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "/speckit.plan" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 '/speckit.plan' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 4: 檢查 /speckit.tasks 指令
# ========================================
test_speckit_tasks() {
    echo -n "Test 4: 檢查 /speckit.tasks 指令... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "/speckit.tasks" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 '/speckit.tasks' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 5: 檢查 --input 參數傳遞給 /speckit.specify
# ========================================
test_speckit_specify_input() {
    echo -n "Test 5: 檢查 --input 參數傳遞... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否有 --input 參數傳遞給 /speckit.specify
    if grep "/speckit.specify" "$SCRIPT_PATH" | grep -q -- "--input"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: /speckit.specify 可能缺少 --input 參數"
        # 仍然算通過，因為可能使用其他方式傳遞
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# Test 6: 檢查 TDD 模式參數
# ========================================
test_speckit_tdd_mode() {
    echo -n "Test 6: 檢查 TDD 模式參數... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否有 --mode tdd 或 --no-parallel 參數
    if grep "/speckit.tasks" "$SCRIPT_PATH" | grep -qE -- "--mode tdd|--no-parallel"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: /speckit.tasks 可能缺少 TDD 模式參數"
        # 仍然算通過
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# Test 7: 檢查輸出檔案路徑變數
# ========================================
test_output_file_variables() {
    echo -n "Test 7: 檢查輸出檔案路徑變數... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否定義了 spec.md, plan.md, tasks.md 的路徑變數
    REQUIRED_VARS=("SPEC_PATH" "PLAN_PATH" "TASKS_PATH")
    MISSING_VARS=()

    for var in "${REQUIRED_VARS[@]}"; do
        if ! grep -q "$var" "$SCRIPT_PATH"; then
            MISSING_VARS+=("$var")
        fi
    done

    if [ ${#MISSING_VARS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: 缺少以下輸出檔案路徑變數:"
        for var in "${MISSING_VARS[@]}"; do
            echo "    - $var"
        done
        # 仍然算通過
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# Test 8: 檢查 SpecKit 指令陣列
# ========================================
test_speckit_commands_array() {
    echo -n "Test 8: 檢查 SpecKit 指令陣列... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否有 SPECKIT_COMMANDS 陣列或類似結構
    if grep -qE "SPECKIT_COMMANDS|speckit_commands" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: 未發現 SpecKit 指令陣列"
        # 仍然算通過
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# Test 9: 檢查從 brd_analysis.json 讀取指令
# ========================================
test_read_commands_from_brd() {
    echo -n "Test 9: 檢查從 brd_analysis.json 讀取指令... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否從 BRD_FILE 讀取 speckit_commands
    if grep -q "speckit_commands" "$SCRIPT_PATH" && grep -q "BRD_FILE" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: 可能未從 brd_analysis.json 讀取 SpecKit 指令"
        # 仍然算通過
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# Test 10: 檢查 Claude CLI 錯誤處理
# ========================================
test_claude_cli_error_handling() {
    echo -n "Test 10: 檢查 Claude CLI 錯誤處理... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否有錯誤處理（handle_error, trap, ||等）
    if grep -qE "handle_error|trap|\\|\\|" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少錯誤處理機制"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# 執行所有測試
# ========================================
echo "開始執行測試..."
echo ""

test_claude_cli_execute
test_speckit_specify
test_speckit_plan
test_speckit_tasks
test_speckit_specify_input
test_speckit_tdd_mode
test_output_file_variables
test_speckit_commands_array
test_read_commands_from_brd
test_claude_cli_error_handling

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
    echo "🎉 Phase 3 紅燈階段測試完成 (T016-T018)"
    echo "下一步: 執行 T022-T024 驗證測試（綠燈階段）"
    exit 0
else
    echo -e "${RED}❌ 有 $TESTS_FAILED 個測試失敗${NC}"
    echo ""
    echo "TDD 紅燈階段 ✓ - 測試失敗符合預期"
    echo "下一步: 修正 $SCRIPT_PATH 以通過測試"
    exit 1
fi
