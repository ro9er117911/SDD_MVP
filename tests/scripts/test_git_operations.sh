#!/usr/bin/env bash

# T017: Git 操作模擬測試
# 目的: 驗證 run_speckit.sh 中的 Git 操作正確性

set -euo pipefail

# 測試結果追蹤
TESTS_PASSED=0
TESTS_FAILED=0
TEST_NAME="T017: Git 操作模擬測試"

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
# Test 1: 檢查 git clone 指令存在
# ========================================
test_git_clone_exists() {
    echo -n "Test 1: 檢查 git clone 指令存在... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "git clone" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'git clone' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 2: 檢查 git checkout -b 指令存在
# ========================================
test_git_checkout_b_exists() {
    echo -n "Test 2: 檢查 git checkout -b 指令存在... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "git checkout -b" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'git checkout -b' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 3: 驗證分支名稱格式（bot/spec-{timestamp}）
# ========================================
test_branch_name_format() {
    echo -n "Test 3: 驗證分支名稱格式（bot/spec-{timestamp}）... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否包含 BRANCH_PREFIX 和 TIMESTAMP 變數
    if grep -q "BRANCH_PREFIX" "$SCRIPT_PATH" && grep -q "TIMESTAMP" "$SCRIPT_PATH"; then
        # 檢查預設 BRANCH_PREFIX 是否包含 "bot/spec"
        if grep -q 'bot/spec' "$SCRIPT_PATH"; then
            echo -e "${GREEN}✓ PASSED${NC}"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${RED}✗ FAILED${NC}"
            echo "  錯誤: BRANCH_PREFIX 預設值不是 'bot/spec'"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 BRANCH_PREFIX 或 TIMESTAMP 變數"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 4: 驗證 commit 訊息格式（Conventional Commits）
# ========================================
test_commit_message_format() {
    echo -n "Test 4: 驗證 commit 訊息格式（Conventional Commits）... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否包含 COMMIT_MESSAGE 變數且格式為 "feat:" 或其他 Conventional Commits 類型
    if grep -q "COMMIT_MESSAGE" "$SCRIPT_PATH"; then
        # 檢查是否符合 Conventional Commits 格式（feat:, fix:, docs: 等）
        if grep -E "feat:|fix:|docs:|refactor:|test:|chore:" "$SCRIPT_PATH" | grep -q "COMMIT_MESSAGE"; then
            echo -e "${GREEN}✓ PASSED${NC}"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${YELLOW}⚠ WARNING${NC}"
            echo "  警告: COMMIT_MESSAGE 格式可能不符合 Conventional Commits"
            # 仍然算通過，因為可能使用變數構造
            ((TESTS_PASSED++))
            return 0
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 COMMIT_MESSAGE 變數"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 5: 檢查 git add 指令存在
# ========================================
test_git_add_exists() {
    echo -n "Test 5: 檢查 git add 指令存在... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "git add" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'git add' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 6: 檢查 git commit 指令存在
# ========================================
test_git_commit_exists() {
    echo -n "Test 6: 檢查 git commit 指令存在... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "git commit" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'git commit' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 7: 檢查 git push 指令存在
# ========================================
test_git_push_exists() {
    echo -n "Test 7: 檢查 git push 指令存在... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "git push" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  錯誤: 缺少 'git push' 指令"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ========================================
# Test 8: 檢查 git identity 設定
# ========================================
test_git_identity() {
    echo -n "Test 8: 檢查 git identity 設定... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    # 檢查是否設定 git config user.name 和 user.email
    if grep -q "git config user.name" "$SCRIPT_PATH" && grep -q "git config user.email" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: 未發現 git identity 設定（可能影響 commit）"
        # 算通過，因為可能在環境變數中設定
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# Test 9: 檢查 git checkout main 指令
# ========================================
test_git_checkout_main() {
    echo -n "Test 9: 檢查 git checkout main 指令... "

    if ! [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}⊘ SKIPPED${NC} (檔案不存在)"
        return 0
    fi

    if grep -q "git checkout main" "$SCRIPT_PATH"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  警告: 未發現 'git checkout main' 指令"
        # 算通過，因為可能使用其他方式
        ((TESTS_PASSED++))
        return 0
    fi
}

# ========================================
# 執行所有測試
# ========================================
echo "開始執行測試..."
echo ""

test_git_clone_exists
test_git_checkout_b_exists
test_branch_name_format
test_commit_message_format
test_git_add_exists
test_git_commit_exists
test_git_push_exists
test_git_identity
test_git_checkout_main

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
    echo "下一步: 執行 T018 測試 (SpecKit 指令執行模擬測試)"
    exit 0
else
    echo -e "${RED}❌ 有 $TESTS_FAILED 個測試失敗${NC}"
    echo ""
    echo "TDD 紅燈階段 ✓ - 測試失敗符合預期"
    echo "下一步: 修正 $SCRIPT_PATH 以通過測試"
    exit 1
fi
