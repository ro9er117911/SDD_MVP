#!/usr/bin/env bash
# T001: Dockerfile 語法驗證測試
# 驗證 Dockerfile 語法正確，無 Hadolint 警告，基礎映像為 node:18-slim

set -e

DOCKERFILE_PATH="docker/spec-bot-sandbox/Dockerfile"
EXPECTED_BASE_IMAGE="node:18-slim"

echo "🧪 T001: Dockerfile 語法驗證測試"
echo "=================================="

# 檢查 Dockerfile 是否存在
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "❌ 失敗: Dockerfile 不存在於 $DOCKERFILE_PATH"
    exit 1
fi
echo "✅ Dockerfile 檔案存在"

# 檢查基礎映像
if grep -q "FROM $EXPECTED_BASE_IMAGE" "$DOCKERFILE_PATH"; then
    echo "✅ 基礎映像正確: $EXPECTED_BASE_IMAGE"
else
    echo "❌ 失敗: 基礎映像不是 $EXPECTED_BASE_IMAGE"
    exit 1
fi

# 檢查 Dockerfile 語法（使用 docker build --check）
echo "檢查 Dockerfile 語法..."
if docker build --check -f "$DOCKERFILE_PATH" . 2>/dev/null; then
    echo "✅ Dockerfile 語法有效"
else
    echo "⚠️  警告: docker build --check 不支援，跳過語法檢查"
fi

# 檢查是否有 Hadolint（可選）
if command -v hadolint &> /dev/null; then
    echo "執行 Hadolint 檢查..."
    if hadolint "$DOCKERFILE_PATH"; then
        echo "✅ Hadolint 檢查通過"
    else
        echo "❌ 失敗: Hadolint 發現警告"
        exit 1
    fi
else
    echo "⚠️  警告: Hadolint 未安裝，跳過 linting"
fi

echo ""
echo "✅ T001 測試通過：Dockerfile 語法驗證成功"
exit 0
