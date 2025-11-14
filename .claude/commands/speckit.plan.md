---
description: 使用 plan 模板執行實作規劃工作流程，以生成設計產物。
---

## 使用者輸入

```text
$ARGUMENTS
```

**必須**考慮使用者輸入（若非空）。

## 大綱

1. **設定**：執行 `.specify/scripts/bash/setup-plan.sh --json`（一次），解析 JSON 取得 `FEATURE_SPEC`、`IMPL_PLAN`、`SPECS_DIR`、`BRANCH`。注意單引號逃脫樣例。

2. **載入上下文**：讀取 `FEATURE_SPEC` 與 `.specify/memory/constitution.md`。載入 `IMPL_PLAN` 模板（已 copy）。

3. **執行計畫工作流程**：依 `IMPL_PLAN` 模板結構：
   - 填入技術上下文（未明事項標註 "NEEDS CLARIFICATION"）  
   - 填入憲法檢查段（由 constitution 得出）  
   - 評估門檻（若違規則 ERROR）  
   - Phase 0：產出 research.md（解決所有 NEEDS CLARIFICATION）  
   - Phase 1：產出 data-model.md、contracts/、quickstart.md 等  
   - Phase 1：透過 agent script 更新 agent context  
   - 設計完成後重新評估 Constitution Check

4. **停止並回報**：命令在 Phase 2 planning 後結束。回報 branch、IMPL_PLAN 路徑與已產生的 artifact。

## 階段說明

### Phase 0：輪廓與研究

1. 從技術上下文抽出 unknowns：為每個 NEEDS CLARIFICATION 建立研究任務。  
2. 產出研究代理任務（每個 unknown 及 technology choice 分別建立研究任務）。  
3. 將結果整合於 `research.md`，格式：
   - Decision: [選擇]  
   - Rationale: [選擇理由]  
   - Alternatives considered: [其他可行方案]

**輸出**：research.md，解決所有 NEEDS CLARIFICATION

### Phase 1：設計與契約

**先決條件**：`research.md` 完成

1. 從 feature spec 擷取實體 → 產出 `data-model.md`：實體名稱、欄位、關聯、驗證規則、狀態轉換。  
2. 從功能需求產出 API contracts（REST/GraphQL），輸出到 `/contracts/`（OpenAPI / GraphQL schema）。  
3. 更新 Agent context（呼叫腳本示例 `.specify/scripts/bash/update-agent-context.sh claude`）以同步 agent-specific context file。

**輸出**：`data-model.md`、`/contracts/*`、`quickstart.md`、agent-specific file

## 主要規則

- 使用絕對路徑。  
- 若有 gate 失敗或未解決的釐清事項，回報 ERROR 並停止。
