# Spec Bot - 規格機器人

**Specification-Driven Development (SDD) 工具包** - 將自然語言需求轉換為可執行的技術規格

[![版本](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![憲法版本](https://img.shields.io/badge/constitution-v2.0.0-orange.svg)](.specify/memory/constitution.md)

---

## 專案簡介

Spec Bot 是一個 **AI 驅動的規格自動化工具**,專為需要嚴謹需求管理的企業環境設計。系統透過結構化工作流程,將 BRD (Business Requirements Document) 自動轉換為 SDD (System Design Document),確保一致性、可追溯性與合規性。

### 核心價值

- **規格即真相**: 所有需求以 Markdown 儲存於 Git,版本可控、可稽核
- **工作流程驅動**: 強制執行 `specify → clarify → plan → tasks → implement → analyze` 流程
- **銀行級合規**: 支援風險管理、資安、法遵、稽核需求 (Bank Profile 擴充)
- **測試驅動開發**: 內建 Gherkin 場景,TDD 為核心原則 (非協商)
- **AI 輔助人審**: AI 產生草稿,人工審核確認,符合監理要求

---

## 快速開始

### 核心 SDD 工作流程 (適用所有專案)

```bash
# 1. 從自然語言生成功能規格
/speckit.specify "設計 STR 可疑交易報告摘要自動化功能"

# 2. 釐清模糊需求 (最多 5 個問題/回合)
/speckit.clarify

# 3. 生成實作規劃 (架構、技術選型、資料模型)
/speckit.plan

# 4. 生成可執行任務清單
/speckit.tasks

# 5. 分析一致性 (跨文件驗證)
/speckit.analyze

# 6. 執行實作 (TDD 模式)
/speckit.implement
```

### Bank Profile 工作流程 (適用銀行/金融/醫療等受監理產業)

```bash
# Phase 1: 專案上下文 (00-20)
/speckit.meta              # 專案元資料、利害關係人、優先順序
/speckit.business          # 業務目標、KPI、使用者故事
/speckit.process           # 流程設計 (As-Is / To-Be)

# Phase 2: 風險與資安 (30-40)
/speckit.risk              # 風險識別、控制措施、RACI
/speckit.infosec           # 資安需求、權限矩陣

# Phase 3: 法遵與稽核 (50-60)
/speckit.compliance        # 法規對應、法遵控制點
/speckit.audit             # 稽核需求、日誌要求

# Phase 4: 非功能需求 (70)
/speckit.nfr               # 效能、可用性、RTO/RPO

# Phase 5: 審核與憲法建立 (關鍵整合步驟)
/speckit.review            # 審核 00-70 完整性 → 生成 PROJECT_SUMMARY.md
/speckit.constitution      # 讀取總結 → 更新 constitution.md (通用+專案約束)

# Phase 6: 功能開發循環 (可重複)
/speckit.specify <功能>    # 自動整合 constitution 約束
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze           # 驗證符合 constitution
/speckit.implement
```

---

## 架構總覽

### 目錄結構

```
.
├── .claude/
│   └── commands/                # Slash 命令定義
│       ├── speckit.specify.md   # 核心 SDD 工作流程
│       ├── speckit.clarify.md
│       ├── speckit.plan.md
│       ├── speckit.tasks.md
│       ├── speckit.implement.md
│       ├── speckit.analyze.md
│       ├── speckit.meta.md      # Bank Profile 命令
│       ├── speckit.business.md
│       ├── speckit.process.md
│       ├── speckit.risk.md
│       ├── speckit.infosec.md
│       ├── speckit.compliance.md
│       ├── speckit.audit.md
│       └── speckit.nfr.md
├── .specify/
│   ├── memory/
│   │   └── constitution.md      # 專案憲法 (v2.0.0) - 10 大核心原則
│   ├── scripts/bash/            # 工作流程自動化腳本
│   │   ├── create-new-feature.sh
│   │   ├── check-prerequisites.sh
│   │   ├── setup-plan.sh
│   │   └── update-agent-context.sh
│   └── templates/               # 文件模板
│       ├── spec-template.md     # 功能規格模板
│       ├── plan-template.md     # 實作規劃模板
│       ├── tasks-template.md    # 任務分解模板
│       ├── 00_meta-template.md  # Bank Profile 模板 (00-70)
│       ├── 30_risk_control-template.md
│       ├── 40_infosec-template.md
│       ├── 50_compliance-template.md
│       ├── 60_audit-template.md
│       └── 70_nfr-template.md
├── bank-profile/                # 專案層級 Bank SDD Profile
│   ├── 00_meta.md
│   ├── 10_business.md
│   ├── 20_process.md
│   ├── 30_risk_control.md
│   ├── 40_infosec.md
│   ├── 50_compliance.md
│   ├── 60_audit.md
│   └── 70_nfr.md
├── specs/
│   └── ###-feature-name/        # 功能層級 SDD (從 Bank Profile 產生)
│       ├── spec.md
│       ├── plan.md
│       ├── tasks.md
│       ├── research.md
│       ├── data-model.md
│       ├── contracts/
│       └── checklists/
├── draft/
│   └── extension.md             # Bank Profile 擴充設計文件
└── CLAUDE.md                    # Claude Code 使用指引
```

### 文件關係圖

```
Bank Profile (專案層級,00-70)
┌─────────────────────────────────────────┐
│ 00_meta → 10_business → 20_process     │
│    ↓          ↓            ↓            │
│ 30_risk ← 40_infosec ← 50_compliance   │
│    ↓          ↓            ↓            │
│ 60_audit ←────────┴────→ 70_nfr        │
└──────────────┬──────────────────────────┘
               │
               ↓ /speckit.review (審核與總結)
┌─────────────────────────────────────────┐
│ PROJECT_SUMMARY.md                      │
│ ├─ 專案概覽 (00/10/20 精華)            │
│ ├─ 風險與控制總覽 (30/40/50)           │
│ ├─ 技術約束總覽 (60/70)                │
│ └─ 專案特定約束 (為憲法準備)           │
└──────────────┬──────────────────────────┘
               │
               ↓ /speckit.constitution (建立憲法)
┌─────────────────────────────────────────┐
│ .specify/memory/constitution.md         │
│ ├─ Part I: 通用原則 (10 大核心原則)    │
│ └─ Part II: 專案特定約束               │
│    ├─ XI. 技術約束                     │
│    ├─ XII. 流程約束                    │
│    ├─ XIII. 合規約束                   │
│    └─ XIV. 效能與可靠性約束            │
└──────────────┬──────────────────────────┘
               │
               ↓ 所有功能開發自動遵守
Feature SDD (功能層級,可重複)
┌─────────────────────────────────────────┐
│ spec.md (WHAT) ← 繼承 constitution 約束 │
│   ↓                                     │
│ plan.md (HOW) ← 驗證符合 constitution  │
│   ↓                                     │
│ tasks.md (WHEN)                         │
│   ↓                                     │
│ analyze ← 驗證符合 constitution         │
│   ↓                                     │
│ 實作程式碼 (TDD)                         │
└─────────────────────────────────────────┘
```

---

## 核心命令說明

### 基礎 SDD 工作流程

| 命令 | 用途 | 輸入 | 輸出 |
|------|------|------|------|
| `/speckit.specify` | 從自然語言生成功能規格 | 功能描述 | `spec.md` (Gherkin 場景、驗收標準) |
| `/speckit.clarify` | 偵測並解決規格模糊處 | `spec.md` | 更新的 `spec.md` + Clarifications 章節 |
| `/speckit.plan` | 生成實作規劃 | `spec.md` | `plan.md`, `data-model.md`, `contracts/` |
| `/speckit.tasks` | 生成可執行任務清單 | `spec.md`, `plan.md` | `tasks.md` (依優先級、依賴關係排序) |
| `/speckit.implement` | 執行 TDD 實作 | `tasks.md` | 程式碼 + 測試 |
| `/speckit.analyze` | 跨文件一致性驗證 | `spec.md`, `plan.md`, `tasks.md` | 分析報告 (唯讀) |

### Bank Profile 命令 (企業級擴充)

| 命令 | 用途 | 主要產出 | 依賴文件 |
|------|------|---------|---------|
| `/speckit.meta` | 專案元資料 | 利害關係人、團隊、優先順序 | 無 |
| `/speckit.business` | 業務需求 | KPI、使用者故事 (Gherkin) | `00_meta.md` |
| `/speckit.process` | 流程設計 | As-Is/To-Be 流程圖、例外處理 | `10_business.md` |
| `/speckit.risk` | 風險管理 | 風險清單、控制措施、RACI | `10_business.md`, `20_process.md` |
| `/speckit.infosec` | 資安需求 | 資料分級、權限矩陣、加密要求 | `30_risk_control.md` |
| `/speckit.compliance` | 法遵對應 | 法規清單、法遵控制點、證據留存 | `30_risk`, `40_infosec` |
| `/speckit.audit` | 稽核需求 | 稽核事件、日誌格式、保留期限 | `50_compliance` |
| `/speckit.nfr` | 非功能需求 | SLA、RTO/RPO、效能指標 | 所有前置文件 |
| `/speckit.review` | **審核與總結** | **PROJECT_SUMMARY.md** (專案總結) | **00-70 全部** |
| `/speckit.constitution` | **建立憲法** | **更新 constitution.md** (通用+專案約束) | **PROJECT_SUMMARY.md** |

---

## 憲法原則 (v2.0.0)

Spec Bot 遵循 **10 大核心原則**,確保系統簡潔、可靠、合規:

### 關鍵原則

1. **Single Source of Truth** - 所有狀態存於 GitHub,Bot 無狀態
2. **Lightweight Sandboxing** - 所有操作於 Docker 容器中執行
3. **Test-Driven Development** - TDD 搭配 Gherkin 場景 (**非協商**)
4. **YAGNI** - 拒絕 spec.md 未定義的複雜度
5. **Full Traceability** - 結構化 JSON 日誌 + Correlation IDs
6. **Zero Trust & Least Privilege** - 最小權限 API Scopes
7. **Semantic Versioning** - MAJOR.MINOR.PATCH + Migration Guides
8. **Grounded AI & Prompt Injection Defense** - RAG + Source Citations
9. **Native Integration First** - 使用官方 SDKs (Slack Bolt, PyGithub, OpenAI)

完整憲法: [`.specify/memory/constitution.md`](.specify/memory/constitution.md)

---

## 使用情境

### 適用場景

✅ **強烈建議使用 Bank Profile**:
- 銀行、證券、保險等金融業
- 醫療照護系統 (HIPAA, GDPR)
- 處理個資或敏感資料的系統
- 受監理單位稽核的專案
- 需要跨部門 (業務/IT/法遵/資安/稽核) 對齊的專案

✅ **可選使用 Bank Profile**:
- 中大型企業內部系統 (需要風險管理)
- SaaS 產品 (需要資安與合規文件)

❌ **不建議使用 Bank Profile** (使用核心 SDD 即可):
- 快速原型驗證
- 內部工具 (無監理要求)
- 非受監理產業

### 真實案例

**案例: STR/SAR 可疑交易報告摘要自動化**

```bash
# 1. 建立專案上下文 (Bank Profile)
/speckit.meta
# → 定義專案背景、監理要求 (洗錢防制法)、利害關係人 (業務/法遵/IT/稽核)

/speckit.business
# → KPI: 摘要產生時間減少 70%
# → 使用者故事: 「作為分析人員,我需要 AI 輔助摘要,減少重複性文字工作」

/speckit.process
# → As-Is 流程: 人工閱讀 STR → 人工撰寫摘要 (30 分鐘/案)
# → To-Be 流程: AI 產生草稿 (5 秒) → 人工審核修改 (5 分鐘) → 確認送出

/speckit.risk
# → 識別風險: R-001 模型遺漏關鍵可疑行為
# → 控制措施: C-001 強制人工審核 (預防 R-001)

/speckit.infosec
# → 資料分級: STR 文本為「高度機密」
# → 權限矩陣: 分析人員 (檢視/編輯)、法遵主管 (檢視)、稽核 (檢視遮罩後)
# → 遮罩規則: 姓名 → 王**、身分證 → ******7890

/speckit.compliance
# → 適用法規: REG-AML-001 洗錢防制法、REG-PDPA-001 個資法
# → 法遵控制點: CP-AML-001 STR 個案完整追溯能力
# → 證據留存: 原始 STR + 模型輸出 + 最終摘要 (7 年)

/speckit.audit
# → 稽核事件: AE-BIZ-003 修改摘要內容 (記錄 before/after)
# → 日誌保留: 7 年 (洗錢防制法要求)
# → 稽核報表: RA-AML-001 分析人員模型使用情況統計 (每月)

/speckit.nfr
# → NFR-PERF-001: 單筆 STR 摘要生成 < 5 秒
# → NFR-AVAIL-001: 系統可用性 99.5% (工作時段)
# → NFR-DR-001: RTO 4 小時、RPO 0 (已確認摘要不可遺失)

# 2. 產生技術規格 (整合 Bank Profile)
/speckit.specify --from-bank-profile
# → 自動擷取 Bank Profile 需求,生成 spec.md

/speckit.plan
# → 生成架構: FastAPI + PostgreSQL + OpenAI GPT-4
# → 資料模型: STRCase, ModelSummary, AuditLog
# → 合約: POST /api/v1/str/{case_id}/generate-summary

/speckit.tasks
# → T001: 建立專案結構 (Docker + uv + pytest)
# → T010 [P] [US1] STR 摘要生成 API 合約測試
# → T012 [P] [US1] 模型推論服務整合
# → T014 [US1] 人工審核 UI (前後對照)

/speckit.implement
# → 依 tasks.md 執行 TDD 實作
```

---

## 技術細節

### 工作流程腳本

所有腳本位於 `.specify/scripts/bash/`,支援 `--json` 模式:

- `create-new-feature.sh`: 自動編號功能分支 (`###-feature-name`)
- `check-prerequisites.sh`: 驗證工作流程狀態,返回檔案路徑
- `setup-plan.sh`: 初始化規劃階段
- `update-agent-context.sh`: 同步 Agent 上下文檔案

### 模板變數

所有模板使用一致的變數語法:

- `[FEATURE NAME]`, `[###-feature-name]`, `[DATE]`
- `$ARGUMENTS` - 使用者輸入
- `[NEEDS CLARIFICATION]` - 標記未知項 (最多 3 個/spec)
- 優先級: `P1`, `P2`, `P3`
- 任務格式: `T###`, `[P]` (可平行), `[US#]` (對應使用者故事)

### Git 工作流程

- **功能分支**: `###-feature-name` (自動編號)
- **Bot 分支**: `bot/spec-{timestamp}` 或 `bot/{feature-name}`
- **Commit 格式**: Conventional Commits (`feat:`, `fix:`, `docs:`)
- **PR 審查**: 所有 SDD 文件需經 PR 審查後合併

---

## 常見問題 (FAQ)

### Q: Bank Profile 一定要全部完成才能產生 spec.md 嗎?

A: 不用。Bank Profile 命令是**獨立且可選的**。你可以:
- 只執行部分命令 (例如只做 risk + infosec)
- 直接執行 `/speckit.specify` (不使用 Bank Profile)
- 先執行 `/speckit.specify`,之後補充 Bank Profile

### Q: 如果我的專案不需要法遵怎麼辦?

A: 跳過 Bank Profile,直接使用核心 SDD 工作流程:
```bash
/speckit.specify "功能描述"
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
```

### Q: Bank Profile 文件存在哪裡?

A: **專案層級** `bank-profile/` 目錄,而非功能層級 `specs/###-feature-name/`。Bank Profile 描述整體專案需求,spec.md 描述個別功能實作。

### Q: `/speckit.analyze` 會自動修正問題嗎?

A: 不會。`analyze` 是**唯讀命令**,只產生分析報告。修正需明確經使用者核准。

### Q: 憲法原則可以違反嗎?

A: 可以,但需在 `plan.md` 的「Complexity Tracking」章節明確記錄:
- 違反了哪條原則
- 為何需要違反
- 為何更簡單的替代方案不可行

---

## 授權 & 貢獻

- **授權**: MIT License
- **貢獻指引**: 請參閱 [CONTRIBUTING.md](CONTRIBUTING.md)
- **問題回報**: [GitHub Issues](https://github.com/your-org/spec-bot/issues)

---

## 版本資訊

- **Spec Bot 版本**: 2.0.0
- **憲法版本**: v2.0.0 (2025-11-13 核定)
- **更新日誌**: [CHANGELOG.md](CHANGELOG.md)

---

## 下一步

1. **快速體驗**: 執行 `/speckit.specify "你的功能描述"` 看看產出
2. **深入學習**: 閱讀 [CLAUDE.md](CLAUDE.md) 了解完整工作流程
3. **銀行級專案**: 依序執行 Bank Profile 命令 (meta → business → ... → nfr)
4. **加入社群**: [Discussions](https://github.com/your-org/spec-bot/discussions)

**讓規格驅動開發,讓 AI 輔助人審,讓合規成為設計基礎。**
