#!/usr/bin/env bash
# 驗證所有 Mermaid 圖表語法

set -Eeuo pipefail

TARGET_DIR="${1:-${WORKSPACE_DIR:-/workspace}}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "⚠️  Mermaid 驗證略過：目錄不存在 ($TARGET_DIR)"
    exit 0
fi

MERMAID_FILES=()
while IFS= read -r mermaid_file; do
    MERMAID_FILES+=("$mermaid_file")
done < <(find "$TARGET_DIR" -type f -name "*.mermaid" 2>/dev/null)

if [[ "${#MERMAID_FILES[@]}" -eq 0 ]]; then
    echo "ℹ️  未找到 Mermaid 檔案，略過驗證。"
    exit 0
fi

VALIDATED_COUNT=0
for file in "${MERMAID_FILES[@]}"; do
    TEMP_OUTPUT="$(mktemp /tmp/mermaid-XXXXXX.png)"
    if mmdc -i "$file" -o "$TEMP_OUTPUT" >/dev/null 2>&1; then
        ((VALIDATED_COUNT++))
        rm -f "$TEMP_OUTPUT"
    else
        echo "❌ Mermaid 語法錯誤: $file" >&2
        exit 1
    fi
done

echo "✅ Mermaid 驗證完成：共 ${VALIDATED_COUNT} 個檔案"
