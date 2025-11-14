# 60_audit - 稽核可稽性需求

## 必須可稽核的事件

- 模型版本變更（上線/下線/滾回）。
- 每筆 STR 個案的模型輸出內容與時間。
- 分析人員對模型輸出的修改與最終確認。
- 任一人檢視特定 STR 個案的紀錄。

## 日誌結構需求（示意）

- log_id
- timestamp
- user_id
- case_id（STR/SAR 個案編號）
- action_type（view_case / view_model_output / edit_summary / approve_summary / change_model_version 等）
- model_version（若適用）
- before_summary / after_summary

## 保留期間與查詢能力

- STR 相關操作與模型使用日誌需保留至少 7 年或依法令要求更長期間。
- 稽核可依：
  - 個案編號
  - 分析人員
  - 日期區間
  - 模型版本
  查詢相關操作紀錄。

## 報表需求

- RA-AML-001：按分析人員統計「模型建議摘要被修改程度」。
- RA-AML-002：按模型版本統計「異常標記個案」比例。
- RA-AML-003：STR 個案處理時間分布（從建立到摘要確認）。
