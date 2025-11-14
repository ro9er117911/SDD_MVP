---
description: 偵測當前功能規格中規格不足或不明確處，並提出最多 5 個精準釐清問題，並把答案寫回規格中。
---

## 使用者輸入

```text
$ARGUMENTS
```

在繼續之前**必須**考慮使用者輸入（若非空）。

## 概要

目標：偵測並降低在作用中功能規格的模糊或遺漏決策點，並把釐清結果直接記錄回 spec 檔。  
注意：此釐清流程預期在執行 `/speckit.plan` 前完成。若使用者明確表示要跳過釐清（例如探索性 spike），可以繼續但需警告後續返工風險。

## 執行步驟

1. 執行一次檢查腳本（`--paths-only` 模式）：
```
.specify/scripts/bash/check-prerequisites.sh --json --paths-only
```
解析回傳 JSON 的最小欄位：`FEATURE_DIR`、`FEATURE_SPEC`（以及可選的 `IMPL_PLAN`、`TASKS`）。若 JSON 解析失敗，終止並要求使用者先執行 `/speckit.specify` 或確認 feature branch 環境。

（同樣注意單引號的 shell 逃脫用法示例）

2. 載入當前 spec 檔，使用下列分類掃描模糊度與覆蓋度，對每個分類標示狀態：Clear / Partial / Missing。建立內部優先清單（此清單不用直接輸出，除非不會提問）。

**檢查分類**（每項標註 Clear/Partial/Missing）：

- 功能範圍與行為（核心用戶目標、out-of-scope、角色差異）  
- 領域與資料模型（實體、屬性、唯一性、生命週期）  
- 互動與 UX 流（主要使用情境、錯誤/empty/loading 狀態、無障礙與在地化）  
- 非功能屬性（效能、可擴展性、可靠性、可觀察性、資安/隱私、合規）  
- 整合與外部依賴（外部服務、匯入/匯出格式、協定/版本假設）  
- 邊界情況與失敗處理（負場景、速率限制、衝突解法）  
- 限制與取捨（語言/儲存/託管）  
- 術語與一致性（術語表、避免同義詞）  
- 完成訊號（DoD/驗收是否可測）  
- 其他 / 占位符（TODO、含糊形容詞等）

對於 Partial 或 Missing 類別，會產生一個候選釐清問題（除非該問題不會實質改變實作/驗證或屬於後續 plan 階段再問）。

3. 生成最多 5 題優先釐清問題（內部排序）。輸出限制與規則：

- 最多 10 題在整個會話中（此回合最多 5 題）。  
- 每題必須可以用以下二類答案回答：  
  - 多選（2–5 個互斥選項），或  
  - 一個單字或短語（≤5 字）  
- 僅包含會實質影響架構、資料模型、任務分解、測試設計、UX 或合規的問題。  
- 避免問已被回答、瑣碎偏好或計畫層執行細節（除非阻斷正確性）。  
- 若未解決之類別超過 5 個，依 Impact * Uncertainty 取 top 5。

4. **逐題互動問答循環（一次一題）**：

- 每次僅展示 **一題**。  
- 對於多選題：  
  - **先給出推薦選項**（`**Recommended:** Option [X] - <簡短理由>`），然後用 Markdown 表格列出所有選項（Option | Description）。  
  - 表格下方附上：「你可以回覆選項字母（例如 'A'）、接受推薦輸入 'yes' 或 'recommended'，或提供你自己的短答」。  
- 對於短答題：  
  - 顯示 `**Suggested:** <建議答案> - <簡短理由>`，並提示：「格式：短答（<=5 字）。你可以回覆 'yes' 或 'suggested' 接受建議，或提供你自己的短答」。  
- 使用者回答後：  
  - 若回覆 'yes'/'recommended'/'suggested' → 採用先前建議答案。  
  - 若提供其他答案 → 驗證該答案對應到選項或符合 ≤5 字限制；若不清楚則要求快速釐清（此次問題不算新題）。  
  - 驗證妥當後，將答案暫存於記憶（尚不寫檔），繼續下一題。  
- 問題終止條件：  
  - 所有重要模糊已解（剩餘佇列皆非必要），或  
  - 使用者指示結束（"done"、"good"、"no more"），或  
  - 已問 5 題。  
- 嚴格規定：**不得在一開始揭露後續問題清單**。

若起始時沒有可問的有效問題，直接回報「無重大模糊需要正式釐清」。

5. **每題接受答案後的即時整合（增量更新）**：

- 在記憶中維護 spec 的表示與原始內容。  
- 第一次整合答案時：若 spec 尚無 `## Clarifications` 區塊，則在最高層級附議題後建立 `## Clarifications`，並在內部以 `### Session YYYY-MM-DD` 子標題建立今日會話紀錄（若已存在則直接使用）。  
- 在該 session 子標題下 append 一行：`- Q: <question> → A: <final answer>`。  
- 依答案類型將釐清結果寫回相應區塊（**立即**更新記憶並寫回檔案）：
  - 功能模糊 → 更新/新增 Functional Requirements。  
  - 互動/角色模糊 → 更新 User Stories / Actors。  
  - 資料形狀模糊 → 更新 Data Model。  
  - 非功能模糊 → 在 Non-Functional / Quality Attributes 新增具體可衡量指標。  
  - 邊界模糊 → 新增 Edge Cases / Error Handling 條目。  
  - 術語衝突 → 正規化術語（若保留原詞，在括號標示 `(formerly "X")`）。  
- 若釐清使先前內容失效，替換舊敘述，勿重複保留矛盾說法。  
- 每次整合均**寫回 spec 檔（atomic overwrite）**，以避免 context loss。  
- 保持格式（不重排無關區塊），新增內容須精簡且可測試。

6. **驗證（在每次寫檔後與最終回合）**：

- Clarifications session 每個接受答案只新增一行（避免重複）。  
- 本次 session 問題數 ≤ 5。  
- 已更新的段落不應再含有新答案原本要解決的佔位符。  
- 無遺留相互矛盾敘述。  
- Markdown 結構有效，只新增 `## Clarifications` 與 `### Session YYYY-MM-DD` 這兩種 allowed heading。  
- 術語一致（統一 canonical term）。

7. **寫回更新後的 spec**（寫檔至 FEATURE_SPEC）。

8. **完成回報**：

- 已問且回答的問題數。  
- 更新後 spec 路徑。  
- 變動過的 sections（列出）。  
- 針對每個 taxonomy 類別列出狀態：Resolved / Deferred / Clear / Outstanding。  
- 若有 Outstanding / Deferred，建議是否繼續 `/speckit.plan` 或稍後再跑 `/speckit.clarify`。  
- 建議下一步命令。

**行為規則摘要**：

- 若無重要模糊則回報「無需進一步釐清」。  
- 若 spec 缺失，提醒先跑 `/speckit.specify`。  
- 絕不超出 5 題限制。  
- 避免問會造成低價值的題目（除非阻斷實作）。  
- 尊重使用者提前終止訊號。
