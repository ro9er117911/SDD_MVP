#!/usr/bin/env bash
# T016: Claude CLI 腳本語法檢查

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_SCRIPT="$REPO_ROOT/docker/scripts/run_speckit.sh"

echo "🧪 T016: Claude CLI 腳本語法檢查"
echo "=================================="

if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo "❌ 失敗: 找不到 $TARGET_SCRIPT，請先完成 T019。"
    exit 1
fi

if [[ ! -x "$TARGET_SCRIPT" ]]; then
    echo "❌ 失敗: $TARGET_SCRIPT 必須具有可執行權限。"
    exit 1
fi

if ! bash -n "$TARGET_SCRIPT"; then
    echo "❌ 失敗: Bash 語法檢查未通過。"
    exit 1
fi
echo "✅ Bash 語法檢查通過 (bash -n)"

if ! grep -q "set -Eeuo pipefail" "$TARGET_SCRIPT"; then
    echo "❌ 失敗: 腳本必須啟用 set -Eeuo pipefail 以確保變數定義與錯誤處理。"
    exit 1
fi
echo "✅ 已啟用 set -Eeuo pipefail"

if ! grep -Eq "trap.+(handle_error|on_error)" "$TARGET_SCRIPT"; then
    echo "❌ 失敗: 未偵測到 trap 錯誤處理（handle_error/on_error），請加入統一的錯誤處理。"
    exit 1
fi
echo "✅ 發現 trap 錯誤處理"

if ! grep -q "REQUIRED_ENV_VARS=(" "$TARGET_SCRIPT"; then
    echo "❌ 失敗: 腳本必須定義 REQUIRED_ENV_VARS 確保必要變數存在。"
    exit 1
fi

if ! grep -Fq 'for var in "${REQUIRED_ENV_VARS[@]}"' "$TARGET_SCRIPT"; then
    echo "❌ 失敗: 須迴圈檢查 REQUIRED_ENV_VARS，確保所有變數皆已設定。"
    exit 1
fi
echo "✅ 所需環境變數檢查邏輯已定義"

echo ""
echo "✅ T016 測試通過：run_speckit.sh 語法與防呆規範符合要求"
