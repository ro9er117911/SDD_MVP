---
description: 依據實作計畫（plan.md）處理並執行 tasks.md 中定義的所有任務以執行實作。
---

## 使用者輸入

```text
$ARGUMENTS
```

在繼續前**必須**考慮使用者輸入（若非空）。

## 大綱

1. 從 repo root 執行一次：
```
.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
```
解析 FEATURE_DIR 與 AVAILABLE_DOCS（絕對路徑）。注意單引號逃脫示例。

2. **檢查檢查表狀態（若 FEATURE_DIR/checklists/ 存在）**：
   - 掃描 `checklists/` 下所有檔案。對每個檔案計算：總項目數（`- [ ]` / `- [X]` / `- [x]`）、已完成數、未完成數。  
   - 產生狀態表格：

     ```
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     ```

   - 計算整體狀態：
     - **PASS**：所有 checklist 未完成項為 0。  
     - **FAIL**：一或多個 checklist 有未完成項。

   - **若任一 checklist 不完備**：
     - 顯示表格並 **中止**，詢問：「Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)」  
     - 需等使用者回應。若回答 `no`/`wait`/`stop` → 停止；若回答 `yes`/`proceed`/`continue` → 繼續到下一步。  
   - **若所有 checklist 通過**：顯示表格並自動進入下一步。

3. 載入與分析實作上下文：
   - **必須**讀取 `tasks.md`（完整任務清單與執行計畫）  
   - **必須**讀取 `plan.md`（技術棧、架構與檔案結構）  
   - 若存在則讀取 `data-model.md`、`contracts/`、`research.md`、`quickstart.md`

4. **專案設定驗證**：
   - 檢查 repo 是否為 git（`git rev-parse --git-dir`），若是則建立或驗證 `.gitignore`。  
   - 根據 plan.md 中提及的技術檢查並建立必要的 ignore 檔（`.dockerignore`、`.eslintignore` 等）或補上常見 patterns。  
   - 若 ignore 已存在，確保包含必要樣板，若缺則 append。

   常見技術樣板（摘要：Node/Python/Java/... 以及工具特定 patterns）— 若 plan.md 指出技術，請套用相應模板。

5. 解析 `tasks.md` 結構並擷取：
   - 任務階段（Setup、Tests、Core、Integration、Polish）  
   - 任務依賴（順序 vs 平行）  
   - 任務細節（ID、描述、檔案路徑、平行標記 [P]）  
   - 執行流程（順序與依賴）

6. 按計畫執行實作：
   - 逐階段執行（階段完成才進下一階段）  
   - 遵守依賴（順序任務依序執行；標記 [P] 的任務可併行）  
   - 採 TDD（若有需要，先執行測試任務再實作）  
   - 檔案衝突之任務須順序執行  
   - 每階段完成後進行驗證檢查點

7. 實作執行原則：
   - 先做 Setup（專案結構、依賴）  
   - 測試先於程式碼（若須撰寫合約/實體/整合測試）  
   - 核心開發（model、service、CLI、endpoint）  
   - 整合（DB、middleware、logging、外部服務）  
   - polish（單元測試、效能優化、文件）

8. 進度追蹤與錯誤處理：
   - 每完成一個任務回報進度  
   - 若任何非平行任務失敗則停止  
   - 平行任務中若有失敗則繼續其他成功者並回報失敗項  
   - 提供明確錯誤訊息與 debug 建議  
   - 已完成任務請標記 `- [X]` 在 `tasks.md`

9. 完成驗證：
   - 確認所有必要任務完成  
   - 檢查實作是否符合原始規格  
   - 驗證測試通過並達到覆蓋要求  
   - 確認實作吻合 plan.md  
   - 最終回報完成狀態摘要

**備註**：此命令假設 `tasks.md` 已完整。若任務缺漏，建議先執行 `/speckit.tasks` 以產生完整任務列表。
