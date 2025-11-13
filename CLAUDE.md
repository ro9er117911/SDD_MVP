# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述

**Spec Bot** - Slack/GitHub/GPT 整合的 SDD 需求對齊工具

這是一個使用 SpecKit 框架開發的專案，目標是自動將 BRD (Business Requirements Document) 轉換為 SDD (System Design Document)，透過 Slack、GitHub 與 GPT 整合實現需求對齊與協作。

## 核心架構

### SpecKit 工作流程

專案遵循嚴格的規格驅動開發流程：

```
BRD → Specification → Planning → Tasks → Implementation → Validation
       (/specify)     (/plan)   (/tasks)  (/implement)
```

### 目錄結構

```
.
├── .claude/
│   └── commands/           # SpecKit 自定義指令（/speckit.*）
├── .specify/
│   ├── memory/
│   │   └── constitution.md # 專案憲法（治理規則與原則）
│   ├── scripts/bash/       # 核心自動化腳本
│   └── templates/          # 規格、計畫、任務模板
├── specs/
│   └── {###-feature-name}/ # 功能規格目錄
│       ├── spec.md         # 功能規格書
│       ├── plan.md         # 實作計畫
│       ├── tasks.md        # 任務清單
│       └── checklists/     # 品質檢查清單
└── archive/                # 歷史文件與參考資料
```

## 開發指令

### SpecKit 核心指令

**所有指令輸出必須使用繁體中文**

| 指令 | 用途 | 輸入 |
|------|------|------|
| `/speckit.constitution` | 建立/更新專案憲法 | 原則定義或參考文件 |
| `/speckit.specify` | 建立功能規格書 | 功能描述（自然語言） |
| `/speckit.clarify` | 澄清規格中的模糊項目 | 規格檔案路徑 |
| `/speckit.plan` | 產生實作計畫 | 規格檔案 |
| `/speckit.tasks` | 產生任務清單 | 計畫檔案 |
| `/speckit.implement` | 執行實作 | 任務檔案 |
| `/speckit.analyze` | 分析規格品質 | 規格目錄 |
| `/speckit.checklist` | 產生檢查清單 | 功能上下文 |

### 功能分支管理

```bash
# 建立新功能（自動執行）
.specify/scripts/bash/create-new-feature.sh --json --number N --short-name "feature-name" "功能描述"

# 輸出：
# - 分支名稱：{N}-{short-name}
# - 規格檔案：specs/{N}-{short-name}/spec.md
```

### Git 工作流程

**分支命名規則**：
- 功能分支：`{###}-{short-name}`（如 `001-spec-bot-sdd-integration`）
- Bot 自動分支：`bot/spec-{timestamp}` 或 `bot/{feature-name}`

**Commit 訊息格式**：遵循 Conventional Commits
```
feat: 新增功能描述
fix: 修正錯誤描述
docs: 文件更新描述
refactor: 重構描述
```

## 憲法核心原則

專案遵循嚴格的治理原則（詳見 `.specify/memory/constitution.md`）：

1. **單一事實來源**：GitHub 為唯一權威，Bot 完全無狀態
2. **輕量沙箱**：所有自動化操作在 Docker 容器中隔離執行
3. **測試驅動開發**：使用 Gherkin 語法，測試必須先行（NON-NEGOTIABLE）
4. **整合測試**：測試覆蓋率 ≥ 80%，模擬 Slack/GitHub/GPT API
5. **簡約與 YAGNI**：禁止過度工程，複雜性需明確記錄於 plan.md
6. **完整可追溯性**：結構化 JSON 日誌，使用 correlation_id 追蹤
7. **語意化版本**：MAJOR.MINOR.PATCH，破壞性變更需遷移指南
8. **零信任與權限最小化**：所有 API tokens 透過環境變數注入
9. **AI 回應有據**：強制使用 RAG，防護 Prompt Injection
10. **原生整合優先**：使用官方 SDK（Bolt/PyGithub/OpenAI）

## 文件標準

### 語言要求
**所有專案文件必須使用繁體中文**，包括：
- spec.md, plan.md, tasks.md
- commit 訊息、PR 描述
- 程式碼註解（除外部相容性需求外）

**例外**：
- 程式碼變數/函式名稱使用英文（遵循 PEP 8）
- 技術專有名詞保留原文（如 "Docker container", "REST API"）

### SDD 格式要求

所有 SDD 必須包含以下 5 個強制章節：
1. **系統概述** - 專案目標、使用者場景、限制
2. **架構設計** - 系統架構圖（Mermaid）、元件職責
3. **資料模型** - 實體關係圖（Mermaid erDiagram）
4. **API 規格** - 端點定義、請求/回應範例
5. **部署方案** - 環境配置、CI/CD、監控策略

### Mermaid 圖表規範

**強制驗證**：所有圖表必須通過 `mermaid-cli` 語法檢查

- 架構圖：`graph TD` 或 `graph LR`
- 資料模型：`erDiagram`
- 流程圖：`flowchart` 或 `sequenceDiagram`

## 安全約束

### Docker 容器規範
- 基礎映像：`python:3.11-slim`
- 執行使用者：非 root
- 資源限制：CPU 2 核心，記憶體 4GB
- 生命週期：任務完成或逾時（10 分鐘）後自動銷毀

### Secrets 管理
- 所有 API tokens 透過環境變數注入
- 日誌中不得記錄 PII 或 secrets（使用 `[REDACTED]` 遮罩）
- 網路存取白名單：Slack API, GitHub API, OpenAI API

### 依賴管理
- 版本鎖定：`requirements.txt` 或 `poetry.lock`
- 弱點掃描：`pip-audit`, `safety`, 或 GitHub Dependabot
- 禁止使用 CVSS ≥ 7.0 的套件

## SpecKit 腳本參考

### create-new-feature.sh
建立新功能分支與規格檔案結構
```bash
--json              # JSON 輸出模式
--number N          # 功能編號
--short-name NAME   # 短名稱（2-4 個詞）
"功能描述"          # 自然語言描述
```

### check-prerequisites.sh
檢查開發環境必要工具

### update-agent-context.sh
更新 agent 開發上下文檔案

## 品質檢查流程

### 規格驗證（/speckit.specify 後自動執行）
- ✅ 無實作細節（語言、框架、API）
- ✅ 需求可測試且明確
- ✅ 成功標準可衡量且與技術無關
- ✅ 所有 [NEEDS CLARIFICATION] 標記已解決
- ✅ 驗收場景使用 Gherkin 格式
- ✅ Edge cases 已識別

### Constitution Check（/speckit.plan 階段）
違反憲法原則的項目必須在 plan.md 的「複雜度追蹤」章節明確記錄：
- 違反的原則
- 引入原因
- 已拒絕的更簡單替代方案及理由

## 協作與審核

### Pull Request 流程
- 所有 SDD 產出必須透過 PR 審核
- PR 標題格式：`feat: 新增 {功能名稱} SDD`
- PR 描述包含：變更摘要、變更原因、測試結果、審核清單
- 至少一位審核者批准才能合併

### Code Review 檢查項目
- [ ] 測試已撰寫且通過（紅燈 → 綠燈流程完成）
- [ ] 憲法原則已遵循（特別是 I, II, III, VIII, IX）
- [ ] 無未經授權的複雜性引入
- [ ] 日誌與錯誤處理已實作
- [ ] Secrets 未洩漏在程式碼或日誌中
- [ ] 文件已更新（spec.md, API docs）

## 重要提醒

1. **繁體中文強制**：所有文件、commit、PR 描述必須使用繁體中文
2. **測試優先**：TDD 是 NON-NEGOTIABLE 原則，測試必須先於實作
3. **無狀態設計**：Bot 不得在本地持久化狀態，所有狀態存於 GitHub
4. **Docker 隔離**：所有自動化操作在容器中執行，任務完成後銷毀
5. **憲法至上**：憲法效力高於所有其他實踐，違反需明確記錄並獲批准

## Active Technologies
- Python 3.11 (001-spec-bot-sdd-integration)

## Recent Changes
- 001-spec-bot-sdd-integration: Added Python 3.11
