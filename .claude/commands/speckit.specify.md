---
description: 由自然語言功能描述產生或更新功能規格檔（feature specification）。
---

## 使用者輸入

```text
$ARGUMENTS
```

觸發 `/speckit.specify` 時使用者在命令後所輸入的文本即為功能描述。假定該描述總是可得（除非為空），執行下列流程。

## 流程總覽

1. **產出簡短分支名稱（2–4 字）**：從功能描述擷取關鍵詞，產出 action-noun 的短名，例如 `user-auth`、`oauth2-api-integration`。  
2. **檢查既有分支**：先 `git fetch --all --prune`，比較遠端/本地分支以及 specs 目錄裡的數字編號，決定下一個可用編號，並以 `.specify/scripts/bash/create-new-feature.sh --json` 建立新分支（詳見原文）。  
   - 注意：只在短名相同的情況下匹配編號；若未找到則從 1 開始。  
3. 載入 `.specify/templates/spec-template.md` 了解必填段落。  
4. 執行下列步驟生成 spec：
   1. 解析使用者描述（若為空則 ERROR）  
   2. 擷取 actor、action、data、constraints  
   3. 對不清楚處做合理猜測或標注 `[NEEDS CLARIFICATION]`（上限 3 個），優先次序：scope > security/privacy > UX > tech details  
   4. 填寫 User Scenarios & Testing（若無法推斷 user flow 則 ERROR）  
   5. 生成可測試的功能性需求（Functional Requirements）  
   6. 定義 Success Criteria（可衡量、技術中立、可驗證）  
   7. 識別主要實體  
   8. 回傳 SUCCESS（spec ready for planning）

5. 將填寫好的 spec 寫入 SPEC_FILE（使用模板順序與標題）。  
6. **規格品質驗證**：產生 `FEATURE_DIR/checklists/requirements.md`（spec quality checklist），並以 checklist 驗證 spec（若有不合項目則修正、重驗，最多 3 次迴圈；若仍失敗，記錄問題與警告）。

### 規格品質檢查清單（概要）
- 無實作細節（framework、API 等）  
- 專注於使用者價值  
- 為非技術利害關係人撰寫  
- 必要段落完成  
- `[NEEDS CLARIFICATION]` 不超過 3 個  
- 要件為可測、無歧義  
- 成功標準可量化、技術中立  
- 使用場景、邊界、相依與假設已列出

若所有檢查項都通過，標記 checklist 完成並進入下一步（`/speckit.clarify` 或 `/speckit.plan`）。

**注意**：此腳本會建立並切換到新的 branch 並初始化 spec 檔然後寫入。
