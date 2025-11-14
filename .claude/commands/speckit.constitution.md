---
description: 從 PROJECT_SUMMARY.md (Bank Profile 審核結果) 或互動輸入建立或更新專案憲法（`.specify/memory/constitution.md`），整合通用原則與專案特定約束。
---

## 使用者輸入

```text
$ARGUMENTS
```

在執行前**必須**考慮使用者輸入（若非空）。

## 大綱

你將更新 `.specify/memory/constitution.md`（專案憲法）。此命令**優先從 `PROJECT_SUMMARY.md` 自動提煉專案特定約束**,若該檔案不存在則使用互動模式。

**核心概念**:
- **通用憲法原則** (10 大核心原則): 適用所有專案的不可協商原則
- **專案特定約束**: 從 Bank Profile (00-70) 提煉的專案專屬技術/流程/合規約束

## 執行流程

### 0. 前置檢查 - 是否存在 PROJECT_SUMMARY.md

**檢查檔案**: `$REPO_ROOT/PROJECT_SUMMARY.md`

#### 情境 A: PROJECT_SUMMARY.md 存在 (推薦路徑)

```
✅ 發現 PROJECT_SUMMARY.md (審核時間: YYYY-MM-DD HH:MM)

將自動提煉專案特定約束並整合到 constitution.md

專案特性 (從 PROJECT_SUMMARY.md):
  - 專案類型: [金融/醫療/一般企業]
  - 監理等級: [高/中/低]
  - 關鍵法規: [REG-001, REG-002...]
  - 技術約束: [X] 項
  - 流程約束: [Y] 項
  - 合規約束: [Z] 項

是否使用 PROJECT_SUMMARY.md 作為輸入? (yes/no/review)
  - yes: 自動模式 (推薦)
  - no: 互動模式 (手動輸入原則)
  - review: 先檢視 PROJECT_SUMMARY.md 內容
```

→ 選擇 **yes** 後跳到步驟 1-A

#### 情境 B: PROJECT_SUMMARY.md 不存在

```
⚠️ 未發現 PROJECT_SUMMARY.md

建議先執行 `/speckit.review` 審核 Bank Profile (00-70) 並生成專案總結。

是否繼續使用互動模式建立憲法? (yes/no/run-review)
  - yes: 互動模式 (手動輸入原則)
  - no: 中止,先執行 /speckit.review
  - run-review: 自動執行 /speckit.review 然後繼續
```

→ 選擇 **yes** 後跳到步驟 1-B (互動模式)

### 1-A. 自動模式 - 從 PROJECT_SUMMARY.md 提煉

**讀取並解析 PROJECT_SUMMARY.md**:

1. **提煉專案特定約束**:
   從 `## ⚙️ 專案特定約束 (為 Constitution 準備)` 章節提取:
   - 技術約束 (Technology Constraints)
   - 流程約束 (Process Constraints)
   - 合規約束 (Compliance Constraints)

2. **提煉專案背景**:
   從 `## 📋 專案概覽` 提取:
   - 專案名稱
   - 專案類型
   - 監理要求

3. **提煉關鍵指標**:
   從 `## 🛡️ 風險與控制` + `## 📊 技術約束` 提取:
   - 關鍵法規
   - SLA 目標
   - RTO/RPO
   - 資料保留期限

**生成憲法結構**:
```markdown
# 專案憲法 - [專案名稱]

## 第一部分: 通用原則 (Universal Principles)

### I. Single Source of Truth
[保留現有 10 大原則,不修改]

...

### X. Native Integration First
[保留現有 10 大原則,不修改]

## 第二部分: 專案特定約束 (Project-Specific Constraints)

> **專案類型**: [金融/醫療/一般企業]
> **監理等級**: [高/中/低]
> **生成時間**: [YYYY-MM-DD]
> **來源**: PROJECT_SUMMARY.md (審核版本 vX.Y.Z)

### XI. 技術約束 (Technology Constraints)

[從 PROJECT_SUMMARY.md 提煉]

**強制使用技術**:
- [技術 A]: [原因,來自 Bank Profile 哪個需求]
- [技術 B]: [原因]

**禁止使用技術**:
- [技術 C]: [原因]

**架構約束**:
- [約束 1]: [原因]

### XII. 流程約束 (Process Constraints)

[從 PROJECT_SUMMARY.md 提煉]

**強制審核點**:
- [審核點 A]: [在哪個流程,為什麼必要]
- [審核點 B]: [來自 30_risk_control.md 或 50_compliance.md]

**必要的人工介入**:
- [介入點 A]: [原因,通常來自法遵或風險要求]

### XIII. 合規約束 (Compliance Constraints)

[從 PROJECT_SUMMARY.md 提煉]

**不可妥協的法遵要求**:
- [法規 A] → [具體要求]: [原因]
- [法規 B] → [具體要求]: [原因]

**強制稽核項目**:
- [稽核項 A]: [保留期限 X 年,來自 60_audit.md]
- [稽核項 B]: [保留期限 Y 年]

**資料保護要求**:
- [要求 A]: [來自 40_infosec.md]

### XIV. 效能與可靠性約束 (Performance & Reliability Constraints)

[從 PROJECT_SUMMARY.md 提煉]

**強制 SLA**:
- 系統可用性: ≥ [99.X%] ([來自 70_nfr.md])
- 關鍵操作回應時間: < [X] 秒

**強制 RTO/RPO**:
- RTO: ≤ [X] 小時
- RPO: ≤ [Y] 分鐘 (或 0 - 不得遺失資料)

**容量需求**:
- 並行處理: ≥ [X] 筆/秒
- 儲存成長: 計畫 [X] 年,至少 [Y] TB

## 第三部分: 治理 (Governance)

### 憲法修正程序
[保留現有內容,不修改]

### 版本政策
- **當前版本**: v[X.Y.Z]
- **核定日期**: [YYYY-MM-DD]
- **最後修改**: [YYYY-MM-DD]

### 專案特定約束變更管理
- 第二部分 (XI-XIV) 可隨 Bank Profile 更新而調整
- 需執行 `/speckit.review` 驗證一致性
- 修改專案特定約束為 MINOR 版本升級
```

### 1-B. 互動模式 - 手動輸入原則

[保留現有的互動模式邏輯]

載入現有憲法模板 `.specify/memory/constitution.md`，識別所有 `[ALL_CAPS_IDENTIFIER]` 佔位符。
**重要**：使用者可能要求新增/刪減原本文檔中的原則數量。若使用者指定數量，請依該數量更新。

為每個佔位符收集/推導值：
- 若對話中有提供值、使用該值。
- 否則從 repo 上下文（README、文件、先前憲法版本）推導。
- `RATIFICATION_DATE` 若未知請詢問或標示 TODO（`TODO(RATIFICATION_DATE): explanation`）。
- `LAST_AMENDED_DATE` 若修改則填為今天；否則保留先前值。
- `CONSTITUTION_VERSION` 需依語義版本規則調整（MAJOR/MINOR/PATCH 說明在原文）—若不確定，先提出版本 bump 類型並說明原因再決定。

### 2. 草擬完成之憲法內容

**憲法結構** (兩部分):

1. **第一部分: 通用原則** (保留現有 10 大核心原則)
   - I. Single Source of Truth
   - II. Lightweight Sandboxing
   - III. Test-Driven Development
   - IV. YAGNI
   - V. Full Traceability
   - VI. Semantic Versioning
   - VII. Zero Trust & Least Privilege
   - VIII. Grounded AI & Prompt Injection Defense
   - IX. Native Integration First
   - X. [保留原有第十條]

2. **第二部分: 專案特定約束** (從 PROJECT_SUMMARY.md 自動生成)
   - XI. 技術約束
   - XII. 流程約束
   - XIII. 合規約束
   - XIV. 效能與可靠性約束

**版本升級規則**:
- 新增第二部分 (專案特定約束) → MINOR 版本升級 (例如: v2.0.0 → v2.1.0)
- 修改第一部分 (通用原則) → MAJOR 版本升級
- 修改第二部分內容 → PATCH 版本升級 (例如: v2.1.0 → v2.1.1)

### 3. 一致性傳播檢查（同步模板）

**檢查並更新以下模板**:

1. **`.specify/templates/spec-template.md`**:
   - 檢查是否需新增「專案特定約束」檢查清單
   - 確保 spec.md 會引用 constitution.md 的專案約束

2. **`.specify/templates/plan-template.md`**:
   - 檢查「Constitution Check」章節是否涵蓋專案特定約束
   - 確保 plan.md 驗證技術選型符合 constitution

3. **`.specify/templates/tasks-template.md`**:
   - 確保任務分類考量專案特定約束

4. **`.claude/commands/speckit.analyze.md`**:
   - 更新驗證邏輯,檢查 spec.md 是否符合 constitution 的專案特定約束

5. **`README.md` 和 `CLAUDE.md`**:
   - 更新憲法說明,提及兩部分結構

### 4. 產生同步影響報告

在 constitution.md 頂端插入 HTML 註解:

```html
<!--
Constitution Update Report
==========================
Date: YYYY-MM-DD HH:MM
Command: /speckit.constitution
Source: PROJECT_SUMMARY.md (審核版本 vX.Y.Z)

Version Change: v2.0.0 → v2.1.0
Reason: Added Project-Specific Constraints (Part II)

Changes:
  ✅ Part I (Universal Principles): No changes (preserved)
  ✅ Part II (Project-Specific Constraints): Added (auto-generated from PROJECT_SUMMARY.md)
    - XI. Technology Constraints (3 items)
    - XII. Process Constraints (2 items)
    - XIII. Compliance Constraints (5 items)
    - XIV. Performance & Reliability Constraints (4 items)

Template Sync Status:
  ✅ .specify/templates/spec-template.md - Updated
  ✅ .specify/templates/plan-template.md - Updated
  ⚠️ .claude/commands/speckit.analyze.md - Needs manual review
  ⚠️ README.md - Needs documentation update

Next Steps:
  1. Review generated constraints in Part II
  2. Update related documentation
  3. Execute /speckit.specify to start feature development
-->
```

### 5. 更新前驗證

**驗證清單**:
- [ ] 第一部分 (通用原則) 保持完整,未被修改
- [ ] 第二部分 (專案特定約束) 所有內容來自 PROJECT_SUMMARY.md
- [ ] 版本號正確升級 (MAJOR.MINOR.PATCH)
- [ ] 日期使用 ISO 8601 格式 (YYYY-MM-DD)
- [ ] 所有約束陳述清晰,可測試
- [ ] 無未說明的方括號佔位符
- [ ] 同步影響報告完整

### 6. 寫回 `.specify/memory/constitution.md`

覆寫現有檔案,保留 Git 歷史。

### 7. 輸出摘要給使用者

```
✅ 專案憲法已更新

📄 檔案位置: .specify/memory/constitution.md

📊 更新摘要:
  ✓ 版本: v2.0.0 → v2.1.0 (MINOR 升級)
  ✓ 升級原因: 新增專案特定約束 (Part II)

  第一部分: 通用原則 (Universal Principles)
    - 保持不變 (10 大核心原則)

  第二部分: 專案特定約束 (Project-Specific Constraints)
    ✅ XI. 技術約束 (3 項)
       - 強制使用: [技術 A, B]
       - 禁止使用: [技術 C]
       - 架構約束: [約束 1]

    ✅ XII. 流程約束 (2 項)
       - 強制審核點: [審核點 A, B]
       - 必要人工介入: [介入點 A]

    ✅ XIII. 合規約束 (5 項)
       - 法遵要求: [法規 A → 具體要求]
       - 稽核項目: [保留 7 年]

    ✅ XIV. 效能與可靠性約束 (4 項)
       - SLA: ≥ 99.5%
       - RTO/RPO: 4 小時 / 0 分鐘

🔄 模板同步狀態:
  ✅ spec-template.md - 已更新
  ✅ plan-template.md - 已更新
  ⚠️ speckit.analyze.md - 需手動檢視
  ⚠️ README.md - 需更新文檔

📋 建議 commit message:
  docs: update constitution to v2.1.0 (add project-specific constraints from Bank Profile)

💡 下一步:
  1. 檢視 constitution.md 確認專案約束正確
  2. 開始功能開發: /speckit.specify <功能描述>
  3. 所有 spec.md 將自動符合這些約束
```

## 格式與風格要求

- **保持標題層級**: 不調整 heading 等級
- **行寬限制**: 每行 ≤ 100 字元 (提高可讀性)
- **清除註解**: 不再需要的註解應刪除
- **待辦標記**: 若資訊缺失,使用 `TODO(<FIELD>): explanation`
- **可測試性**: 所有約束必須可驗證/可測試

## 特殊情境處理

### 情境: 使用者僅局部更新

若使用者僅修改部分原則 (例如: "請更新技術約束,改用 PostgreSQL"):
1. 讀取現有 constitution.md
2. 僅修改指定部分 (XI. 技術約束)
3. 執行 PATCH 版本升級 (v2.1.0 → v2.1.1)
4. 生成同步影響報告

### 情境: PROJECT_SUMMARY.md 過時

若 PROJECT_SUMMARY.md 審核時間 > 30 天:
```
⚠️ PROJECT_SUMMARY.md 已過時 (審核時間: YYYY-MM-DD,距今 X 天)

Bank Profile 可能已更新,建議重新審核。

是否繼續使用現有 PROJECT_SUMMARY.md? (yes/no/re-review)
  - yes: 繼續 (風險: 專案約束可能不是最新)
  - no: 中止,先更新 Bank Profile
  - re-review: 自動執行 /speckit.review 更新後繼續
```

## 與其他命令的整合

### 輸入
- `PROJECT_SUMMARY.md` (優先,從 /speckit.review 產出)
- 使用者互動輸入 (若無 PROJECT_SUMMARY.md)

### 輸出
- `.specify/memory/constitution.md` (更新後的憲法)
- 同步影響報告 (HTML 註解)

### 後續命令
- `/speckit.specify` - 生成 spec.md 時自動遵守 constitution
- `/speckit.analyze` - 驗證 spec.md 符合 constitution
- `/speckit.plan` - 技術選型需符合 constitution 的技術約束

## 注意事項

1. **保護通用原則**: 第一部分 (10 大原則) 除非有重大理由,否則不修改
2. **專案約束可變**: 第二部分隨 Bank Profile 更新而調整,屬於正常演進
3. **版本語義化**: 遵循 Semantic Versioning (MAJOR.MINOR.PATCH)
4. **可追溯性**: 所有專案約束需註明來源 (來自哪個 Bank Profile 文件)
5. **互動確認**: 自動模式仍需使用者確認生成的約束是否正確
