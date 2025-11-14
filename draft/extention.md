

## 一、問題診斷（中型銀行 IT 需求流程）

典型痛點直接列出：

* 需求輸入分散：BRD、簡報、會議紀錄、Line、Email 全部都有，格式不一。
* 來回溝通成本高：業務只講「我要 RPA/AI 自動化」，IT 要追問流程細節、例外情境、權限分級。
* 資安 / 法遵 / 稽核 / 封控多為「後面才被找來」，晚進場導致：

  * 已開發一半才發現不符資安或法遵，重工。
  * 不同專案審查標準不一致，全靠人記憶。
* 文檔斷層：BRD 語言是「業務」，SDD 語言是「技術」，中間缺一層穩定 mapping，Dev 拿到 SDD 時，很多隱含業務假設已經消失。

結論：你要的是「前置需求對齊層 + 後段 SDD 技術層」的一致運轉，而不是把所有東西硬壓進 SDD 三檔 spec/plan/tasks 裡。

---

## 二、是否一定要 SDD？結構上的答案

定位清楚：

* SDD（spec / plan / tasks）本質上是「**工程實作層的規格語言**」：

  * 解決「LLM / 開發團隊怎麼落實這個需求」。
  * 強項：TDD、SbE、Given-When-Then、原子任務切割。
* 銀行內部需求對齊工具要處理的是「**多部門治理 + 業務流程定調**」：

  * 需要顯式把「流程、資安、法遵、稽核、封控」拉到同一個 canvas 上。

因此：

* 不需要把「流程.md / 資安.md / 法遵.md」塞進 spec.md。
* 應該設計為：
  **上層：Bank Requirement Profile（多個 markdown 模組）
  下層：SDD spec / plan / tasks，從上層自動生成或引用**

也就是：**SDD 是底層引擎與格式標準，不是唯一文件切面。**

---

## 三、文件結構設計：銀行版 SDD Profile

設計一個「Bank SDD Profile」層，定義專案目錄與檔案角色：

```text
/project-xyz/
  00_meta.md              # 專案基本資料、利害關係人、優先順序
  10_business.md          # 業務目標、KPI、客戶旅程摘要
  20_process.md           # As-Is / To-Be 流程、例外情境
  30_risk_control.md      # 風險、控制點、RACI
  40_infosec.md           # 資安需求、權限矩陣、資料分級
  50_compliance.md        # 法遵依據（個資法、洗錢防制、金管會指引…）
  60_audit.md             # 稽核可稽性需求（log、報表、留存）
  70_nfr.md               # 非功能需求（SLA、RTO/RPO、性能、可用性）
  ---
  spec.md                 # 結構化功能/非功能規格（SDD）
  plan.md                 # 系統設計、API、資料模型、架構（SDD）
  tasks.md                # 任務分解，對應 backlog / ticket（SDD）
```

概念：

* `10~70_xxx.md`：面向業務 + 管理 + 資安/法遵的「需求對齊層」。
* `spec/plan/tasks.md`：面向工程的「執行層」，**由上層文件驅動生成**，而不是獨立各寫各的。

---

## 四、Minimal runnable example：單一專案的 *.md 長什麼樣（簡化版）

### 1. `20_process.md`（流程）

```markdown
# 20_process.md - As-Is / To-Be 流程

## 1. As-Is 流程（簡述）
- 觸發條件：分行理專收到企業客戶來電要求調整額度
- 步驟：
  1. 理專填寫 Excel 表單，Email 給授信審查單位
  2. 審查人員人工查詢三個系統（核心系統 / 往來記錄 / 授信限額）
  3. 完成後回寄 Email，理專再通知客戶

## 2. To-Be 流程（目標）
- 由「授信調整申請表單系統」取代 Excel + Email

### 主流程（Happy Path）
1. 理專於前台系統選擇客戶，填寫調整申請
2. 系統自動查詢三套系統彙總風險指標
3. 超過閾值時，自動送審至授信審查單位
4. 審查通過後，自動寫回核心系統並通知理專及客戶

### 主要例外情境
- E1：客戶資料不完整 → 導回理專補件
- E2：風險指標超過上限 → 直接拒絕並保留紀錄
```

### 2. `40_infosec.md`（資安）

```markdown
# 40_infosec.md - 資安與權限需求

## 1. 資料分級
- 客戶基本資料：機密
- 授信額度與往來紀錄：高度機密
- 稽核紀錄與審查意見：高度機密

## 2. 身分與存取管理
- 角色：
  - RM（理專）：僅可存取自己轄內客戶資料
  - CA（授信審查）：可存取授信相關資料，但不可編輯客戶主檔
- 必須整合 AD / SSO，禁止共用帳號

## 3. 日誌與追蹤
- 所有調整申請必須記錄：
  - 發起人、審批人、審批時間
  - 調整前後額度、系統自動產生的風險指標
- Log 保留至少 7 年，支援稽核查詢

## 4. 技術與合規要求（輸出給 plan/spec）
- 強制使用 HTTPS / TLS 1.2+
- 資料庫中高度機密欄位需加密 at-rest
- 外部 API 需有 IP 白名單與 API Key 管控
```

接著，`spec.md` 裡的 feature / scenario 就可以直接引用、連結這兩份文件，而不是重寫一次。

---

## 五、流程設計：需求對齊 → SDD → 開發

設計一條清晰的端到端流程，避免模糊地帶：

1. **輸入階段**

   * 接受 BRD / 需求簡報 / 會議紀錄。
   * 由「需求對齊工具」將這些原始輸入整理成 `00~70_xxx.md` 的草稿版（可透過 LLM 協助）。

2. **跨部門對齊階段**

   * 業務單位負責 `10_business.md / 20_process.md`。
   * 資安負責 `40_infosec.md`。
   * 法遵負責 `50_compliance.md`。
   * 稽核負責 `60_audit.md`。
   * IT 架構 / Infra 負責 `70_nfr.md`。
   * 工具層只允許在這些檔案裡修改，維持格式一致。

3. **Gate / 準入條件**

   * 所有上述 *.md 必須達到「最低完成度定義（DoR for Dev）」：

     * 必填段落不得為空（如資料分級、主要例外情境）。
     * 關鍵欄位採選項（Critical / High / Medium / Low）避免自由發揮。
   * 未達標 → 不建立 Dev Ticket / 不進入 SDD 階段。

4. **SDD 生成階段**

   * 根據 `20_process.md` + `40_infosec.md` + `70_nfr.md`：

     * 自動生成 `spec.md` 的 Gherkin 情境骨架。
     * 自動生成 `plan.md` 的 API / 模組清單草稿。
   * `tasks.md` 由 `spec/plan` 推導出 backlog（feature → story → task），保留映射關係。

5. **開發與變更管理**

   * 開發過程中的所有變更，必須回寫：

     * 若改功能 → 更新 `spec.md`。
     * 若改流程 / 權限 → 需要同步更新 `20_process.md / 40_infosec.md`，並要求相關部門再確認。

---

## 六、治理與維護：解決「模板沒人維護」問題

避免「自己生一堆 markdown 模板，三個月後就爛掉」，要把「模板維護」當成組織職責，而不是個人興趣專案。

具體設計：

1. **Owner 設定**

   * 建議：由「企業架構 / IT PMO / 需求管理辦公室」擔任 `Bank SDD Profile` 的 owner。
   * 各專案只能實例化模板，不得任意改動模板結構（欄位名稱、順序）。

2. **版本控制**

   * 模板以版本管理，例如：

     * `/templates/bank_sdd_profile/v1/…`
     * `/templates/bank_sdd_profile/v2/…`
   * 新專案只能用最新版本；既有專案標記自己用的模板版本，避免中途變更。

3. **變更流程**

   * 調整模板層級欄位（例如新增「AI Model Risk」段落）時：

     * 先開一個小型變更提案（ADR / RFC）。
     * 經過資安 / 法遵 / 稽核 / IT 代表審核後，才釋出 `vX+1`。
   * 工具端（SDD_MVP / Teams Bot）只要讀「最新穩定版本」目錄，就可自動獲得最新模板，不需要你逐專案維護。

---

## 七、MVP 落地路線（以最小可用為主）

只給一條可執行主線：

1. **MVP v0：純 Git + 模板**

   * 在現有 SDD_MVP repo 裡新增 `/templates/bank_sdd_profile/v1`。
   * `create_project.sh` 類指令：建立專案目錄並複製這些 *.md 空白模板。
   * 全部手動填寫，但格式已固定。

2. **MVP v1：AI 輔助結構化**

   * 新增一個 CLI / Bot：

     * `brd_to_profile`：輸入 BRD / 會議紀錄 → 自動生成 `10~70_xxx.md` 草稿。
   * 人類只需修正，而不是從空白頁面開始。

3. **MVP v2：SDD 整合**

   * 在 SDD 流程中，新增一個步驟：

     * `profile_to_sdd`：從 `20_process.md / 40_infosec.md / 70_nfr.md` 生成 `spec.md / plan.md` skeleton。
   * 之後才進入既有的 `/speckit.specify / .plan / .tasks` 流程。

---

## 八、關鍵檢核（給你判斷方案是否「成型」）

1. 是否已明確區分「需求對齊層（Bank Profile）」與「技術執行層（SDD spec/plan/tasks）」而非混在一起。
2. 是否所有資安 / 法遵 / 稽核 / 封控要求都有固定欄位與 owner（不再靠人記）並有 Gate 機制。
3. 是否有明確的模板 owner + 版本管理機制，避免模板品質退化或分裂。
