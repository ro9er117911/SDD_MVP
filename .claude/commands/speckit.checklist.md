---
description: 依據目前 feature（功能）產生自訂檢查清單（Checklist）。
---

## 檢查表目標：「英語需求的單元測試（Unit Tests for English）」

**關鍵概念**：檢查表本質上是「需求寫作的單元測試」— 驗證需求的品質、清晰度與完整度。

**不是用來驗證實作/測試系統行為**：

- ❌ 不是「確認按鈕點擊正確」  
- ❌ 不是「測試錯誤處理」  
- ❌ 不是「確認 API 回傳 200」  
- ❌ 不是比對程式/實作是否吻合 spec

**而是用來驗證需求的品質**：

- ✅ 是否為所有卡片類型定義視覺層級？（完整性）  
- ✅ “prominent display” 是否以具體大小/位置量化？（清晰性）  
- ✅ hover 狀態需求是否一致？（一致性）  
- ✅ 是否定義鍵盤導覽的無障礙需求？（覆蓋）  
- ✅ 是否定義 logo 圖片載入失敗時的 fallback？（邊界）

**比喻**：如果規格是用英文寫的程式碼，檢查表就是那套單元測試。它測試的是「需求本身」是否已寫好、完整、無歧義、可被實作，而不是測試實作。

## 使用者輸入

```text
$ARGUMENTS
```

在繼續之前**必須**考慮使用者輸入（若非空）。

## 執行步驟

1. **設定**：從 repo root 執行一次：
```
.specify/scripts/bash/check-prerequisites.sh --json
```
解析 JSON 取得 FEATURE_DIR 與 AVAILABLE_DOCS 清單（皆為絕對路徑）。注意單引號的逃脫示例。

2. **釐清意圖（動態）**：產生最多三個初步的釐清問題（非固定題庫），這些問題必須：
   - 從使用者文本與 spec/plan/tasks 中擷取訊號  
   - 僅詢問會實質改變檢查表內容的資訊  
   - 若 `$ARGUMENTS` 已明確，則跳過該問題  
   - 每題須精準，不需過多泛問

   產生問題的演算法（簡述）：
   - 擷取關鍵領域字（auth、latency、UX、API 等）與風險指標  
   - 將訊號聚成候選焦點（最多 4 類）  
   - 推斷使用對象與時間點（作者、Reviewer、QA、release）  
   - 偵測缺失維度（範圍深度、風險強度、可量化驗收準則等）  
   - 形成問題類型（範圍、風險優先、深度校準、受眾、排除邊界、場景類別差缺）

   問題格式規則：
   - 若提供選項，產生一個緊湊表格（Option | Candidate | 為何重要）  
   - 選項上限 A–E；若自由回覆更合適則不出表格  
   - 不要要求使用者重述已說明的事  
   - 若不確定，直接詢問：`確認 X 是否屬於範圍？`  

   若無互動可能，預設：
   - 深度：Standard  
   - 受眾：Reviewer（若為程式相關），否則 Author  
   - 焦點：Top 2 relevance clusters

   輸出問題（標為 Q1/Q2/Q3）。若回答後仍有 ≥2 類未決定，可再問最多兩題（Q4/Q5）並在每題附一行理由。最多 5 題。若使用者拒絕更多問題則停止。

3. **理解使用者需求**：結合 `$ARGUMENTS` 與釐清答案：
   - 推導檢查表主題（安全、審查、部署、UX 等）  
   - 合併使用者明確要求的 must-have 項目  
   - 將焦點映成分類骨架  
   - 從 spec/plan/tasks 推斷缺失（不可臆測）

4. **載入功能上下文**：從 FEATURE_DIR 讀取：
   - spec.md：功能需求與範圍  
   - plan.md（若存在）：技術細節、相依  
   - tasks.md（若存在）：實作任務

   載入策略：
   - 僅讀取與焦點相關的必要片段（避免 dump）  
   - 長段落以簡潔的情境彙整代替全文嵌入  
   - 若檔案過大，用 interim summary 代替 raw text

5. **產生檢查表** — 創建「驗證需求品質的單元測試」：
   - 在 FEATURE_DIR 建立或使用 `checklists/` 資料夾  
   - 生成檔名為 `[domain].md`（例如 `ux.md`、`api.md`）  
   - 若檔案存在，會 append；每次執行**都會**產生新檔（不覆寫既有檔）  
   - 編號 CHK001 起，逐條產出  
   - 每項需聚焦於規格文字本身的品質（完整性、清晰性、一致性、可測量性、覆蓋度）

   **分類結構**：
   - Requirement Completeness（需求完整性）  
   - Requirement Clarity（需求清晰）  
   - Requirement Consistency（需求一致性）  
   - Acceptance Criteria Quality（驗收標準品質）  
   - Scenario Coverage（場景覆蓋）  
   - Edge Case Coverage（邊界情況）  
   - Non-Functional Requirements（非功能）  
   - Dependencies & Assumptions（相依與假設）  
   - Ambiguities & Conflicts（模糊與衝突）

   **檢查項目寫法原則**（測試需求文字，不是實作）：
   - 問題型句子，註明品質維度（[Completeness] etc.）  
   - 若檢查現有 spec 節，請以 `[Spec §X.Y]` 引用  
   - 若缺失，標示 `[Gap]`

   範例：  
   - 完整性：`"Are error handling requirements defined for all API failure modes? [Gap]"`  
   - 清晰性：`"Is 'fast loading' quantified with specific timing thresholds? [Clarity]"`  
   - 一致性：`"Do navigation requirements align across all pages? [Consistency]"`  
   - 覆蓋性：`"Are requirements defined for zero-state scenarios (no items)? [Coverage]"`  
   - 可測性：`"Are visual hierarchy requirements measurable? [Measurability]"`

6. **輸出格式**：若存在 `.specify/templates/checklist-template.md`，遵循該模板；否則採用下列格式：
   - H1 標題、目的/建立 metadata 行、`##` 分類區塊，每項用 `- [ ] CHK### <檢查項目>`，ID 從 CHK001 開始

7. **回報**：輸出建立檔案的完整路徑與項目數，提醒使用者每次執行會產生新檔。匯總：
   - 選定焦點  
   - 深度層級  
   - Actor / timing  
   - 已納入使用者指定之 must-have 項目

## 範例檢查表類型與樣本項目

**UX（ux.md）**：  
- `- [ ] CHK001 - 視覺層級需求是否以可衡量方式定義？ [Clarity, Spec §FR-1]`  
- `- [ ] CHK002 - 互動狀態（hover, focus）是否一致定義？ [Consistency]`  
- `- [ ] CHK003 - 無障礙（keyboard）需求是否明確？ [Coverage, Gap]`

**API（api.md）**：  
- `- [ ] CHK001 - 是否為所有失敗情境定義錯誤回應格式？ [Completeness]`  
- `- [ ] CHK002 - Rate limiting 閾值是否量化？ [Clarity]`

**Performance（performance.md）**、**Security（security.md）** 同理。

## 反例（不得做的事）

- 切記：**不要**把「執行測試」或「驗證實作」當作檢查項；檢查項皆應為「是否撰寫/定義好」的問題，而非動作測試。
