# Spec Bot Sandbox Dockerfile
# 基礎映像：Node.js 18 (用於 Claude CLI 與 SpecKit)
FROM node:18-slim

# 設定環境變數
ENV DEBIAN_FRONTEND=noninteractive \
    ANTHROPIC_API_KEY="" \
    GITHUB_TOKEN="" \
    CORRELATION_ID=""

# 安裝系統依賴
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 基本工具
    git \
    curl \
    jq \
    ca-certificates \
    gnupg \
    # Python 3.11
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# 安裝 GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Python 工具 (uv)
RUN pip3 install --no-cache-dir uv

# 安裝 Claude CLI
RUN npm install -g @anthropic-ai/claude-code

# 安裝 SpecKit CLI (透過 uv)
# 注意：這裡假設 SpecKit 可透過 Git 安裝，實際路徑需確認
# RUN uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 安裝 Mermaid CLI
RUN npm install -g @mermaid-js/mermaid-cli

# 建立非 root 使用者
RUN useradd -m -u 1000 -s /bin/bash specbot

# 設定工作目錄
WORKDIR /workspace

# 切換到非 root 使用者
USER specbot

# 預設命令
CMD ["bash"]
