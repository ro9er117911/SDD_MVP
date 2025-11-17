#!/usr/bin/env bash
# T017: Git 操作模擬測試

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/shared.sh"

TARGET_SCRIPT="$REPO_ROOT/docker/scripts/run_speckit.sh"

echo "🧪 T017: Claude CLI 腳本 Git 操作模擬"
echo "======================================"

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

CURRENT_BRANCH="$(git -C "$WORKSPACE_DIR" branch --show-current)"
if [[ ! "$CURRENT_BRANCH" =~ ^bot/spec-[0-9]{8}-[0-9]{6}$ ]]; then
    echo "❌ 失敗: 分支名稱 $CURRENT_BRANCH 不符合 bot/spec-YYYYMMDD-HHmmss 格式。"
    exit 1
fi
echo "✅ 分支命名符合規範: $CURRENT_BRANCH"

COMMIT_SUBJECT="$(git -C "$WORKSPACE_DIR" log -1 --pretty=%s)"
if ! echo "$COMMIT_SUBJECT" | grep -Eq '^(feat|fix|docs|refactor|test|chore|build|ci|perf)(\([^)]+\))?:'; then
    echo "❌ 失敗: Commit 訊息未符合 Conventional Commits 格式: $COMMIT_SUBJECT"
    exit 1
fi
echo "✅ Commit 訊息符合 Conventional Commits: $COMMIT_SUBJECT"

if ! git --git-dir "$REMOTE_GIT_DIR" rev-parse --verify "refs/heads/$CURRENT_BRANCH" >/dev/null 2>&1; then
    echo "❌ 失敗: 遠端倉庫未建立分支 $CURRENT_BRANCH，git push 可能失敗。"
    exit 1
fi
echo "✅ 遠端倉庫已存在分支 $CURRENT_BRANCH"

RESULT_FILE="$OUTPUT_DIR/result.json"
if [[ ! -f "$RESULT_FILE" ]]; then
    echo "❌ 失敗: 未找到輸出檔案 $RESULT_FILE"
    exit 1
fi

BRANCH_IN_RESULT="$(jq -r '.git_operations.branch' "$RESULT_FILE")"
if [[ "$BRANCH_IN_RESULT" != "$CURRENT_BRANCH" ]]; then
    echo "❌ 失敗: result.json 分支資訊 ($BRANCH_IN_RESULT) 與實際分支不符 ($CURRENT_BRANCH)。"
    exit 1
fi

COMMIT_IN_RESULT="$(jq -r '.git_operations.commit_message' "$RESULT_FILE")"
if [[ "$COMMIT_IN_RESULT" != "$(git -C "$WORKSPACE_DIR" log -1 --pretty=%B)" ]]; then
    echo "❌ 失敗: result.json 中的 commit 訊息與 Git 紀錄不一致。"
    exit 1
fi

PUSH_STATUS="$(jq -r '.git_operations.push_status' "$RESULT_FILE")"
if [[ "$PUSH_STATUS" != "success" ]]; then
    echo "❌ 失敗: git_operations.push_status 應為 success，實際為 $PUSH_STATUS。"
    exit 1
fi

PR_URL="$(jq -r '.git_operations.pr_url' "$RESULT_FILE")"
if [[ -z "$PR_URL" || "$PR_URL" == "null" || "$PR_URL" != https://github.com/* ]]; then
    echo "❌ 失敗: result.json 中的 PR URL 無效：$PR_URL"
    exit 1
fi

echo "✅ git_operations 結構符合預期 (branch/commit/push/pr)"
echo ""
echo "✅ T017 測試通過：Claude CLI 腳本 Git 操作模擬成功"
