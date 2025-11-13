# 技術研究：Spec Bot 實作計畫 (GPT-5 nano + Claude CLI + SpecKit)

**Feature Branch**: `001-spec-bot-sdd-integration`
**研究日期**: 2025-11-13
**研究者**: Claude Code
**版本**: 2.0.0 (架構重構版本)

**重要更新**: 本文件已根據正確的 GPT-5 nano + Claude CLI + SpecKit 架構重新撰寫，取代舊版 Python Bot 架構。

**參考文件**: [architecture-new.md](./architecture-new.md)

---

## 決策摘要

| 技術類別 | 選擇 | 理由（一句話） |
|---------|------|--------------|
| **Slack Bot 層** | GPT-5 nano API | 直接作為 Prompt Bot，無需自建 Python Bot |
| **Agent 執行層** | Claude CLI | 官方 Agent 工具，支援 SpecKit 指令與文件操作 |
| **SDD 生成框架** | GitHub SpecKit CLI | 官方 SDD 框架，提供 `/speckit.specify`, `/speckit.plan`, `/speckit.tasks` |
| **容器基礎映像** | `node:18-slim` | Claude CLI 需 Node.js，同時安裝 Python + uv 支援 SpecKit |
| **通訊協議** | JSON 檔案 (brd_analysis.json) | 簡單可靠，避免自定義協議複雜度 |
| **Mermaid 驗證** | mermaid-cli (npm) | 官方工具，Claude CLI 執行後驗證語法 |
| **Git 操作** | Git CLI + GitHub Token | Claude CLI 直接執行 git 指令，無需 SDK wrapper |
| **錯誤重試策略** | GPT-5 nano 決策 + 容器重啟 | 分類錯誤類型，暫時性錯誤重試，永久性錯誤通知使用者 |
| **測試框架** | Contract Testing + Docker Testing | 驗證 JSON Schema + 容器整合測試 |

---

## 1. 架構模式決策

### 決策：GPT-5 nano Orchestrator + Claude CLI Agent + Docker Isolation

**核心理由**：
1. **GPT-5 nano 三重角色**：
   - **Slack Bot**: 監聽 Slack 事件 (`file_shared`, `app_mention`)，發送狀態通知
   - **Prompt Generator**: 分析 BRD 內容，提取需求，產生結構化的 `brd_analysis.json`
   - **Decision Coordinator**: 決定執行哪些 SpecKit 指令，管理 Docker 容器生命週期

2. **Claude CLI 作為 Agent**:
   - 官方 Anthropic 工具，穩定且持續更新
   - 支援執行自定義指令（如 `/speckit.*`）
   - 完全控制 `/workspace` 目錄，可執行 Git 操作

3. **Docker 隔離**：
   - 安全隔離：容器無法存取宿主機敏感資料
   - 環境一致性：所有執行環境相同
   - 生命週期管理：任務完成後自動銷毀，符合無狀態原則

**技術決策樹**：
```
問題：如何自動生成 SDD？
├─ 方案 A: Python Bot + PyGithub + OpenAI SDK ❌
│  └─ 問題：需要自建完整的 SDD 生成邏輯
│
├─ 方案 B: GitHub Actions + 自定義腳本 ❌
│  └─ 問題：無法與 Slack 即時互動，缺乏錯誤處理機制
│
└─ 方案 C: GPT-5 nano + Claude CLI + SpecKit ✅
   ├─ 優勢 1: SpecKit 提供現成的 SDD 生成框架
   ├─ 優勢 2: Claude CLI 作為 Agent 可自主決策執行步驟
   └─ 優勢 3: GPT-5 nano 負責決策協調，Claude CLI 負責執行
```

### 替代方案考量

**替代方案 1：Python Slack Bot + OpenAI SDK（舊架構）**
- **被拒絕原因**：
  - 需要自建 SDD 生成邏輯（5 個章節、Mermaid 圖表），開發成本高
  - 無法利用 SpecKit 的最佳實踐與品質檢查
  - PyGithub API 呼叫繁瑣（需多次 API 呼叫建立分支、commit、PR）

**替代方案 2：全自動 GitHub Actions**
- **被拒絕原因**：
  - 無法與 Slack 即時互動（使用者無法看到處理進度）
  - 錯誤處理困難（失敗時無法通知 Slack 使用者）
  - 缺乏 BRD 分析能力（無 GPT-5 nano 的需求提取）

**替代方案 3：自建 Agent 框架（如 LangChain + AutoGPT）**
- **被拒絕原因**：
  - 過度工程，違反 YAGNI 原則
  - Claude CLI 已提供成熟的 Agent 能力
  - 增加維護成本與系統複雜度

### 參考資源
- [Claude CLI 文件](https://www.anthropic.com/claude-code)
- [GitHub SpecKit 文件](https://github.com/github/spec-kit)
- [Architecture 說明文件](./architecture-new.md)

---

## 2. GPT-5 nano API 整合研究

### 決策：GPT-5 nano 作為 Slack Bot + Orchestrator

**核心理由**：
1. **直接監聽 Slack 事件**：GPT-5 nano API 可整合 Slack Events API，無需中間層
2. **強大的 BRD 分析能力**：
   - 自動提取功能需求 (Functional Requirements)
   - 識別非功能需求 (Non-Functional Requirements)
   - 辨識技術約束條件 (Constraints)
3. **產生結構化輸出**：直接產生 JSON 格式的 `brd_analysis.json`

**brd_analysis.json 格式設計**：
```json
{
  "correlation_id": "req-abc-123-xyz",
  "timestamp": "2025-11-13T10:30:00Z",
  "brd_metadata": {
    "file_name": "new_feature_BRD.md",
    "file_size_bytes": 45678,
    "slack_channel": "C01ABC123",
    "slack_user": "U01XYZ789"
  },
  "brd_content": "... 完整 BRD Markdown 內容 ...",
  "analysis": {
    "functional_requirements": [
      {
        "id": "FR-001",
        "description": "PM 可透過 Slack 上傳 BRD 觸發自動化流程",
        "priority": "P1"
      },
      {
        "id": "FR-002",
        "description": "系統自動產生 spec.md, plan.md, tasks.md",
        "priority": "P1"
      }
    ],
    "non_functional_requirements": [
      {
        "category": "Performance",
        "requirement": "處理時間 < 5 分鐘"
      },
      {
        "category": "Quality",
        "requirement": "測試覆蓋率 ≥ 80%"
      }
    ],
    "constraints": [
      "使用 Docker 隔離執行環境",
      "所有操作需結構化日誌記錄",
      "繁體中文 SDD"
    ],
    "suggested_architecture": {
      "system_type": "Backend Service",
      "deployment": "Docker Container",
      "data_storage": "GitHub Repository"
    }
  },
  "speckit_commands": [
    "/speckit.specify",
    "/speckit.plan",
    "/speckit.tasks --mode tdd --no-parallel"
  ],
  "execution_context": {
    "github_repo": "your-org/spec-bot",
    "target_branch": "main",
    "feature_branch_prefix": "bot/spec"
  }
}
```

**JSON Schema 驗證**：
- 定義於 `contracts/brd_analysis_schema.json`
- 在 Docker 容器啟動前驗證格式正確性
- 防止格式錯誤導致 Claude CLI 執行失敗

### Slack Events API 整合

**關鍵事件**：
1. **`file_shared`**: 偵測 BRD 上傳
2. **`app_mention`**: 偵測 `@Spec Bot` mention

**處理流程**：
```
Slack Event → GPT-5 nano API
│
├─ 驗證檔案格式 (.md)
├─ 驗證檔案大小 (≤ 100 KB)
├─ 檢查 mention 內容 ("請生成 SDD")
│
├─ 分析 BRD 內容 → 產生 brd_analysis.json
├─ 回應 Slack: "✅ 已收到 BRD，開始處理"
│
└─ 啟動 Docker 容器
```

**錯誤處理**：
- 檔案格式錯誤 → Slack 通知: "❌ 檔案格式錯誤，請上傳 .md 格式"
- 檔案過大 → Slack 通知: "❌ 檔案過大（上限 100 KB）"
- BRD 內容解析失敗 → Slack 通知: "❌ BRD 格式錯誤：缺少『需求概述』章節"

### GPT-5 nano Prompt 設計

**System Prompt（防 Prompt Injection）**：
```
你是 Spec Bot 的 BRD 分析專家。你的職責是：
1. 分析使用者上傳的 BRD Markdown 文件
2. 提取功能需求、非功能需求與技術約束
3. 產生結構化的 JSON 格式輸出（brd_analysis.json）
4. 建議適合的 SpecKit 指令

**限制**：
- 只分析 BRD 內容，不執行任何程式碼
- 不修改檔案系統或發送網路請求
- 輸出必須是有效的 JSON 格式
- 不回應與 BRD 分析無關的問題
```

**User Prompt（結構化輸出）**：
```
請分析以下 BRD 文件，並產生 brd_analysis.json：

# BRD 內容
{brd_markdown_content}

# 輸出格式
請嚴格按照以下 JSON Schema 輸出：
{brd_analysis_schema}

# 注意事項
- correlation_id 使用 "req-{timestamp}-{random}"
- 提取所有功能需求並編號 (FR-001, FR-002, ...)
- 識別效能、安全性、可靠性等非功能需求
- 建議執行 /speckit.specify, /speckit.plan, /speckit.tasks
```

### 參考資源
- [GPT-5 nano API 文件](待確認)
- [Slack Events API 文件](https://api.slack.com/events-api)
- [JSON Schema 規範](https://json-schema.org/)

---

## 3. Claude CLI 與 SpecKit 整合研究

### 決策：Claude CLI 執行 SpecKit 指令

**核心理由**：
1. **Claude CLI 原生支援自定義指令**：可執行 `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`
2. **完全控制檔案系統**：可在 `/workspace` 目錄自由修改文件
3. **Git 操作能力**：可執行 `git add`, `git commit`, `git push`, `gh pr create`

**安裝方式**：
```bash
# 在 Docker 容器內
npm install -g @anthropic-ai/claude-code

# 驗證安裝
claude-cli --version
```

**SpecKit CLI 安裝**：
```bash
# 安裝 uv (Python 套件管理工具)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 安裝 SpecKit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 驗證安裝
specify --version
```

**SpecKit 指令集**：

| 指令 | 輸入 | 輸出 | 說明 |
|------|------|------|------|
| `/speckit.specify` | brd_analysis.json | `spec.md` | 產生功能規格書 |
| `/speckit.clarify` | `spec.md` | 澄清問題清單 | 識別模糊需求 |
| `/speckit.plan` | `spec.md` | `plan.md` | 產生實作計畫 |
| `/speckit.tasks` | `plan.md` | `tasks.md` | 產生任務清單 |

**Claude CLI 執行範例**：
```bash
#!/bin/bash
# 在 Docker 容器內執行

# 1. 讀取輸入
CORRELATION_ID=$(cat /input/brd_analysis.json | jq -r '.correlation_id')

# 2. 初始化 Git
cd /workspace
git clone https://github.com/${GITHUB_REPO}.git .
git checkout -b "bot/spec-$(date +%s)"

# 3. 執行 SpecKit 指令（由 Claude CLI 協調）
claude-cli execute "/speckit.specify --input /input/brd_analysis.json"
claude-cli execute "/speckit.plan"
claude-cli execute "/speckit.tasks --mode tdd --no-parallel"

# 4. Git 操作
git add specs/
git commit -m "feat: 新增 Spec Bot SDD 文件"
git push origin HEAD

# 5. 建立 PR
PR_URL=$(gh pr create --title "feat: 新增 Spec Bot SDD 文件" --body "..." | grep -oP 'https://.*')

# 6. 輸出結果
cat > /output/result.json <<EOF
{
  "correlation_id": "$CORRELATION_ID",
  "status": "success",
  "pr_url": "$PR_URL"
}
EOF
```

### Claude CLI 與 SpecKit 的互動模式

**問題**：Claude CLI 如何知道執行哪些 SpecKit 指令？

**解答**：由 GPT-5 nano 在 `brd_analysis.json` 的 `speckit_commands` 欄位指定：
```json
{
  "speckit_commands": [
    "/speckit.specify",
    "/speckit.plan",
    "/speckit.tasks --mode tdd --no-parallel"
  ]
}
```

Claude CLI 讀取此欄位後依序執行。

**問題**：Claude CLI 如何傳遞 BRD 分析結果給 SpecKit？

**解答**：`/speckit.specify` 指令接受 `--input` 參數：
```bash
/speckit.specify --input /input/brd_analysis.json
```

SpecKit 讀取 JSON 中的 `brd_content` 與 `analysis` 欄位產生 `spec.md`。

### 錯誤處理

**SpecKit 執行失敗**：
- Claude CLI 捕捉錯誤訊息
- 寫入 `/output/result.json`:
  ```json
  {
    "correlation_id": "req-abc-123",
    "status": "error",
    "error_type": "SPECKIT_EXECUTION_ERROR",
    "error_message": "/speckit.specify failed: ..."
  }
  ```
- GPT-5 nano 讀取後通知 Slack 使用者

**Git 操作失敗**：
- 檢查 GITHUB_TOKEN 是否有效
- 檢查分支是否已存在
- 回傳錯誤與疑難排解步驟

### 參考資源
- [Claude CLI GitHub](https://github.com/anthropics/claude-code)
- [SpecKit CLI 文件](https://github.com/github/spec-kit)
- [GitHub CLI (gh) 文件](https://cli.github.com/)

---

## 4. Docker 容器設計研究

### 決策：node:18-slim + Claude CLI + SpecKit CLI

**核心理由**：
1. **Claude CLI 需 Node.js**: 官方建議 Node.js 18+
2. **SpecKit CLI 需 Python + uv**: 在同一容器安裝 Python 3.11
3. **資源限制**: CPU 2 核心，記憶體 4GB，符合 FR-018

**Dockerfile 設計**：
```dockerfile
FROM node:18-slim

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    git \
    python3.11 \
    python3-pip \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 安裝 uv (Python 套件管理工具)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# 安裝 Claude CLI
RUN npm install -g @anthropic-ai/claude-code

# 安裝 SpecKit CLI
RUN uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 安裝 Mermaid CLI (圖表驗證)
RUN npm install -g @mermaid-js/mermaid-cli

# 安裝 GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y

# 建立非 root 使用者
RUN useradd -m -u 1000 specbot
USER specbot
WORKDIR /workspace

# 容器入口點
CMD ["bash"]
```

**docker-compose.yml 設計**：
```yaml
version: '3.8'

services:
  spec-bot-worker:
    build:
      context: .
      dockerfile: docker/spec-bot-sandbox/Dockerfile
    container_name: spec-bot-worker-${CORRELATION_ID}

    # 資源限制 (FR-018)
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G

    # 掛載點
    volumes:
      - ./input:/input:ro              # 唯讀輸入
      - ./output:/output:rw             # 可寫輸出
      - ./workspace:/workspace:rw       # Git 工作區

    # 環境變數 (FR-039)
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - CORRELATION_ID=${CORRELATION_ID}
      - LOG_LEVEL=INFO

    # 網路隔離
    networks:
      - spec-bot-net

    # 生命週期 (FR-017)
    restart: "no"
    stop_grace_period: 30s

networks:
  spec-bot-net:
    driver: bridge
```

### 容器生命週期管理

**啟動流程**：
```python
# GPT-5 nano 協調層（偽代碼）
import docker

client = docker.from_env()

# 1. 建立輸入目錄
os.makedirs(f"/tmp/{correlation_id}/input", exist_ok=True)
with open(f"/tmp/{correlation_id}/input/brd_analysis.json", "w") as f:
    json.dump(brd_analysis, f)

# 2. 啟動容器
container = client.containers.run(
    image="spec-bot-sandbox:latest",
    name=f"spec-bot-worker-{correlation_id}",
    volumes={
        f"/tmp/{correlation_id}/input": {"bind": "/input", "mode": "ro"},
        f"/tmp/{correlation_id}/output": {"bind": "/output", "mode": "rw"},
        f"/tmp/{correlation_id}/workspace": {"bind": "/workspace", "mode": "rw"}
    },
    environment={
        "GITHUB_TOKEN": os.environ["GITHUB_TOKEN"],
        "ANTHROPIC_API_KEY": os.environ["ANTHROPIC_API_KEY"],
        "CORRELATION_ID": correlation_id
    },
    detach=True,
    mem_limit="4g",
    cpu_count=2
)

# 3. 監控執行（逾時 10 分鐘，FR-017）
container.wait(timeout=600)

# 4. 收集輸出
with open(f"/tmp/{correlation_id}/output/result.json") as f:
    result = json.load(f)

# 5. 清理容器
container.remove()
shutil.rmtree(f"/tmp/{correlation_id}")
```

### 安全性設計

**白名單指令 (FR-019)**：
```bash
# 允許執行的指令
ALLOWED_COMMANDS=(
    claude-cli
    /speckit.specify
    /speckit.plan
    /speckit.tasks
    git
    gh
    bash
    node
    npm
    python3
    uv
    mmdc      # mermaid-cli
    curl
    mkdir
    cp
    mv
    rm
    jq
)

# 禁止執行的指令
FORBIDDEN_COMMANDS=(
    apt
    yum
    gcc
    javac
    nmap
    nc
    telnet
)
```

**網路隔離**：
- Docker 網路僅允許存取白名單 API（Slack, GitHub, Anthropic）
- 使用 iptables 規則限制出站連線

**Secrets 管理 (FR-039)**：
- GITHUB_TOKEN 與 ANTHROPIC_API_KEY 透過環境變數注入
- 日誌中使用 `[REDACTED]` 遮罩 secrets

### 參考資源
- [Docker SDK for Python](https://docker-py.readthedocs.io/)
- [Docker Compose 文件](https://docs.docker.com/compose/)
- [Docker 安全最佳實踐](https://docs.docker.com/engine/security/)

---

## 5. 通訊協議設計研究

### 決策：JSON 檔案 (brd_analysis.json & result.json)

**核心理由**：
1. **簡單可靠**: 避免自定義協議的複雜度
2. **易於驗證**: 使用 JSON Schema 驗證格式
3. **人類可讀**: 便於除錯與日誌追蹤

**輸入格式: brd_analysis.json**
- 位置: `/input/brd_analysis.json`
- 權限: 唯讀 (ro)
- Schema: `contracts/brd_analysis_schema.json`

**輸出格式: result.json**
- 位置: `/output/result.json`
- 權限: 讀寫 (rw)
- Schema: `contracts/result_schema.json`

**result.json 範例**：
```json
{
  "correlation_id": "req-abc-123-xyz",
  "status": "success",
  "execution_time_seconds": 142,
  "outputs": {
    "spec_md": {
      "path": "specs/001-spec-bot-sdd-integration/spec.md",
      "size_bytes": 15234,
      "checksum": "sha256:abc123..."
    },
    "plan_md": {
      "path": "specs/001-spec-bot-sdd-integration/plan.md",
      "size_bytes": 28901,
      "checksum": "sha256:def456..."
    },
    "tasks_md": {
      "path": "specs/001-spec-bot-sdd-integration/tasks.md",
      "size_bytes": 12456,
      "checksum": "sha256:ghi789..."
    }
  },
  "git_operations": {
    "branch": "bot/spec-1731491400",
    "commit_sha": "a1b2c3d4e5f6",
    "commit_message": "feat: 新增 Spec Bot SDD 文件",
    "push_status": "success",
    "pr_url": "https://github.com/your-org/spec-bot/pull/123"
  },
  "logs": [
    {"level": "INFO", "message": "開始執行 /speckit.specify", "timestamp": "2025-11-13T10:30:05Z"},
    {"level": "INFO", "message": "spec.md 產生完成", "timestamp": "2025-11-13T10:31:20Z"}
  ]
}
```

### 錯誤格式

```json
{
  "correlation_id": "req-abc-123-xyz",
  "status": "error",
  "error_type": "SPECKIT_EXECUTION_ERROR",
  "error_message": "/speckit.specify failed: Missing 'functional_requirements' in input",
  "stack_trace": "...",
  "execution_time_seconds": 45,
  "logs": [...]
}
```

### JSON Schema 驗證

**contracts/brd_analysis_schema.json**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["correlation_id", "timestamp", "brd_content", "analysis", "speckit_commands"],
  "properties": {
    "correlation_id": {
      "type": "string",
      "pattern": "^req-[a-zA-Z0-9-]+$"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time"
    },
    "brd_content": {
      "type": "string",
      "minLength": 100,
      "maxLength": 102400
    },
    "analysis": {
      "type": "object",
      "required": ["functional_requirements", "non_functional_requirements", "constraints"],
      "properties": {
        "functional_requirements": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["id", "description", "priority"],
            "properties": {
              "id": {"type": "string", "pattern": "^FR-\\d{3}$"},
              "description": {"type": "string"},
              "priority": {"enum": ["P1", "P2", "P3"]}
            }
          }
        }
      }
    },
    "speckit_commands": {
      "type": "array",
      "items": {"type": "string"}
    }
  }
}
```

### 參考資源
- [JSON Schema 官方文件](https://json-schema.org/)
- [AJV JSON Schema Validator](https://ajv.js.org/)

---

## 6. Mermaid 圖表驗證研究

### 決策：mermaid-cli (mmdc)

**核心理由**：
1. **官方工具**: Mermaid.js 官方 CLI 工具
2. **語法驗證準確**: 支援所有 Mermaid 語法（graph, sequenceDiagram, erDiagram, C4）
3. **Docker 容器內一次性執行**: 無需外部服務

**安裝方式**：
```bash
npm install -g @mermaid-js/mermaid-cli
```

**驗證範例**：
```bash
# Claude CLI 執行 SpecKit 後自動驗證
for mermaid_file in specs/001-*/diagrams/*.mermaid; do
    echo "驗證 $mermaid_file"
    mmdc -i "$mermaid_file" -o /tmp/test.png
    if [ $? -ne 0 ]; then
        echo "❌ Mermaid 語法錯誤: $mermaid_file"
        exit 1
    fi
done
```

**錯誤處理**：
- 語法錯誤 → 記錄到 result.json 的 `logs` 欄位
- 自動重試一次（使用更明確的 SpecKit prompt）
- 仍失敗 → 回傳錯誤給 GPT-5 nano，通知 Slack 使用者

### 參考資源
- [Mermaid CLI 文件](https://github.com/mermaid-js/mermaid-cli)
- [Mermaid 語法文件](https://mermaid.js.org/)

---

## 7. 錯誤處理策略研究

### 決策：分類處理 + 指數退避重試

**錯誤分類**：

| 錯誤類型 | 範例 | 處理策略 |
|---------|------|---------|
| **暫時性錯誤** | GPT-5 nano API rate limit, GitHub API 503 | 指數退避重試（1s, 2s, 4s） |
| **輸入錯誤** | BRD 格式錯誤, 檔案過大 | 立即通知使用者，提供修正建議 |
| **執行錯誤** | SpecKit 執行失敗, Git 操作失敗 | 記錄日誌，通知使用者，提供疑難排解步驟 |
| **權限錯誤** | GITHUB_TOKEN 無效, Docker 容器無法啟動 | 通知管理員，檢查環境配置 |

**重試邏輯（偽代碼）**：
```python
def execute_with_retry(func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return func()
        except TemporaryError as e:
            wait_time = 2 ** attempt  # 1s, 2s, 4s
            logger.warning(f"Retry {attempt + 1}/{max_retries} after {wait_time}s: {e}")
            time.sleep(wait_time)
        except PermanentError as e:
            logger.error(f"Permanent error: {e}")
            notify_user(error=e, troubleshooting_steps=get_troubleshooting(e))
            raise
    raise MaxRetriesExceeded()
```

**Slack 錯誤通知格式**：
```
❌ 錯誤：SPECKIT_EXECUTION_ERROR
時間：2025-11-13 10:35:42
說明：/speckit.specify 執行失敗

疑難排解步驟：
1. 檢查 BRD 是否包含所有必要章節
2. 查看詳細日誌：[點此查看]
3. 若問題持續，請聯繫管理員

[🔄 重試] [📋 查看日誌]
```

### 參考資源
- [指數退避演算法](https://en.wikipedia.org/wiki/Exponential_backoff)
- [Slack 互動式訊息](https://api.slack.com/messaging/interactivity)

---

## 8. 測試策略研究

### 決策：Contract Testing + Docker Testing + E2E Testing

**測試金字塔**：
```
      /\
     /  \  E2E (5%): 完整流程測試
    /____\
   /      \  Integration (25%): Docker 容器測試
  /________\
 /          \  Unit (70%): Contract Testing + 邏輯驗證
/____________\
```

**Contract Testing（70%）**：
- 驗證 brd_analysis.json 符合 JSON Schema
- 驗證 result.json 符合 JSON Schema
- 驗證 Slack Events payload 格式
- 驗證 GitHub API 請求格式

**測試工具**：
```bash
# JSON Schema 驗證
npm install -g ajv-cli
ajv validate -s contracts/brd_analysis_schema.json -d tests/fixtures/brd_analysis_sample.json
```

**Docker 整合測試（25%）**：
- 測試容器啟動與銷毀
- 測試檔案掛載 (/input, /output, /workspace)
- 測試環境變數注入
- 測試資源限制（CPU, Memory）

**測試工具**：
```python
import docker
import pytest

@pytest.fixture
def docker_client():
    return docker.from_env()

def test_container_execution(docker_client):
    container = docker_client.containers.run(
        image="spec-bot-sandbox:test",
        volumes={
            "/tmp/test/input": {"bind": "/input", "mode": "ro"},
            "/tmp/test/output": {"bind": "/output", "mode": "rw"}
        },
        detach=True
    )

    # 等待執行完成
    result = container.wait(timeout=600)

    # 驗證輸出
    assert os.path.exists("/tmp/test/output/result.json")

    # 清理
    container.remove()
```

**E2E 測試（5%）**：
- 模擬 Slack 上傳 BRD → 驗證 GitHub PR 產出
- 驗證 PR 包含所有必要檔案（spec.md, plan.md, tasks.md）
- 驗證 Mermaid 圖表語法正確
- 驗證 Slack 通知訊息格式

### 測試覆蓋率目標
- **整體覆蓋率**: ≥ 80%
- **關鍵路徑覆蓋率**: 100%（BRD 分析 → Docker 執行 → GitHub PR）
- **錯誤處理覆蓋率**: ≥ 90%

### 參考資源
- [JSON Schema Validator](https://www.npmjs.com/package/ajv)
- [Docker SDK for Python](https://docker-py.readthedocs.io/)
- [Pytest Docker Plugin](https://pypi.org/project/pytest-docker/)

---

## 9. 日誌與監控研究

### 決策：結構化 JSON 日誌 + correlation_id 追蹤

**日誌格式**：
```json
{
  "timestamp": "2025-11-13T10:30:00Z",
  "level": "INFO",
  "correlation_id": "req-abc-123-xyz",
  "component": "docker-manager",
  "message": "Container started successfully",
  "context": {
    "container_id": "a1b2c3d4",
    "branch_name": "bot/spec-1731491400",
    "brd_file_name": "new_feature_BRD.md"
  }
}
```

**correlation_id 追蹤流程**：
```
1. GPT-5 nano 產生 correlation_id: "req-abc-123-xyz"
2. 寫入 brd_analysis.json
3. Docker 容器讀取 correlation_id
4. Claude CLI 在所有日誌中包含 correlation_id
5. result.json 回傳相同 correlation_id
6. GPT-5 nano 使用 correlation_id 追蹤整個流程
```

**關鍵指標監控**：
- Docker 容器啟動成功率
- Claude CLI 執行成功率
- GitHub PR 建立成功率
- 平均處理時間（P50, P95, P99）
- 佇列長度（即時監控）
- 錯誤類型分布

### 參考資源
- [Structured Logging Best Practices](https://www.elastic.co/guide/en/ecs/current/index.html)
- [Correlation ID Pattern](https://microservices.io/patterns/observability/distributed-tracing.html)

---

## 10. 佇列管理研究

### 決策：簡單 FIFO 佇列 + Redis（可選）

**核心理由**：
1. **無狀態原則**: 佇列狀態存於記憶體，容器重啟後清空
2. **簡單實作**: 使用 Python `asyncio.Queue` 或 Redis List
3. **並行限制**: 最多 5 個 Docker 容器並行執行（FR-005a）

**FIFO 佇列實作（偽代碼）**：
```python
import asyncio
from typing import Dict, List

class RequestQueue:
    def __init__(self, max_concurrent=5, max_queue_size=10):
        self.queue = asyncio.Queue(maxsize=max_queue_size)
        self.max_concurrent = max_concurrent
        self.running_tasks = {}  # correlation_id -> Task

    async def enqueue(self, brd_analysis: Dict):
        if self.queue.full():
            raise QueueFullError("佇列已滿（10/10），請 10 分鐘後再試")

        await self.queue.put(brd_analysis)
        position = self.queue.qsize()
        estimated_wait = position * 180  # 假設每個請求 3 分鐘

        return {
            "position": position,
            "estimated_wait_seconds": estimated_wait
        }

    async def process_queue(self):
        while True:
            if len(self.running_tasks) < self.max_concurrent:
                brd_analysis = await self.queue.get()
                task = asyncio.create_task(
                    self.execute_docker_container(brd_analysis)
                )
                self.running_tasks[brd_analysis["correlation_id"]] = task
            else:
                await asyncio.sleep(5)  # 等待空閒
```

**佇列狀態通知**：
```
⏸ 目前有 5 個請求處理中
您的請求排在第 3 位
預計等待 9 分鐘

進度：
✅ req-001 (已完成)
⏳ req-002 (處理中)
⏳ req-003 (處理中)
⏳ req-004 (處理中)
⏳ req-005 (處理中)
⏳ req-006 (處理中)
⏸ req-007 (佇列中，第 1 位)
⏸ req-008 (佇列中，第 2 位)
⏸ req-009 (佇列中，第 3 位) ← 您的請求
```

### Redis 持久化（可選）

**使用情境**: 如果需要跨容器共享佇列狀態

```python
import redis

redis_client = redis.Redis(host='localhost', port=6379)

def enqueue_to_redis(brd_analysis):
    redis_client.rpush("spec_bot_queue", json.dumps(brd_analysis))

def dequeue_from_redis():
    data = redis_client.lpop("spec_bot_queue")
    return json.loads(data) if data else None
```

### 參考資源
- [Python asyncio Queue](https://docs.python.org/3/library/asyncio-queue.html)
- [Redis Lists](https://redis.io/docs/data-types/lists/)

---

## 總結與下一步

### 已完成的技術決策

✅ **架構模式**: GPT-5 nano Orchestrator + Claude CLI Agent + Docker Isolation
✅ **核心技術**: GPT-5 nano API, Claude CLI, SpecKit CLI, Docker
✅ **通訊協議**: JSON 檔案 (brd_analysis.json, result.json)
✅ **容器設計**: node:18-slim + Claude CLI + SpecKit CLI + Git
✅ **測試策略**: Contract Testing + Docker Testing + E2E Testing
✅ **錯誤處理**: 分類處理 + 指數退避重試
✅ **日誌追蹤**: 結構化 JSON 日誌 + correlation_id

### 待確認項目

⏳ **GPT-5 nano API 存取方式**: 待確認 API 端點與認證方式
⏳ **Claude CLI 在 Docker 內的執行細節**: 待實際測試驗證
⏳ **SpecKit CLI 與 Claude CLI 整合方式**: 待測試 `/speckit.*` 指令執行
⏳ **GitHub Token 注入方式**: 待驗證環境變數安全性

### 下一步行動

1. **Phase 1**: 撰寫 `data-model.md`（架構圖與流程圖）
2. **Phase 1**: 撰寫 `quickstart.md`（開發環境設定指南）
3. **Phase 1**: 定義 `contracts/*.json`（JSON Schema）
4. **Phase 2**: 產生 `tasks.md`（由 `/speckit.tasks` 指令）
5. **Phase 3**: 開始實作 Dockerfile 與測試

---

**文件狀態**: ✅ Phase 0 研究完成
**下一步**: Phase 1 設計 → 產生 data-model.md, quickstart.md, contracts/
**負責人**: [填寫技術負責人]
**審核者**: [填寫審核者]
