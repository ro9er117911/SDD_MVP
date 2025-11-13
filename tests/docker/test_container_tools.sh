#!/usr/bin/env bash
# T002: 容器工具安裝驗證測試
# 驗證 Claude CLI, SpecKit CLI, Git, GitHub CLI, mermaid-cli 已安裝

set -e

echo "🧪 T002: 容器工具安裝驗證測試"
echo "====================================="

# 測試工具清單
declare -A TOOLS=(
    ["claude"]="Claude CLI"
    ["git"]="Git"
    ["gh"]="GitHub CLI"
    ["mmdc"]="Mermaid CLI"
    ["node"]="Node.js"
    ["python3"]="Python 3"
    ["uv"]="uv (Python 套件管理)"
)

FAILED=0

for cmd in "${!TOOLS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        version=$("$cmd" --version 2>&1 | head -1)
        echo "✅ ${TOOLS[$cmd]} 已安裝: $version"
    else
        echo "❌ 失敗: ${TOOLS[$cmd]} 未安裝"
        FAILED=1
    fi
done

# 特別檢查 SpecKit（通過 Claude CLI 執行）
if command -v claude &> /dev/null; then
    echo "檢查 SpecKit CLI 可用性..."
    # 這裡先假設 SpecKit 透過 Claude CLI 的 .claude/commands/ 提供
    if [ -d "/workspace/.claude/commands" ] || [ -d ".claude/commands" ]; then
        echo "✅ SpecKit CLI 配置目錄存在"
    else
        echo "⚠️  警告: SpecKit 配置目錄未找到"
    fi
else
    echo "❌ 失敗: 無法檢查 SpecKit（Claude CLI 未安裝）"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo "✅ T002 測試通過：所有工具已正確安裝"
    exit 0
else
    echo "❌ T002 測試失敗：部分工具未安裝"
    exit 1
fi
