# 實作計劃：[FEATURE]

**分支**: `[###-feature-name]` | **日期**: [DATE] | **規格**: [link]
**輸入**: 功能規格來自 `/specs/[###-feature-name]/spec.md`

**注意**: 此模板由 `/speckit.plan` 指令填寫。執行流程請參閱 `.specify/templates/commands/plan.md`。

## 摘要

[從功能規格中提取：主要需求 + 研究中的技術方法]

## 技術上下文

<!--
  需要操作：請將本節內容替換為專案的技術細節。
  此處的結構僅供建議，用於指導迭代過程。
-->

**語言/版本**: [例如：Python 3.11、Swift 5.9、Rust 1.75 或需要釐清]
**主要依賴套件**: [例如：FastAPI、UIKit、LLVM 或需要釐清]
**儲存方式**: [如適用，例如：PostgreSQL、CoreData、檔案 或不適用]
**測試框架**: [例如：pytest、XCTest、cargo test 或需要釐清]
**目標平台**: [例如：Linux 伺服器、iOS 15+、WASM 或需要釐清]
**專案類型**: [單一/網頁/行動 - 決定原始碼結構]
**效能目標**: [特定領域，例如：1000 req/s、10k lines/sec、60 fps 或需要釐清]
**限制條件**: [特定領域，例如：<200ms p95、<100MB 記憶體、可離線運作 或需要釐清]
**規模/範圍**: [特定領域，例如：10k 使用者、1M LOC、50 個畫面 或需要釐清]

## 章程檢查

*關卡：必須在第 0 階段研究前通過。在第 1 階段設計後重新檢查。*

[依據章程檔案決定的關卡]

## 專案結構

### 文件（此功能）

```text
specs/[###-feature]/
├── plan.md              # 此檔案（/speckit.plan 指令輸出）
├── research.md          # 第 0 階段輸出（/speckit.plan 指令）
├── data-model.md        # 第 1 階段輸出（/speckit.plan 指令）
├── quickstart.md        # 第 1 階段輸出（/speckit.plan 指令）
├── contracts/           # 第 1 階段輸出（/speckit.plan 指令）
└── tasks.md             # 第 2 階段輸出（/speckit.tasks 指令 - 不由 /speckit.plan 建立）
```

### 原始碼（儲存庫根目錄）
<!--
  需要操作：請將下方的佔位結構替換為此功能的具體配置。
  刪除未使用的選項，並以實際路徑展開所選結構（例如：apps/admin、packages/something）。
  交付的計劃不得包含選項標籤。
-->

```text
# [若未使用請移除] 選項 1：單一專案（預設）
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [若未使用請移除] 選項 2：網頁應用程式（偵測到「frontend」+「backend」時）
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [若未使用請移除] 選項 3：行動裝置 + API（偵測到「iOS/Android」時）
api/
└── [同上方的 backend]

ios/ or android/
└── [平台特定結構：功能模組、UI 流程、平台測試]
```

**結構決策**: [記錄所選結構並參照上方擷取的實際目錄]

## 複雜度追蹤

> **僅在章程檢查有必須說明的違規時填寫**

| 違規項目 | 為何需要 | 為何拒絕更簡單的替代方案 |
|-----------|------------|-------------------------------------|
| [例如：第 4 個專案] | [目前需求] | [為何 3 個專案不足] |
| [例如：Repository 模式] | [特定問題] | [為何直接存取資料庫不足] |
