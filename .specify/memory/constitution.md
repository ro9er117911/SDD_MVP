<!--
═══════════════════════════════════════════════════════════════
SYNC IMPACT REPORT - Constitution Update v1.0.0
═══════════════════════════════════════════════════════════════

Version Change: TEMPLATE → v1.0.0

Modified Sections:
  - Converted all placeholder tokens to concrete content
  - Added 10 core principles based on project requirements
  - Added 3 additional sections: Document Standards, Security Constraints, Governance

Added Principles:
  1. I. 單一事實來源 (Single Source of Truth)
  2. II. 輕量沙箱 (Lightweight Sandbox)
  3. III. 測試驅動開發 (Test-Driven Development) - NON-NEGOTIABLE
  4. IV. 整合測試 (Integration Testing)
  5. V. 簡約與 YAGNI (Simplicity & YAGNI)
  6. VI. 完整可追溯性 (Complete Traceability)
  7. VII. 語意化版本 (Semantic Versioning)
  8. VIII. 零信任與權限最小化 (Zero Trust & Least Privilege)
  9. IX. AI 回應有據 (Evidence-Based AI Responses)
  10. X. 原生整合優先 (Native Integration First)

Templates Requiring Updates:
  ✅ .specify/templates/plan-template.md - Constitution Check section aligned
  ✅ .specify/templates/spec-template.md - Requirements format aligned
  ✅ .specify/templates/tasks-template.md - Task categorization aligned
  ✅ .claude/commands/*.md - Command references verified

Follow-up TODOs: None - All placeholders have been resolved

═══════════════════════════════════════════════════════════════
-->

# Spec Bot 專案憲法

本憲法定義 Spec Bot 專案的核心原則、技術標準與治理規則，為所有開發決策提供最高指導原則。

## 核心原則

### I. 單一事實來源

**GitHub 為唯一權威資料來源，Bot 必須完全無狀態**

- GitHub repository 是所有規格、程式碼、配置的唯一事實來源
- Bot 不得在本地或外部系統持久化任何狀態或資料
- 所有歷史記錄、版本追溯、審核紀錄依賴 GitHub 原生功能（commit history、PR history、compare）
- Bot 重啟後必須能從 GitHub 完整恢復上下文，無需額外資料儲存

**理由**: 避免狀態不一致問題，簡化災難復原與系統擴展，利用 GitHub 成熟的版本控制能力。

---

### II. 輕量沙箱

**所有自動化操作必須在 Docker 容器中隔離執行**

- 每個 BRD 處理請求啟動獨立的 Docker 容器
- 容器必須在任務完成或逾時（10 分鐘）後自動銷毀
- 容器環境標準化：
  - 基礎映像：`node:18-slim`
  - 執行使用者：非 root
  - 資源限制：CPU 2 核心上限，記憶體 4GB 上限
  - 安裝工具：Claude CLI、SpecKit CLI、Git、Python 3.11、uv、Node.js 18+、mermaid-cli、curl、基本檔案工具
- 白名單命令：claude-cli, /speckit.*, git, bash, node, npm, python3, uv, mmdc, curl, mkdir, cp, mv, rm
- 禁止命令：編譯器（gcc, javac）、套件管理器（apt, yum）、網路掃描工具（nmap）

**理由**: 確保操作隔離性與安全性，防止惡意或錯誤操作影響主機系統，便於資源清理與並行處理。

---

### III. 測試驅動開發 (NON-NEGOTIABLE)

**TDD 為強制性原則，測試必須先於實作**

- 嚴格遵循 Red-Green-Refactor 循環：
  1. 撰寫測試（必須失敗）
  2. 取得使用者批准
  3. 驗證測試確實失敗
  4. 實作最小可行程式碼使測試通過
  5. 重構（保持測試通過）
- 驗收場景必須使用 Gherkin 語法（Given-When-Then）
- 禁止先寫實作再補測試
- 測試覆蓋核心業務邏輯，而非追求 100% 行覆蓋率

**理由**: TDD 確保需求可測試性、降低缺陷率、提供即時回饋、作為活文件記錄行為預期。此原則不可妥協。

---

### IV. 整合測試

**重點領域必須包含整合測試，覆蓋率 ≥ 80%**

強制整合測試範圍：
- 新增或變更的 API 契約（Contract tests）
- 跨服務通訊（Slack API、GitHub API、OpenAI API）
- 共享的資料結構（brd_analysis.json、SDD 章節格式）
- Docker 容器與主機系統互動
- GitHub Actions 觸發與執行流程

整合測試策略：
- 使用 mock servers 模擬外部 API（避免實際 API 呼叫）
- 驗證請求格式、回應解析、錯誤處理
- 測試環境與生產環境配置一致

**理由**: 整合測試捕捉單元測試無法發現的介面不一致與配置錯誤，確保系統各部分正確協作。

---

### V. 簡約與 YAGNI

**禁止過度工程，複雜性需明確記錄於 plan.md**

- 遵循 YAGNI（You Aren't Gonna Need It）原則：只實作當前明確需求
- 禁止「為未來擴展」而增加抽象層或配置選項
- 三行相似程式碼優於過早抽象
- 信任內部程式碼與框架保證，僅在系統邊界（使用者輸入、外部 API）驗證
- 違反簡約原則時，必須在 `plan.md` 的「複雜度追蹤」章節記錄：
  - 違反的原則
  - 引入原因
  - 已拒絕的更簡單替代方案及理由

**理由**: 過度工程增加維護成本、降低可讀性、延長開發時間。最佳複雜度是完成當前任務的最小必要複雜度。

---

### VI. 完整可追溯性

**結構化 JSON 日誌，使用 correlation_id 追蹤跨系統操作**

日誌標準：
- 格式：結構化 JSON（非純文字）
- 強制欄位：
  - `timestamp`（ISO 8601 格式）
  - `correlation_id`（追蹤單一請求的所有操作）
  - `log_level`（INFO, WARNING, ERROR）
  - `component`（記錄來源：slack_listener, gpt_coordinator, docker_executor 等）
  - `message`（簡短說明）
  - `context`（相關資訊：user_id, file_name, pr_url 等）
- 錯誤日誌額外欄位：
  - `error_type`（分類：GPT_API_ERROR, GIT_ERROR, VALIDATION_ERROR, DOCKER_ERROR）
  - `error_message`（完整錯誤訊息）
  - `stack_trace`（堆疊追蹤）

敏感資料遮罩：
- API tokens、secrets 必須使用 `[REDACTED]` 遮罩
- 不得記錄完整的 API keys、passwords、personal identifiable information (PII)

**理由**: 結構化日誌支援快速問題定位、效能分析、審計追蹤。correlation_id 使跨系統操作可完整追溯。

---

### VII. 語意化版本

**MAJOR.MINOR.PATCH 版本號，破壞性變更需遷移指南**

版本號規則：
- **MAJOR**：不向下相容的 API 變更、移除功能、重大架構調整
  - 必須提供遷移指南（migration guide）
  - 說明破壞性變更與升級步驟
- **MINOR**：向下相容的新功能、新 API 端點、功能增強
- **PATCH**：向下相容的錯誤修正、效能改善、文件更新

適用範圍：
- 憲法版本（constitution.md）
- API 版本（若提供外部 API）
- 重要工具腳本版本（如 SpecKit CLI）

**理由**: 語意化版本讓使用者快速判斷升級風險，遷移指南降低升級成本，版本號傳達變更影響範圍。

---

### VIII. 零信任與權限最小化

**所有 API tokens 透過環境變數注入，賦予最小必要權限**

Secrets 管理：
- 所有 API tokens（Slack, GitHub, OpenAI）透過環境變數注入
- 不得將 secrets 寫死在程式碼、配置檔案或 commit 歷史中
- 使用 `.env` 檔案本地開發，生產環境使用 GitHub Secrets 或密鑰管理服務

權限最小化：
- **GitHub Token**: 使用 Fine-grained personal access token，限制權限範圍：
  - `contents: write`（建立分支、提交檔案）
  - `pull_requests: write`（建立 PR、設定審核者）
  - `workflows: write`（觸發 GitHub Actions）
  - `metadata: read`（讀取 repository 基本資訊）
- **Slack App**: 僅申請必要權限（讀取訊息、上傳檔案、發送訊息）
- **Docker 容器**: 以非 root 使用者執行，無主機系統存取權限

網路存取白名單：
- 僅允許連線至：Slack API (slack.com), GitHub API (api.github.com), OpenAI API (api.openai.com)

**理由**: 零信任原則降低 secrets 洩漏風險，權限最小化限制攻擊面，白名單防止資料外洩。

---

### IX. AI 回應有據

**強制使用 RAG（Retrieval-Augmented Generation），防護 Prompt Injection**

RAG 策略：
- GPT-5 nano 生成 SDD 時，必須引用 BRD 原文章節
- 禁止 GPT 憑空捏造需求或功能細節
- Prompt 設計包含明確指示：「僅基於提供的 BRD 內容生成 SDD，不得添加未提及的需求」

Prompt Injection 防護：
- BRD 內容視為不可信輸入，嚴格分隔系統指令與使用者輸入
- 使用結構化格式（JSON）傳遞 BRD 內容，避免純文字拼接
- 驗證 BRD 大小（≤ 100 KB）與格式（.md 檔案），拒絕異常輸入

輸出驗證：
- 使用 mermaid-cli 驗證生成的 Mermaid 圖表語法正確性
- 檢查 SDD 是否包含 5 個強制章節
- 若驗證失敗，重試一次（使用更明確的 prompt）

**理由**: RAG 確保 AI 回應基於事實而非幻想，Prompt Injection 防護避免惡意 BRD 操控系統行為，輸出驗證保證品質。

---

### X. 原生整合優先

**使用官方 SDK，避免自行實作 API 包裝層**

強制使用官方 SDK：
- **Slack**: Bolt for JavaScript/Python（官方框架）
- **GitHub**: PyGithub（Python）或 Octokit（JavaScript）
- **OpenAI**: OpenAI Python/JavaScript SDK
- **Claude CLI**: `@anthropic-ai/claude-code`（官方 Agent CLI）
- **SpecKit CLI**: `specify-cli`（官方規格驅動開發框架）

禁止行為：
- 不得直接使用 `requests` 或 `axios` 手動呼叫 Slack/GitHub/OpenAI API
- 不得自行實作 OAuth 流程、簽章驗證或 API rate limiting（使用 SDK 內建功能）

例外情況：
- 官方 SDK 不支援的特殊功能（必須記錄於 `plan.md` 複雜度追蹤）
- 官方 SDK 有嚴重 bug 且無修復計畫（需提供證據）

**理由**: 官方 SDK 經過充分測試、處理邊界情況、自動更新，減少維護負擔與安全風險。自行實作容易遺漏細節。

---

## 文件標準

### 語言要求

**所有專案文件必須使用繁體中文**

強制繁體中文範圍：
- 規格文件（spec.md, plan.md, tasks.md）
- Commit 訊息（遵循 Conventional Commits 格式）
- Pull Request 標題與描述
- 程式碼註解（除非外部相容性需求）

例外：
- 程式碼變數名稱、函式名稱（遵循 PEP 8 或對應語言規範，使用英文）
- 技術專有名詞保留原文（Docker container, REST API, Mermaid 等）
- 外部 API 回應或第三方套件文件

**理由**: 統一語言降低溝通成本，確保團隊成員快速理解文件內容，專有名詞保留原文避免誤解。

---

### SDD 格式要求

**所有 SDD 必須包含以下 5 個強制章節**

1. **系統概述**
   - 專案目標
   - 使用者角色與場景
   - 技術限制與假設

2. **架構設計**
   - 系統架構圖（Mermaid: graph TD 或 graph LR）
   - 元件職責說明
   - 技術堆疊選擇

3. **資料模型**
   - 實體關係圖（Mermaid: erDiagram）
   - 關鍵實體屬性定義
   - 資料流向

4. **API 規格**
   - 端點定義（路徑、HTTP 方法）
   - 請求/回應範例（JSON 格式）
   - 錯誤碼定義

5. **部署方案**
   - 環境配置（開發、測試、生產）
   - CI/CD 流程
   - 監控與告警策略

章節編號：使用 `01_系統概述.md`, `02_架構設計.md` 等格式，確保排序一致。

---

### Mermaid 圖表規範

**強制驗證：所有圖表必須通過 mermaid-cli 語法檢查**

圖表類型標準：
- **架構圖**: `graph TD` 或 `graph LR`
- **資料模型**: `erDiagram`
- **流程圖**: `flowchart` 或 `sequenceDiagram`
- **部署圖**: `graph` 或 C4 model

語法驗證命令：
```bash
mmdc -i diagram.mermaid -o diagram.png
```

圖表複雜度限制：
- 節點數量建議不超過 50 個（避免渲染效能問題）
- 使用子圖（subgraph）組織複雜架構

**理由**: 統一圖表格式提升可讀性，語法驗證避免 GitHub 渲染錯誤，複雜度限制確保圖表實用性。

---

## 安全約束

### Docker 容器規範

- **基礎映像**: `node:18-slim`（定期更新至最新安全補丁版本）
- **執行使用者**: 非 root（使用 `USER node` 或建立專用使用者）
- **資源限制**:
  - CPU: 2 核心上限
  - 記憶體: 4GB 上限
  - 磁碟空間: 10GB 上限（臨時檔案）
- **生命週期**:
  - 任務完成後立即銷毀
  - 逾時（10 分鐘）後強制終止並清理
- **網路隔離**:
  - 僅允許連線至白名單 API 端點
  - 禁止主機網路模式（`--network host`）

---

### Secrets 管理

- **環境變數注入**:
  - 本地開發：使用 `.env` 檔案（已加入 `.gitignore`）
  - 生產環境：使用 GitHub Secrets 或 AWS Secrets Manager
- **日誌遮罩**:
  - 所有日誌輸出前自動掃描並遮罩 secrets 模式（如 `sk-`, `ghp_`, `xoxb-`）
  - PII（email, phone, IP address）使用 `[REDACTED]` 替換
- **定期輪替**:
  - API tokens 每 90 天輪替一次
  - 使用 expiring tokens 機制（如 GitHub Fine-grained tokens 設定有效期）

---

### 依賴管理

- **版本鎖定**:
  - Python: `requirements.txt` 或 `poetry.lock`
  - Node.js: `package-lock.json` 或 `yarn.lock`
- **弱點掃描**:
  - 定期執行 `pip-audit`（Python）或 `npm audit`（Node.js）
  - 整合 GitHub Dependabot 自動偵測與修復
- **風險閾值**:
  - 禁止使用 CVSS 評分 ≥ 7.0 的套件
  - 高風險套件必須在 48 小時內更新或替換

---

## 治理規則

### 憲法效力

本憲法為專案最高指導原則，效力優先於所有其他開發實踐、團隊慣例或個人偏好。

---

### 修訂程序

憲法修訂需經過以下流程：

1. **提案階段**:
   - 任何團隊成員可提出修訂建議（透過 GitHub Issue）
   - 說明修訂原因、影響範圍、替代方案

2. **審查階段**:
   - 核心團隊成員（SA、Architect、Tech Lead）審查提案
   - 評估對現有專案的影響（需要多少程式碼調整）
   - 若影響重大（涉及核心原則變更），需全員投票

3. **實施階段**:
   - 更新 `constitution.md` 並遞增版本號
   - 若為 MAJOR 版本變更，提供遷移指南
   - 更新所有相關模板與文件（plan-template.md, spec-template.md, tasks-template.md）
   - 透過 PR 審核流程合併

---

### 合規檢查

#### Constitution Check Gate

所有功能規劃（`plan.md`）必須包含「Constitution Check」章節，驗證設計是否符合憲法原則。

檢查項目範例：
- ✅ 是否遵循單一事實來源（資料不持久化於 Bot）
- ✅ 是否使用 Docker 容器隔離執行
- ✅ 是否包含測試計畫（TDD 流程）
- ✅ 是否使用官方 SDK 而非自行包裝 API
- ✅ 是否記錄結構化日誌

違反憲法原則時：
- 必須在 `plan.md` 的「複雜度追蹤」章節記錄
- 說明違反原因、業務需求、已拒絕的更簡單方案
- 需獲得至少一位 Tech Lead 或 Architect 批准

---

#### Code Review 檢查清單

所有 Pull Request 必須通過以下檢查：

- [ ] 測試已撰寫且通過（紅燈 → 綠燈流程完成）
- [ ] 憲法原則已遵循（特別是 I, II, III, VIII, IX）
- [ ] 無未經授權的複雜性引入（無違反原則 V）
- [ ] 日誌與錯誤處理已實作（符合原則 VI）
- [ ] Secrets 未洩漏在程式碼或日誌中（符合原則 VIII）
- [ ] 文件已更新（spec.md, API docs 等）
- [ ] Mermaid 圖表通過語法驗證

---

### 審核流程

#### Pull Request 要求

- **標題格式**: 遵循 Conventional Commits（feat, fix, docs, refactor 等）
- **描述內容**:
  - 變更摘要（What changed）
  - 變更原因（Why changed）
  - 測試結果（Test coverage）
  - 審核清單（Checklist）
- **審核者要求**:
  - 至少一位 CODEOWNERS 批准（SA 或 Architect）
  - 自動化測試通過
  - Constitution Check 無違反項目（或違反已記錄並批准）

#### 分支保護規則

- Main branch 啟用保護：
  - 禁止直接 push
  - 需至少 1 位審核者批准
  - 需通過所有 CI 檢查
  - 需 linear history（禁止 merge commits，使用 rebase 或 squash）

---

### 執行層級 Agent 指引

**本憲法適用於 Claude CLI Agent 執行 SpecKit 指令時的所有決策與操作**

當 Claude CLI 執行 `/speckit.specify`, `/speckit.plan`, `/speckit.tasks` 等指令時，必須：
- 以本憲法為最高決策依據
- 在設計階段驗證 Constitution Check
- 在錯誤處理中遵循可追溯性原則（correlation_id）
- 在生成 SDD 時強制 5 章節格式與 Mermaid 圖表驗證
- 在任何自動化操作中維持零信任原則（不信任輸入，驗證所有外部資料）

參考文件：
- 執行層指引：`CLAUDE.md`（Agent 操作實踐）
- 模板定義：`.specify/templates/`（規格、計畫、任務格式）

---

## 版本資訊

**Version**: 1.0.0
**Ratified**: 2025-11-13
**Last Amended**: 2025-11-21

---

**變更歷史**:
- **v1.0.0** (2025-11-21): 從模板轉換為完整憲法，定義 10 項核心原則、文件標準、安全約束與治理規則
