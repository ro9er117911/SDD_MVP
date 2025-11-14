---
description: 從互動或提供的原則輸入建立或更新專案憲法（`.specify/memory/constitution.md`），並確保所有相依模板同步。
---

## 使用者輸入

```text
$ARGUMENTS
```

在執行前**必須**考慮使用者輸入（若非空）。

## 大綱

你將更新 `.specify/memory/constitution.md`（專案憲法）。該檔為模板，含有方括號佔位符（例如 `[PROJECT_NAME]`、`[PRINCIPLE_1_NAME]`）。你的任務是：(a) 收集或推導具體值、(b) 精確填入模板、(c) 將修改影響傳播到相依 artifact。

執行流程：

1. 載入現有憲法模板 `.specify/memory/constitution.md`，識別所有 `[ALL_CAPS_IDENTIFIER]` 佔位符。  
   **重要**：使用者可能要求新增/刪減原本文檔中的原則數量。若使用者指定數量，請依該數量更新。  

2. 為每個佔位符收集/推導值：
   - 若對話中有提供值、使用該值。  
   - 否則從 repo 上下文（README、文件、先前憲法版本）推導。  
   - `RATIFICATION_DATE` 若未知請詢問或標示 TODO（`TODO(RATIFICATION_DATE): explanation`）。  
   - `LAST_AMENDED_DATE` 若修改則填為今天；否則保留先前值。  
   - `CONSTITUTION_VERSION` 需依語義版本規則調整（MAJOR/MINOR/PATCH 說明在原文）—若不確定，先提出版本 bump 類型並說明原因再決定。

3. 草擬完成之憲法內容：
   - 以具體文字替換所有佔位符（除非有意保留某些待定占位，需在報告中說明）。  
   - 每條原則需包含名稱、不可協商規則要點，以及簡短理由。  
   - Governance 段應包含修正程序、版本政策與合規審查預期。

4. 一致性傳播檢查（同步模板）：
   - 讀取 `.specify/templates/plan-template.md`，檢查與新憲法是否一致（若憲法新增強制項目，plan-template 需反映）。  
   - 讀取 `.specify/templates/spec-template.md`，檢查是否需新增或移除必填節。  
   - 讀取 `.specify/templates/tasks-template.md`，確保任務分類與新原則一致（例如：觀察性、版本政策等）。  
   - 檢查 `.specify/templates/commands/*.md` 中是否存在過時引用（例如 agent 專屬命名）並更新。  
   - 檢查 README / docs/quickstart.md 等 runtime 指導文件，更新必要參考。

5. 產生同步影響報告（在更新後以 HTML 註解置於憲法檔案頂端）：
   - 版本變化：old → new  
   - 修改或重新命名的原則清單  
   - 新增/刪除部分清單  
   - 需要手動更新的模板檔路徑（✅ 已更新 / ⚠ pending）  
   - 未定義但保留的佔位符與後續 TODO

6. 更新前驗證：
   - 不可殘留未說明之方括號 token（除非有合理保留並於報告中標註）。  
   - 版本行與報告一致。  
   - 日期使用 ISO YYYY-MM-DD。  
   - 原則須為陳述式、可被測試，避免模糊語（視情況 `should` → 改寫為 MUST/SHOULD 並加上理由）。

7. 寫回 `.specify/memory/constitution.md`（覆寫）。

8. 輸出摘要給使用者：
   - 新版本號與升級理由。  
   - 需要手動追蹤的檔案清單。  
   - 建議 commit message（例如：`docs: amend constitution to vX.Y.Z (principle additions + governance update)`）。

格式與風格要求：

- 保持模板的標題層級（不要調整 heading 等級）。  
- 在註明理由時每行最好在 100 字以內換行（可讀性）。  
- 刪除註解當不再需要。  
- 若部分資訊缺失（如 ratification date 真正未知），插入 `TODO(<FIELD_NAME>): explanation` 並在 Sync Impact Report 中列為 deferred。

若使用者僅提供局部更新（例如只改一條原則），仍需執行驗證與版本決議步驟。
