---
description: 根據可用設計產物（spec、plan、data-model、contracts 等）產生一份可執行、依賴順序排列且可供 LLM 直接執行的 `tasks.md`。
---

## 使用者輸入

```text
$ARGUMENTS
```

在繼續之前**必須**考慮使用者輸入（若非空）。

## 大綱

1. **設定**：執行一次：
```
.specify/scripts/bash/check-prerequisites.sh --json
```
解析 `FEATURE_DIR` 與 `AVAILABLE_DOCS`。所有路徑必為絕對路徑。

2. **載入設計文件**：從 FEATURE_DIR 讀取：
   - 必要：`plan.md`（技術棧、庫、結構）、`spec.md`（使用者故事與優先級）  
   - 可選：`data-model.md`、`contracts/`、`research.md`、`quickstart.md`  
   - 注意：根據可取得文件產生任務

3. **執行任務產生流程**：
   - 從 plan.md 擷取 tech stack 與專案結構  
   - 從 spec.md 擷取使用者故事（P1、P2、P3）  
   - 若 data-model 存在，將實體映射到使用者故事  
   - 若 contracts 存在，將 endpoint 映射到使用者故事  
   - 若 research.md 存在，將其決策映射為 setup 任務  
   - 依照「任務生成規則」為每個使用者故事產生完整任務  
   - 產生依賴圖、平行執行範例、並驗證每個 user story 都有完整任務以進行獨立測試

4. **生成 tasks.md**：依據 `.specify.specify/templates/tasks-template.md` 結構填寫：
   - 正確 feature 名稱  
   - Phase 1：Setup 任務  
   - Phase 2：Foundational（阻塞性前置）  
   - Phase 3+：依使用者故事（P1、P2..）逐個建立階段  
   - 最終 Phase：Polish 與跨切 concerns  
   - 所有任務必依嚴格 checklist 格式（見下）並附檔案路徑

5. **回報**：輸出 tasks.md 路徑與摘要：
   - 任務總數  
   - 每個 user story 的任務數  
   - 已辨識的平行機會  
   - 每個故事的獨立測試標準  
   - 建議 MVP 範圍（通常為 User Story 1）

**關鍵：產出的 tasks.md 必須立刻可執行—每個任務需夠具體，LLM 可在無其他上下文下完成。**

## 任務生成規則（關鍵）

**嚴格**：任務必須按 user story 組織。

**測試任務為選用**：僅當 spec 要求或使用者明確要求 TDD 才生成。

### Checklist 格式（**必需**）

每個任務都必須遵循此格式：

```text
- [ ] [TaskID] [P?] [Story?] Description with file path
```

格式組成：

1. `- [ ]`（checkbox）  
2. Task ID：順序編號（T001, T002...）  
3. `[P]`（僅當任務可平行時加入）  
4. `[Story]`（User story 任務必需）例如 `[US1]`、`[US2]`；Setup/Foundational/Polish 階段無 story label  
5. 描述：具體動作與精確檔案路徑

**範例正確：**

- `- [ ] T001 Create project structure per implementation plan`  
- `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py`  
- `- [ ] T012 [P] [US1] Create User model in src/models/user.py`

**錯誤示例**：缺少 ID、缺少檔案路徑或缺 checkbox 都會被視為不合格。

### 任務組織

1. **以使用者故事為主**：每個故事（P1,P2..）一個階段，映射其所需的模型、服務、端點、UI、測試（若請求）。  
2. **從 contracts 對應 endpoint → user story**。  
3. **從 data model 將實體映到 stories；若多個故事共用實體，放在最早需要的故事或 Setup 階段**。  
4. **Setup/Infrastructure → Phase 1；Foundational → Phase 2；Story-specific setup → 該故事階段**。

### 階段範例

- Phase 1：Setup（初始化）  
- Phase 2：Foundational（阻塞性）  
- Phase 3+: User Stories（P1, P2）→ 每個故事內部：Tests（若需要）→ Models → Services → Endpoints → Integration  
- Final Phase：Polish & Cross-Cutting
