# Implementation Plan: Spec Bot - Slack/GitHub/GPT 整合的 SDD 需求對齊工具

**Branch**: `001-spec-bot-sdd-integration` | **Date**: 2025-11-13 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-spec-bot-sdd-integration/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

本專案旨在開發一個自動化工具，透過 Slack、GitHub 與 GPT-5 nano 的整合，實現 BRD (Business Requirements Document) 到 SDD (System Design Document) 的自動轉換。

**核心架構**：
- **GPT-5 nano** 作為 Slack Bot + Prompt Generator + Decision Coordinator（三重角色）
- **Claude CLI** 作為 Agent 執行 SpecKit 指令與文件操作
- **GitHub SpecKit** 提供 SDD 生成框架（/speckit.specify, /speckit.plan, /speckit.tasks）
- **Docker 容器** 提供隔離的執行環境

**核心流程**：PM 在 Slack 上傳 BRD → GPT-5 nano 分析並產生 brd_analysis.json → Docker 容器啟動 → Claude CLI 執行 SpecKit 指令生成 SDD → 提交 GitHub PR → SA/Architect 審核 → 合併後自動產出多格式交付物。

系統強調無狀態設計、沙箱隔離、測試驅動開發與完整可追溯性。

**參考文件**: [architecture-new.md](./architecture-new.md)

## Technical Context

**架構模式**: GPT-5 nano Orchestrator + Claude CLI Agent + Docker Isolation

**核心技術堆疊**:
- **GPT-5 nano API**: BRD 分析、需求提取、Prompt 生成與決策協調
- **Claude CLI**: `@anthropic-ai/claude-code` (Agent 執行層)
- **SpecKit CLI**: `specify-cli` from GitHub (SDD 生成框架)
- **Docker**: 容器隔離與資源管理
- **Git**: 版本控制與 GitHub 操作

**Primary Dependencies**:
- **GPT-5 nano API**: 決策協調層
  - Slack Events API 整合
  - BRD 內容分析
  - brd_analysis.json 生成

- **Claude CLI** (`@anthropic-ai/claude-code` via npm):
  - Agent 執行 SpecKit 指令
  - 文件修改與 Git 操作
  - 完全控制 `/workspace` 目錄

- **SpecKit CLI** (`specify-cli` via uv tool):
  - `/speckit.specify` - 產生 spec.md
  - `/speckit.plan` - 產生 plan.md
  - `/speckit.tasks` - 產生 tasks.md
  - 安裝方式: `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`

- **Docker** (`docker` via system package):
  - 容器生命週期管理
  - 資源限制 (CPU, Memory)
  - 網路隔離與白名單

- **Node.js** (18+):
  - Claude CLI 執行環境
  - mermaid-cli 圖表驗證

- **Python** (3.11+):
  - SpecKit CLI 依賴
  - uv 套件管理工具

**Storage**:
- **GitHub Repository** (唯一權威事實來源，儲存所有 SDD 產出)
- **Docker 容器檔案系統**:
  - `/input/brd_analysis.json` (GPT-5 nano 輸入)
  - `/output/result.json` (Claude CLI 輸出)
  - `/workspace` (Git 工作區，Claude CLI 完全控制)
- **無持久化資料庫** (Bot 完全無狀態)

**Testing**:
- **整合測試**: 測試 GPT-5 nano → Docker → Claude CLI → GitHub 完整流程
- **端到端測試**: 模擬 Slack 上傳 BRD → 驗證 GitHub PR 產出
- **Contract Testing**: 驗證 brd_analysis.json 與 result.json 格式
- **語法驗證測試**: mermaid-cli 驗證圖表語法
- **測試覆蓋率目標**: ≥ 80%
- **TDD 模式**: 所有功能測試先行 (NON-NEGOTIABLE)

**Target Platform**:
- **Docker 容器基礎映像**: `node:18-slim`
- **容器內工具**:
  - Claude CLI (npm install -g @anthropic-ai/claude-code)
  - SpecKit CLI (uv tool install specify-cli)
  - Git 2.30+
  - Python 3.11 + uv
  - Node.js 18+ + npm
  - mermaid-cli (@mermaid-js/mermaid-cli)
- **執行環境**: Linux 伺服器 (Docker host)

**Project Type**:
- **協調層**: GPT-5 nano (API service)
- **執行層**: Claude CLI (Agent in Docker)
- **框架層**: GitHub SpecKit (SDD 生成工具鏈)
- **無 Frontend UI**: 所有互動透過 Slack

**Performance Goals**:
- Slack 初步回應延遲 < 5 秒
- BRD 分析 (GPT-5 nano) < 30 秒
- SDD 生成 (Claude CLI + SpecKit) < 2 分鐘
- GitHub PR 建立時間 < 30 秒
- BRD → SDD 完整流程 < 3 分鐘 (P95)
- 並行處理上限: 5 個 Docker 容器
- 佇列長度上限: 10 個請求

**Constraints**:
- BRD 檔案大小 ≤ 100 KB (GPT-5 nano context window 限制)
- Docker 容器資源限制: CPU 2 核心，記憶體 4GB
- Docker 容器執行逾時: 10 分鐘
- 僅支援繁體中文 BRD 與 SDD (MVP 階段)
- 網路存取白名單: Slack API, GitHub API, Anthropic API

**Scale/Scope**:
- 初期使用者: 10-20 位 PM/SA/Architect
- 預估每日處理 BRD 數量: 5-10 個
- SDD 檔案結構: 5 個強制章節，至少 3 張 Mermaid 圖表
- GitHub Repository: 單一 monorepo，所有 SDD 儲存於 `/specs/` 目錄

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### 原則 I: 單一事實來源與狀態外部化
✅ **PASS** - 所有 SDD 產出儲存於 GitHub Repository，Bot 完全無狀態設計
- GPT-5 nano 不持久化任何狀態，所有決策基於當下輸入
- Claude CLI 在容器內操作，容器銷毀後無狀態殘留
- GitHub 為唯一權威來源

### 原則 II: Bot 輕量沙箱原則
✅ **PASS** - 所有自動化操作在 Docker 容器中執行
- 容器基礎映像: `node:18-slim`（非 Python，因 Claude CLI 需 Node.js）
- 容器內安裝: Claude CLI + SpecKit CLI + Git + Python + uv
- 任務完成或逾時後自動銷毀容器

### 原則 III: 測試驅動開發 (NON-NEGOTIABLE)
✅ **PASS** - 規格書已包含 Gherkin 格式驗收場景
- 測試覆蓋率目標 ≥ 80%
- TDD 紅-綠-重構循環強制執行
- 測試先於實作

### 原則 IV: 整合測試與模擬環境
✅ **PASS** - 已規劃完整的整合測試策略
- 模擬 GPT-5 nano API 回應（brd_analysis.json）
- 模擬 Docker 容器執行（檢查 result.json 輸出）
- 模擬 GitHub API 操作（PR 建立、commit）
- Contract Testing 驗證介面格式

### 原則 V: 簡約與需求驅動 (YAGNI)
✅ **PASS** - 使用現成工具與框架，無過度工程
- GPT-5 nano: 直接使用 API，無自建 wrapper
- Claude CLI: 官方工具，無需包裝
- SpecKit CLI: GitHub 官方框架，無需自建
- 避免自建佇列系統（使用簡單 FIFO）

### 原則 VI: 完整可追溯性與審計
✅ **PASS** - 結構化日誌與 correlation_id 追蹤
- GPT-5 nano 產生唯一 correlation_id
- brd_analysis.json 包含 correlation_id
- result.json 回傳相同 correlation_id
- 所有日誌包含 correlation_id 欄位

### 原則 VII: 語意化版本與文件同步
✅ **PASS** - Commit 訊息遵循 Conventional Commits
- Claude CLI 使用規範的 commit 格式
- PR 需審核後才能合併
- Release 使用語意化版本標籤

### 原則 VIII: 零信任與權限最小化
✅ **PASS** - 最小權限原則與 secrets 管理
- GitHub Token 使用 Fine-grained token
- 權限: contents:write, pull_requests:write, workflows:write, metadata:read
- 所有 API tokens 透過環境變數注入 Docker 容器
- 容器以非 root 使用者執行
- 日誌中不記錄 PII 或 secrets

### 原則 IX: AI 回應有據與防護
✅ **PASS** - Claude CLI 生成的 Mermaid 圖表需通過驗證
- mermaid-cli 語法驗證
- SpecKit 內建品質檢查
- GPT-5 nano Prompt Injection 防護（輸入 sanitization）
- 錯誤時提供重試機制

### 原則 X: 原生整合優先
✅ **PASS** - 使用官方工具與 SDK
- GPT-5 nano API (官方)
- Claude CLI (Anthropic 官方)
- SpecKit CLI (GitHub 官方)
- Git CLI (原生命令)

**整體評估**: ✅ 通過 - 無重大憲法違反，可進入 Phase 0 研究階段

## Project Structure

### Documentation (this feature)

```text
specs/001-spec-bot-sdd-integration/
├── spec.md              # 功能規格書 (已完成)
├── plan.md              # 本檔案 (/speckit.plan 指令輸出)
├── architecture-new.md  # GPT-5 nano + Claude CLI 架構說明 (已完成)
├── research.md          # Phase 0 輸出 (技術決策與最佳實踐研究)
├── data-model.md        # Phase 1 輸出 (實體關係圖與資料模型)
├── quickstart.md        # Phase 1 輸出 (開發環境設定指南)
├── contracts/           # Phase 1 輸出 (API 契約定義)
│   ├── slack_events.json           # Slack Event API 契約
│   ├── brd_analysis_schema.json    # GPT-5 nano → Docker 輸入格式
│   ├── result_schema.json          # Docker → GPT-5 nano 輸出格式
│   └── github_api.json             # GitHub REST API 契約
└── tasks.md             # Phase 2 輸出 (/speckit.tasks 指令 - 本指令不會建立)
```

### Docker 容器結構

**Dockerfile** (`docker/spec-bot-sandbox/Dockerfile`):
```dockerfile
FROM node:18-slim

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    git \
    python3.11 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安裝 uv (Python 套件管理工具)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# 安裝 Claude CLI
RUN npm install -g @anthropic-ai/claude-code

# 安裝 SpecKit CLI
RUN uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 安裝 mermaid-cli
RUN npm install -g @mermaid-js/mermaid-cli

# 建立非 root 使用者
RUN useradd -m -u 1000 specbot
USER specbot
WORKDIR /workspace

# 容器入口點
CMD ["bash"]
```

**docker-compose.yml** (容器編排):
```yaml
version: '3.8'

services:
  spec-bot-worker:
    build:
      context: .
      dockerfile: docker/spec-bot-sandbox/Dockerfile
    container_name: spec-bot-worker-${CORRELATION_ID}

    # 資源限制
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G

    # 掛載點
    volumes:
      - ./input:/input:ro              # GPT-5 nano 輸入（唯讀）
      - ./output:/output:rw             # Claude CLI 輸出
      - ./workspace:/workspace:rw       # Git 工作區

    # 環境變數
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - CORRELATION_ID=${CORRELATION_ID}
      - LOG_LEVEL=INFO

    # 網路隔離
    networks:
      - spec-bot-net

    # 生命週期
    restart: "no"
    stop_grace_period: 30s

networks:
  spec-bot-net:
    driver: bridge
```

### GPT-5 nano 協調層結構

**注意**: GPT-5 nano 不是傳統程式碼專案，而是 API 服務。以下為邏輯架構：

```text
GPT-5 nano Orchestration Layer (API Service)
├── Slack Events Handler
│   ├── file_shared 事件監聽
│   ├── app_mention 事件監聽
│   └── 訊息回應與狀態更新 (⏳, ✅, ❌)
├── BRD Analyzer
│   ├── BRD 內容解析
│   ├── 需求提取 (Functional, Non-Functional, Constraints)
│   ├── 關鍵字識別與分類
│   └── brd_analysis.json 生成
├── Decision Coordinator
│   ├── 決定執行哪些 SpecKit 指令
│   ├── 產生 Claude CLI Prompt
│   └── Docker 容器啟動與監控
├── Docker Manager
│   ├── 容器生命週期管理
│   ├── 環境變數注入 (GITHUB_TOKEN, ANTHROPIC_API_KEY)
│   ├── 輸入檔案掛載 (/input/brd_analysis.json)
│   └── 輸出檔案收集 (/output/result.json)
└── Result Processor
    ├── result.json 解析
    ├── GitHub PR 連結提取
    ├── Slack 通知格式化
    └── 錯誤處理與重試邏輯
```

**注意**: 實際實作方式取決於 GPT-5 nano API 的呼叫方式（可能是無伺服器函式、API Gateway、或整合平台如 Zapier）。

### Claude CLI 執行腳本

**執行範例** (`docker/scripts/run_speckit.sh`):
```bash
#!/bin/bash
# 此腳本在 Docker 容器內執行，由 Claude CLI 自主決定執行步驟

set -e  # 遇到錯誤立即停止

# 讀取輸入
CORRELATION_ID=$(cat /input/brd_analysis.json | jq -r '.correlation_id')
echo "[INFO] 開始處理請求: $CORRELATION_ID"

# 初始化 Git
cd /workspace
if [ ! -d .git ]; then
    git clone https://github.com/${GITHUB_REPO}.git .
fi

# 建立新分支
BRANCH_NAME="bot/spec-$(date +%s)"
git checkout -b "$BRANCH_NAME"

# 執行 SpecKit 指令
echo "[INFO] 執行 /speckit.specify"
claude-cli execute "/speckit.specify --input /input/brd_analysis.json"

echo "[INFO] 執行 /speckit.plan"
claude-cli execute "/speckit.plan"

echo "[INFO] 執行 /speckit.tasks"
claude-cli execute "/speckit.tasks --mode tdd --no-parallel"

# Git 操作
git add specs/
git commit -m "feat: 新增 Spec Bot SDD 文件

由 GPT-5 nano 協調，Claude CLI 產生
Correlation ID: $CORRELATION_ID"

git push origin "$BRANCH_NAME"

# 建立 Pull Request
PR_URL=$(gh pr create \
    --title "feat: 新增 Spec Bot SDD 文件" \
    --body "由 GPT-5 nano 自動產生，請審核。Correlation ID: $CORRELATION_ID" \
    --base main \
    --head "$BRANCH_NAME" | grep -oP 'https://.*')

# 輸出結果
cat > /output/result.json <<EOF
{
  "correlation_id": "$CORRELATION_ID",
  "status": "success",
  "git_operations": {
    "branch": "$BRANCH_NAME",
    "commit_sha": "$(git rev-parse HEAD)",
    "pr_url": "$PR_URL"
  }
}
EOF

echo "[INFO] 處理完成: $CORRELATION_ID"
```

## Complexity Tracking

**本專案無憲法違反項目** - 所有設計決策符合憲法原則，無需額外複雜性引入。

### 潛在複雜點監控

1. **GPT-5 nano ↔ Claude CLI 通訊協議**
   - **複雜度**: 中等
   - **引入原因**: 需要標準化格式確保可靠傳遞
   - **簡化方案**: 使用 JSON 格式 (brd_analysis.json, result.json)，避免自定義協議

2. **Docker 容器生命週期管理**
   - **複雜度**: 中等
   - **引入原因**: 需要確保資源清理與逾時處理
   - **簡化方案**: 使用 Docker SDK 原生 API，避免自建排程器

3. **Claude CLI 錯誤處理**
   - **複雜度**: 中等
   - **引入原因**: Claude CLI 可能執行失敗或逾時
   - **簡化方案**: 監控 /output/result.json，逾時則強制終止容器

---

## Phase 0: 研究與技術決策

**產出檔案**: [research.md](./research.md)

**完成日期**: 待執行

**研究範圍**:
1. ⏳ GPT-5 nano API 整合方式與 Slack Events API 串接
2. ⏳ Claude CLI 安裝與配置方式
3. ⏳ SpecKit CLI 安裝與指令使用方式
4. ⏳ Docker 容器內 Git 操作與 GitHub Token 注入
5. ⏳ brd_analysis.json 與 result.json 格式設計
6. ⏳ Mermaid 圖表驗證流程
7. ⏳ 結構化日誌與 correlation_id 追蹤
8. ⏳ FIFO 佇列實作（Docker 容器層級）

**關鍵技術決策點**:
- GPT-5 nano API 存取方式（REST API / SDK / Platform Integration）
- Claude CLI 在 Docker 內的執行方式（CLI 指令 / API 呼叫）
- SpecKit CLI 與 Claude CLI 的整合方式
- Docker 容器與宿主機的檔案交換機制（volumes, bind mounts）

---

## Phase 1: 設計與架構定義

**產出檔案**: [data-model.md](./data-model.md), [quickstart.md](./quickstart.md), `contracts/*.json`

**完成日期**: 待執行

**主要任務**:
1. 定義 brd_analysis.json 格式規範（JSON Schema）
2. 定義 result.json 格式規範（JSON Schema）
3. 設計 Docker 容器環境變數清單
4. 撰寫 Dockerfile 與 docker-compose.yml
5. 定義 Claude CLI 執行腳本範本
6. 設計 Slack Events 處理流程
7. 設計 GitHub PR 建立流程
8. 撰寫開發環境快速啟動指南

**輸出交付物**:
- `contracts/brd_analysis_schema.json` - 輸入格式 JSON Schema
- `contracts/result_schema.json` - 輸出格式 JSON Schema
- `contracts/slack_events.json` - Slack Events API 契約
- `contracts/github_api.json` - GitHub API 呼叫契約
- `data-model.md` - 架構圖與流程圖（Mermaid 格式）
- `quickstart.md` - 開發環境設定指南

---

## Phase 2: 任務分解與實作規劃

**產出檔案**: [tasks.md](./tasks.md)

**完成日期**: 待執行（由 `/speckit.tasks` 指令產生）

**任務範圍預估**:
- Phase 1: 建立 Dockerfile 與容器環境（預估 5-8 個任務）
- Phase 2: 實作 GPT-5 nano BRD 分析邏輯（預估 8-12 個任務）
- Phase 3: 實作 Docker 容器管理與生命週期（預估 10-15 個任務）
- Phase 4: 實作 Claude CLI 執行腳本與 SpecKit 整合（預估 12-18 個任務）
- Phase 5: 實作 GitHub PR 建立與通知（預估 8-12 個任務）
- Phase 6: 實作錯誤處理與日誌追蹤（預估 10-15 個任務）
- Phase 7: 整合測試與端到端驗證（預估 15-20 個任務）

**總計預估**: 68-100 個任務（依據實際複雜度調整）

---

## Phase 3-7: 實作與測試

由 `/speckit.implement` 指令執行，根據 `tasks.md` 逐步實作。

**關鍵里程碑**:
1. ✅ Dockerfile 建立完成，可成功啟動容器
2. ✅ Claude CLI 能在容器內執行 SpecKit 指令
3. ✅ GPT-5 nano 能產生有效的 brd_analysis.json
4. ✅ Claude CLI 能讀取 brd_analysis.json 並產生 SDD
5. ✅ Git 操作成功，能建立分支與 commit
6. ✅ GitHub PR 自動建立且格式正確
7. ✅ Slack 通知正確發送
8. ✅ 整合測試通過率 ≥ 95%
9. ✅ 測試覆蓋率達 ≥ 80%
10. ✅ 所有憲法檢查通過

---

## Dependencies

### 外部服務

| 服務 | 用途 | 關鍵 API/功能 |
|------|------|---------------|
| **Slack API** | 接收事件、發送通知 | Events API (`file_shared`, `app_mention`), Web API (`chat.postMessage`) |
| **GPT-5 nano API** | BRD 分析、決策協調 | （API 端點待確認） |
| **GitHub API** | 建立分支、PR、commit | REST API v3 (repos, pulls, git) |
| **Anthropic API** | Claude CLI 執行 | Claude CLI 需 ANTHROPIC_API_KEY |
| **Docker Engine** | 容器執行 | Docker SDK / CLI |

### 內部依賴

| 元件 | 依賴於 | 說明 |
|------|--------|------|
| **GPT-5 nano 協調層** | Slack API | 監聽 Slack 事件 |
| **Docker 容器** | GPT-5 nano | 接收 brd_analysis.json |
| **Claude CLI** | SpecKit CLI | 執行 /speckit.* 指令 |
| **Claude CLI** | Git + GitHub Token | 提交 commit 與建立 PR |
| **result.json** | Claude CLI | 回傳執行結果 |
| **Slack 通知** | result.json | 解析 PR URL 並通知 |

### 安裝依賴

**Docker 容器內**:
```bash
# Node.js 18+ (基礎映像)
apt-get install nodejs npm

# Claude CLI
npm install -g @anthropic-ai/claude-code

# Python + uv
apt-get install python3.11 python3-pip
curl -LsSf https://astral.sh/uv/install.sh | sh

# SpecKit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Git
apt-get install git
```

**宿主機（GPT-5 nano 協調層）**:
- 依據 GPT-5 nano API 整合方式而定（待 Phase 0 研究）
- 可能需要無伺服器平台 SDK（AWS Lambda, GCP Cloud Functions, Azure Functions）
- 或整合平台 SDK（Zapier, Make, n8n）

---

## Testing Strategy

### 測試金字塔

```
        /\
       /  \  E2E (5%)
      /____\
     /      \  Integration (25%)
    /________\
   /          \  Unit (70%)
  /____________\
```

### 測試範圍

#### 1. 單元測試（預估 70% 覆蓋）

**GPT-5 nano 協調層**:
- BRD 內容解析與驗證（檔案大小、格式、章節完整性）
- brd_analysis.json 格式驗證（JSON Schema 驗證）
- Correlation ID 產生與追蹤
- 錯誤分類與通知格式化

**Contract Testing**:
- brd_analysis.json 符合 JSON Schema
- result.json 符合 JSON Schema
- Slack Events payload 格式驗證
- GitHub API 請求格式驗證

**Mermaid 驗證**:
- mermaid-cli 語法檢查
- 圖表節點數量限制驗證

#### 2. 整合測試（預估 25% 覆蓋）

**Docker 容器執行測試**:
- 容器啟動與銷毀
- 檔案掛載 (/input, /output, /workspace)
- 環境變數注入驗證
- 資源限制驗證（CPU, Memory）

**Claude CLI 執行測試**:
- Claude CLI 能讀取 brd_analysis.json
- Claude CLI 能執行 /speckit.specify
- Claude CLI 能執行 Git 指令（add, commit, push）
- Claude CLI 能產生 result.json

**GitHub 整合測試**:
- 分支建立成功
- Commit 提交成功
- PR 建立成功
- CODEOWNERS 設定正確

#### 3. 端到端測試（預估 5% 覆蓋）

**完整流程測試**:
- 模擬 Slack 上傳 BRD → 驗證 GitHub PR 產出
- 檢查 PR 包含所有必要檔案（spec.md, plan.md, tasks.md）
- 檢查 Mermaid 圖表已產生且語法正確
- 檢查 Slack 通知訊息格式正確

**錯誤處理測試**:
- GPT-5 nano API 錯誤 → Slack 錯誤通知
- Docker 容器逾時 → 容器強制終止 + Slack 通知
- GitHub API 權限錯誤 → Slack 錯誤通知 + 疑難排解指引
- Claude CLI 執行失敗 → 日誌記錄 + Slack 通知

### 測試工具

- **Contract Testing**: JSON Schema Validator
- **Docker Testing**: testcontainers 或等效工具
- **API Mocking**: 模擬 GPT-5 nano、GitHub、Slack API 回應
- **End-to-End**: Selenium/Playwright（若需測試 Slack UI）或純 API 測試

---

## Deployment

### 環境需求

**生產環境**:
- Docker Engine 20.10+
- 支援 Docker Compose 3.8+
- 網路存取：Slack API, GitHub API, Anthropic API
- Secrets 管理：環境變數或 Docker Secrets

**環境變數清單**:
```bash
# Slack 配置
SLACK_BOT_TOKEN=xoxb-...
SLACK_SIGNING_SECRET=...

# GitHub 配置
GITHUB_TOKEN=ghp_...
GITHUB_REPO=owner/repo-name

# Anthropic 配置
ANTHROPIC_API_KEY=sk-ant-...

# GPT-5 nano 配置（待確認）
GPT5_NANO_API_KEY=...
GPT5_NANO_API_ENDPOINT=https://...

# Docker 配置
DOCKER_IMAGE=spec-bot-sandbox:latest
DOCKER_CPU_LIMIT=2
DOCKER_MEMORY_LIMIT=4g

# 日誌配置
LOG_LEVEL=INFO
LOG_FORMAT=json
```

### CI/CD Pipeline

**GitHub Actions** (`.github/workflows/ci.yml`):
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker Image
        run: docker build -f docker/spec-bot-sandbox/Dockerfile -t spec-bot-sandbox:test .

      - name: Run Contract Tests
        run: docker run --rm -v $(pwd)/contracts:/contracts spec-bot-sandbox:test bash -c "npm test"

      - name: Run Integration Tests
        run: docker run --rm -v $(pwd):/workspace spec-bot-sandbox:test bash -c "pytest tests/integration"

      - name: Check Test Coverage
        run: |
          if [ $(coverage report | grep TOTAL | awk '{print $4}' | sed 's/%//') -lt 80 ]; then
            echo "Test coverage below 80%"
            exit 1
          fi
```

---

## Monitoring & Observability

### 結構化日誌

**日誌格式** (JSON):
```json
{
  "timestamp": "2025-11-13T10:30:00Z",
  "level": "INFO",
  "correlation_id": "req-abc-123",
  "component": "docker-manager",
  "message": "Container started successfully",
  "context": {
    "container_id": "a1b2c3d4",
    "branch_name": "bot/spec-1731491400",
    "brd_file_name": "new_feature_BRD.md"
  }
}
```

### 關鍵指標

- Docker 容器啟動成功率
- Claude CLI 執行成功率
- GitHub PR 建立成功率
- 平均處理時間（P50, P95, P99）
- 佇列長度（即時監控）
- 錯誤類型分布

---

## Rollout Plan

### Phase 1: 開發環境驗證（Week 1-2）
- 建立 Dockerfile 並在本地驗證
- 測試 Claude CLI + SpecKit CLI 整合
- 撰寫單元測試與整合測試

### Phase 2: 測試環境部署（Week 3）
- 部署至測試環境
- 使用測試 Slack workspace 與 GitHub repository
- 邀請 2-3 位 PM 進行 Alpha 測試

### Phase 3: Beta 測試（Week 4）
- 擴大測試範圍至 5-10 位使用者
- 收集回饋並修正問題
- 調整 GPT-5 nano Prompt 與 Claude CLI 指令

### Phase 4: 生產環境上線（Week 5）
- 部署至生產環境
- 開放所有 PM/SA/Architect 使用
- 監控關鍵指標與錯誤率

---

## Success Metrics

- ✅ Dockerfile 建立完成且通過測試
- ✅ Claude CLI 能成功執行 SpecKit 指令
- ✅ GPT-5 nano → Claude CLI 通訊協議驗證通過
- ✅ 整合測試通過率 ≥ 95%
- ✅ 測試覆蓋率 ≥ 80%
- ✅ BRD → SDD 完整流程 < 3 分鐘（P95）
- ✅ 所有憲法檢查通過

---

## Risk Assessment

| 風險 | 嚴重性 | 可能性 | 緩解措施 |
|------|--------|--------|----------|
| **GPT-5 nano API 不可用** | 高 | 低 | 備用方案：使用 GPT-4 Turbo |
| **Claude CLI 安裝失敗** | 高 | 中 | 預先測試 Dockerfile，準備替代方案（直接呼叫 Anthropic API）|
| **SpecKit CLI 格式不符** | 中 | 中 | 研究 SpecKit 文件，撰寫適配層 |
| **Docker 容器逾時** | 中 | 中 | 實作強制終止機制，提供使用者重試選項 |
| **GitHub Token 權限不足** | 中 | 低 | 詳細文件說明 Fine-grained token 設定步驟 |
| **Mermaid 語法錯誤率高** | 低 | 中 | 實作語法驗證與自動修正機制 |

---

## 附錄：參考資料

- [Architecture 說明文件](./architecture-new.md)
- [Claude CLI 文件](https://www.anthropic.com/claude-code)
- [GitHub SpecKit 文件](https://github.com/github/spec-kit)
- [Slack Bolt for Python 文件](https://slack.dev/bolt-python/)
- [Docker SDK 文件](https://docker-py.readthedocs.io/)
- [Mermaid CLI 文件](https://github.com/mermaid-js/mermaid-cli)

---

**文件狀態**: ✅ Phase 0 前期規劃完成
**下一步**: 執行 Phase 0 研究 → 產生 research.md
**負責人**: [填寫技術負責人]
**審核者**: [填寫審核者]
