# Tasks: Spec Bot - Slack/GitHub/GPT-5 nano 整合的 SDD 需求對齊工具

**Feature Branch**: `001-spec-bot-sdd-integration`
**Input**: Design documents from `/specs/001-spec-bot-sdd-integration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md, architecture-new.md

**架構**: GPT-5 nano Orchestrator + Claude CLI Agent + SpecKit + Docker Isolation

**模式**: 測試驅動開發 (TDD) - 所有任務按順序執行，無並行任務
**恢復機制**: 每個 Phase 完成後都有 Checkpoint 標記，可從任意 Checkpoint 恢復

---

## 格式說明: `- [ ] [TaskID] [Story?] Description with file path`

- **TaskID**: 任務編號 (T001, T002, T003...)
- **[Story]**: 使用者故事標籤 (僅限 Phase 3 之後的任務)
  - [US1]: User Story 1 (PM 上傳 BRD 觸發自動化流程)
  - [US2]: User Story 2 (自動生成 SDD 並提交 GitHub)
  - [US3]: User Story 3 (審核者在 GitHub 審核 SDD)
  - [US4]: User Story 4 (合併後自動產生交付物)
  - [US5]: User Story 5 (錯誤處理與日誌追蹤)
- **Description**: 清晰描述任務內容，包含完整檔案路徑

---

## Phase 1: Docker 容器環境建立

**目的**: 建立 Docker 容器映像，安裝 Claude CLI + SpecKit CLI + 所有依賴

**⚠️ Session 恢復點 #1**: 如果在此階段中斷，請從 T001 開始重新執行

### 測試先行 (TDD 紅燈階段)

- [X] T001 撰寫 Dockerfile 語法驗證測試 ✅
  - 測試檔案: `tests/docker/test_dockerfile_syntax.sh`
  - 驗證: Dockerfile 語法正確，無 Hadolint 警告
  - 驗證: 基礎映像為 `node:18-slim`

- [X] T002 撰寫容器工具安裝驗證測試 ✅
  - 測試檔案: `tests/docker/test_container_tools.sh`
  - 驗證: Claude CLI 已安裝 (`claude-cli --version`)
  - 驗證: SpecKit CLI 已安裝 (`specify --version`)
  - 驗證: Git 已安裝 (`git --version`)
  - 驗證: GitHub CLI 已安裝 (`gh --version`)
  - 驗證: mermaid-cli 已安裝 (`mmdc --version`)

### 實作 (TDD 綠燈階段)

- [X] T003 建立 Dockerfile (docker/spec-bot-sandbox/Dockerfile) ✅
  - 參考: plan.md 第 215-247 行
  - 內容:
    - FROM node:18-slim
    - 安裝 Git, Python 3.11, curl, jq
    - 安裝 uv (Python 套件管理工具)
    - 安裝 Claude CLI (`npm install -g @anthropic-ai/claude-code`)
    - 安裝 SpecKit CLI (`uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`)
    - 安裝 Mermaid CLI (`npm install -g @mermaid-js/mermaid-cli`)
    - 安裝 GitHub CLI (gh)
    - 建立非 root 使用者 (specbot, UID 1000)
    - WORKDIR /workspace

- [X] T004 建立 docker-compose.yml (docker/docker-compose.yml) ✅
  - 參考: plan.md 第 249-291 行
  - 內容:
    - 服務名稱: spec-bot-worker
    - 資源限制: CPU 2.0, Memory 4G
    - 掛載點: /input (ro), /output (rw), /workspace (rw)
    - 環境變數: GITHUB_TOKEN, ANTHROPIC_API_KEY, CORRELATION_ID
    - 網路: spec-bot-net (isolated)
    - 生命週期: restart=no, stop_grace_period=30s

- [X] T005 建立 .dockerignore 檔案 (docker/.dockerignore) ✅
  - 排除: `.git/`, `node_modules/`, `__pycache__/`, `*.pyc`, `venv/`

### 驗證 (TDD 綠燈驗證)

- [X] T006 執行 T001 測試 - 驗證 Dockerfile 語法 ✅
  ```bash
  bash tests/docker/test_dockerfile_syntax.sh
  # ✅ PASSED: Dockerfile syntax valid
  ```

- [X] T007 建立 Docker 映像並執行 T002 測試 ✅
  ```bash
  docker build -f docker/spec-bot-sandbox/Dockerfile -t spec-bot-sandbox:test .
  docker run --rm spec-bot-sandbox:test bash tests/docker/test_container_tools.sh
  # ✅ PASSED: All tools installed correctly (uv 0.9.9, Claude CLI 2.0.37, Git 2.39.5, gh 2.83.0, mmdc 11.12.0)
  ```

**✅ Checkpoint #1 完成**: Docker 容器環境建立完成，所有工具已安裝並驗證

---

## Phase 2: 通訊協議與契約定義

**目的**: 定義 brd_analysis.json 與 result.json 的 JSON Schema，建立契約測試

**⚠️ Session 恢復點 #2**: 如果在此階段中斷，請從 T008 開始執行

### 測試先行 (TDD 紅燈階段)

- [ ] T008 撰寫 brd_analysis.json Schema 驗證測試
  - 測試檔案: `tests/contracts/test_brd_analysis_schema.sh`
  - 使用 ajv-cli 驗證 JSON Schema
  - 測試範例: `tests/fixtures/brd_analysis_sample.json`
  - 驗證必要欄位: correlation_id, timestamp, brd_content, analysis, speckit_commands

- [ ] T009 撰寫 result.json Schema 驗證測試
  - 測試檔案: `tests/contracts/test_result_schema.sh`
  - 驗證必要欄位: correlation_id, status, git_operations, logs
  - 測試成功案例與錯誤案例

### 實作 (TDD 綠燈階段)

- [ ] T010 建立 brd_analysis.json JSON Schema (specs/001-spec-bot-sdd-integration/contracts/brd_analysis_schema.json)
  - 參考: research.md 第 628-672 行
  - 定義: correlation_id (pattern: ^req-[a-zA-Z0-9-]+$)
  - 定義: brd_content (minLength: 100, maxLength: 102400)
  - 定義: analysis.functional_requirements (array of FR-xxx)
  - 定義: speckit_commands (array of strings)

- [ ] T011 建立 result.json JSON Schema (specs/001-spec-bot-sdd-integration/contracts/result_schema.json)
  - 參考: research.md 第 575-624 行
  - 定義: status (enum: success, error)
  - 定義: git_operations (branch, commit_sha, pr_url)
  - 定義: error_type (SPECKIT_EXECUTION_ERROR, GIT_ERROR, etc.)

- [ ] T012 建立 brd_analysis.json 測試範例 (tests/fixtures/brd_analysis_sample.json)
  - 包含完整的 BRD 內容
  - 包含 5 個功能需求 (FR-001 到 FR-005)
  - 包含 3 個非功能需求
  - 包含 speckit_commands 陣列

- [ ] T013 建立 result.json 測試範例 (tests/fixtures/result_success_sample.json, result_error_sample.json)
  - 成功案例: status=success, 包含 PR URL
  - 錯誤案例: status=error, 包含 error_type 與 error_message

### 驗證 (TDD 綠燈驗證)

- [ ] T014 執行 T008 測試 - 驗證 brd_analysis.json Schema
  ```bash
  npm install -g ajv-cli
  bash tests/contracts/test_brd_analysis_schema.sh
  # Expected: ✅ Schema validation passed
  ```

- [ ] T015 執行 T009 測試 - 驗證 result.json Schema
  ```bash
  bash tests/contracts/test_result_schema.sh
  # Expected: ✅ Schema validation passed (success & error cases)
  ```

**✅ Checkpoint #2 完成**: 通訊協議定義完成，契約測試通過

---

## Phase 3: Claude CLI 執行腳本開發

**目的**: 建立 Docker 容器內執行的 Claude CLI 腳本，整合 SpecKit 指令與 Git 操作

**⚠️ Session 恢復點 #3**: 如果在此階段中斷，請從 T016 開始執行

### 測試先行 (TDD 紅燈階段)

- [ ] T016 [US2] 撰寫 Claude CLI 腳本語法測試
  - 測試檔案: `tests/scripts/test_run_speckit_syntax.sh`
  - 驗證: Bash 語法正確 (`bash -n run_speckit.sh`)
  - 驗證: 所有變數已定義
  - 驗證: 錯誤處理完整 (`set -e`, `trap`)

- [ ] T017 [US2] 撰寫 Git 操作模擬測試
  - 測試檔案: `tests/scripts/test_git_operations.sh`
  - 模擬: git clone, git checkout -b, git add, git commit, git push
  - 驗證: 分支名稱格式正確 (`bot/spec-{timestamp}`)
  - 驗證: commit 訊息格式正確 (Conventional Commits)

- [ ] T018 [US2] 撰寫 SpecKit 指令執行模擬測試
  - 測試檔案: `tests/scripts/test_speckit_execution.sh`
  - 模擬: /speckit.specify, /speckit.plan, /speckit.tasks
  - 驗證: 指令參數正確傳遞
  - 驗證: 輸出檔案產生 (spec.md, plan.md, tasks.md)

### 實作 (TDD 綠燈階段)

- [ ] T019 [US2] 建立 Claude CLI 執行腳本 (docker/scripts/run_speckit.sh)
  - 參考: plan.md 第 328-389 行, research.md 第 274-308 行
  - 步驟 1: 讀取 /input/brd_analysis.json 取得 correlation_id
  - 步驟 2: 初始化 Git (git clone, git checkout -b)
  - 步驟 3: 執行 SpecKit 指令:
    - `claude-cli execute "/speckit.specify --input /input/brd_analysis.json"`
    - `claude-cli execute "/speckit.plan"`
    - `claude-cli execute "/speckit.tasks --mode tdd --no-parallel"`
  - 步驟 4: Git 操作 (git add, git commit, git push)
  - 步驟 5: 建立 PR (`gh pr create`)
  - 步驟 6: 輸出 result.json

- [ ] T020 [US2] 建立錯誤處理函式 (docker/scripts/error_handler.sh)
  - 函式: handle_error(error_type, error_message)
  - 功能: 寫入 /output/result.json (status=error)
  - 包含: error_type, error_message, stack_trace, logs

- [ ] T021 [US2] 建立 Mermaid 驗證腳本 (docker/scripts/validate_mermaid.sh)
  - 參考: research.md 第 694-705 行
  - 功能: 遍歷所有 .mermaid 檔案
  - 執行: `mmdc -i $file -o /tmp/test.png`
  - 錯誤: 記錄到 result.json logs 欄位

### 驗證 (TDD 綠燈驗證)

- [ ] T022 執行 T016 測試 - 驗證腳本語法
  ```bash
  bash tests/scripts/test_run_speckit_syntax.sh
  # Expected: ✅ Syntax valid, all variables defined
  ```

- [ ] T023 執行 T017 測試 - 驗證 Git 操作
  ```bash
  bash tests/scripts/test_git_operations.sh
  # Expected: ✅ Git operations succeed, branch name correct
  ```

- [ ] T024 執行 T018 測試 - 驗證 SpecKit 執行
  ```bash
  bash tests/scripts/test_speckit_execution.sh
  # Expected: ✅ SpecKit commands execute, output files generated
  ```

**✅ Checkpoint #3 完成**: Claude CLI 執行腳本開發完成，測試通過

---

## Phase 4: GPT-5 nano 協調層 (Docker 管理)

**目的**: 實作 GPT-5 nano 與 Docker 容器的整合，管理容器生命週期

**⚠️ Session 恢復點 #4**: 如果在此階段中斷，請從 T025 開始執行

**注意**: 本 Phase 假設 GPT-5 nano API 已可用，若實際整合方式不同，需調整任務

### 測試先行 (TDD 紅燈階段)

- [ ] T025 [US2] 撰寫 Docker 容器啟動測試
  - 測試檔案: `tests/docker/test_container_lifecycle.py`
  - 使用: pytest + docker SDK
  - 驗證: 容器成功啟動
  - 驗證: 掛載點正確 (/input, /output, /workspace)
  - 驗證: 環境變數注入成功

- [ ] T026 [US2] 撰寫 Docker 容器逾時處理測試
  - 測試: 容器執行超過 10 分鐘自動終止
  - 驗證: 容器被 kill，資源清理完成
  - 驗證: result.json 包含逾時錯誤訊息

- [ ] T027 [US5] 撰寫 Docker 容器資源限制測試
  - 驗證: CPU 限制為 2 核心
  - 驗證: Memory 限制為 4GB
  - 驗證: 超過限制時容器被 OOM killed

### 實作 (TDD 綠燈階段)

- [ ] T028 [US2] 建立 Docker 容器管理模組 (gpt5_orchestrator/docker_manager.py)
  - 參考: research.md 第 460-501 行
  - 功能: start_container(correlation_id, brd_analysis)
  - 功能: wait_for_completion(container, timeout=600)
  - 功能: collect_output(correlation_id)
  - 功能: cleanup_container(correlation_id)

- [ ] T029 [US5] 建立錯誤處理模組 (gpt5_orchestrator/error_handler.py)
  - 功能: classify_error(error_type)
  - 功能: should_retry(error_type)
  - 功能: get_troubleshooting_steps(error_type)

- [ ] T030 [US1] 建立 BRD 分析模組 (gpt5_orchestrator/brd_analyzer.py)
  - 功能: parse_brd(brd_markdown)
  - 功能: extract_requirements(brd_content)
  - 功能: generate_brd_analysis_json(brd, correlation_id)

- [ ] T031 [US1] 建立 Slack 事件處理模組 (gpt5_orchestrator/slack_handler.py)
  - 功能: handle_file_shared(event)
  - 功能: handle_app_mention(event)
  - 功能: send_status_update(channel, status, message)

### 驗證 (TDD 綠燈驗證)

- [ ] T032 執行 T025 測試 - 驗證容器生命週期
  ```bash
  pytest tests/docker/test_container_lifecycle.py -v
  # Expected: ✅ Container starts, mounts correct, env vars injected
  ```

- [ ] T033 執行 T026 測試 - 驗證逾時處理
  ```bash
  pytest tests/docker/test_container_lifecycle.py::test_timeout -v
  # Expected: ✅ Container killed after 10 minutes
  ```

- [ ] T034 執行 T027 測試 - 驗證資源限制
  ```bash
  pytest tests/docker/test_container_lifecycle.py::test_resource_limits -v
  # Expected: ✅ CPU & Memory limits enforced
  ```

**✅ Checkpoint #4 完成**: GPT-5 nano 協調層與 Docker 管理模組完成

---

## Phase 5: 端到端整合測試

**目的**: 測試完整流程 - Slack 上傳 BRD → GPT-5 nano 分析 → Docker 執行 → GitHub PR

**⚠️ Session 恢復點 #5**: 如果在此階段中斷，請從 T035 開始執行

### 測試先行 (TDD 紅燈階段)

- [ ] T035 [US2] 撰寫端到端流程測試 (Happy Path)
  - 測試檔案: `tests/e2e/test_brd_to_pr_flow.py`
  - 步驟:
    1. 準備測試 BRD (`tests/fixtures/sample_brd.md`)
    2. 模擬 GPT-5 nano 產生 brd_analysis.json
    3. 啟動 Docker 容器
    4. 等待容器執行完成
    5. 驗證 result.json 包含 PR URL
    6. 驗證 GitHub PR 已建立
    7. 驗證 PR 包含 spec.md, plan.md, tasks.md

- [ ] T036 [US5] 撰寫錯誤處理端到端測試
  - 測試: BRD 格式錯誤 → Slack 錯誤通知
  - 測試: SpecKit 執行失敗 → result.json status=error
  - 測試: GitHub Token 權限不足 → 錯誤通知

- [ ] T037 [US5] 撰寫佇列機制測試
  - 測試: 6 個並行請求 → 第 6 個進入佇列
  - 驗證: 佇列位置通知正確
  - 驗證: 預估等待時間合理

### 實作 (TDD 綠燈階段)

- [ ] T038 [US1] 建立完整流程主程式 (gpt5_orchestrator/main.py)
  - 功能: main(slack_event)
  - 步驟:
    1. handle_slack_event(event)
    2. analyze_brd(brd_file)
    3. start_docker_container(brd_analysis)
    4. wait_and_collect_result()
    5. notify_slack(result)

- [ ] T039 [US5] 建立佇列管理器 (gpt5_orchestrator/queue_manager.py)
  - 參考: research.md 第 902-936 行
  - 功能: enqueue(brd_analysis)
  - 功能: process_queue()
  - 功能: get_queue_status()

- [ ] T040 [US5] 建立日誌追蹤模組 (gpt5_orchestrator/logger.py)
  - 功能: log_structured(level, message, correlation_id, context)
  - 格式: JSON 日誌 (參考 research.md 第 854-867 行)

### 驗證 (TDD 綠燈驗證)

- [ ] T041 執行 T035 測試 - 驗證完整流程 (Happy Path)
  ```bash
  pytest tests/e2e/test_brd_to_pr_flow.py::test_happy_path -v
  # Expected: ✅ BRD → Docker → GitHub PR (3 minutes)
  ```

- [ ] T042 執行 T036 測試 - 驗證錯誤處理
  ```bash
  pytest tests/e2e/test_brd_to_pr_flow.py::test_error_handling -v
  # Expected: ✅ All error scenarios handled correctly
  ```

- [ ] T043 執行 T037 測試 - 驗證佇列機制
  ```bash
  pytest tests/e2e/test_brd_to_pr_flow.py::test_queue_mechanism -v
  # Expected: ✅ Queue works, 6th request queued
  ```

**✅ Checkpoint #5 完成**: 端到端整合測試通過，核心流程驗證完成

---

## Phase 6: GitHub Actions 與 CI/CD

**目的**: 建立 GitHub Actions 工作流程，自動執行測試與部署

**⚠️ Session 恢復點 #6**: 如果在此階段中斷，請從 T044 開始執行

### 測試先行 (TDD 紅燈階段)

- [ ] T044 [US4] 撰寫 GitHub Actions 語法驗證測試
  - 使用: `actionlint` 驗證 YAML 語法
  - 驗證: 所有 job 名稱正確
  - 驗證: secrets 使用正確

- [ ] T045 [US4] 撰寫 CI 測試流程驗證
  - 驗證: Docker 映像建立成功
  - 驗證: Contract tests 執行成功
  - 驗證: 測試覆蓋率 ≥ 80%

### 實作 (TDD 綠燈階段)

- [ ] T046 [US4] 建立 CI 工作流程 (.github/workflows/ci.yml)
  - 參考: plan.md 第 672-698 行
  - Jobs:
    - build: 建立 Docker 映像
    - test-contracts: 執行契約測試
    - test-integration: 執行整合測試
    - test-coverage: 檢查測試覆蓋率 ≥ 80%

- [ ] T047 [US4] 建立 Post-Merge 工作流程 (.github/workflows/post-merge.yml)
  - 觸發條件: PR 合併至 main
  - Jobs:
    - convert-mermaid: 轉換 .mermaid → .png
    - convert-markdown: 轉換 .md → .pdf, .docx
    - create-release: 建立 GitHub Release
    - notify-slack: 發送完成通知至 Slack

- [ ] T048 建立 CODEOWNERS 檔案 (.github/CODEOWNERS)
  - 參考: spec.md 第 264-273 行
  - 規則:
    - `/specs/**/*.md` → @team-sa
    - `/specs/**/02_架構設計.md` → @team-architect
    - `/specs/**/diagrams/*` → @team-architect

### 驗證 (TDD 綠燈驗證)

- [ ] T049 執行 T044 測試 - 驗證 GitHub Actions 語法
  ```bash
  actionlint .github/workflows/ci.yml
  actionlint .github/workflows/post-merge.yml
  # Expected: ✅ No syntax errors
  ```

- [ ] T050 執行 T045 測試 - 驗證 CI 流程（本地模擬）
  ```bash
  act -j build  # 使用 nektos/act 本地執行
  act -j test-contracts
  # Expected: ✅ CI jobs succeed
  ```

**✅ Checkpoint #6 完成**: GitHub Actions CI/CD 設定完成

---

## Phase 7: 文件與部署

**目的**: 撰寫部署文件、操作手冊、疑難排解指南

**⚠️ Session 恢復點 #7**: 如果在此階段中斷，請從 T051 開始執行

- [ ] T051 更新 quickstart.md 安裝步驟
  - 參考現有 quickstart.md
  - 更新: Docker 容器建立步驟
  - 更新: 環境變數設定 (GITHUB_TOKEN, ANTHROPIC_API_KEY, GPT5_NANO_API_KEY)
  - 新增: Claude CLI 與 SpecKit 驗證步驟

- [ ] T052 更新 data-model.md 架構圖
  - 移除: Python Bot 架構圖
  - 新增: GPT-5 nano + Claude CLI + SpecKit 架構圖 (Mermaid)
  - 新增: 端到端流程 Sequence Diagram

- [ ] T053 建立疑難排解文件 (TROUBLESHOOTING.md)
  - 常見問題 1: Docker 容器啟動失敗
  - 常見問題 2: SpecKit 指令執行錯誤
  - 常見問題 3: GitHub Token 權限不足
  - 常見問題 4: Claude CLI 無法連線

- [ ] T054 建立部署文件 (DEPLOYMENT.md)
  - 生產環境需求
  - 環境變數清單
  - Docker Compose 部署步驟
  - 監控與日誌設定

- [ ] T055 建立 README.md (專案根目錄)
  - 專案概述
  - 快速開始
  - 架構說明 (連結至 architecture-new.md)
  - 開發指南
  - 貢獻指南

**✅ Checkpoint #7 完成**: 文件撰寫完成

---

## Phase 8: 最終驗收測試

**目的**: 執行完整的驗收測試，確保所有 User Stories 通過

**⚠️ Session 恢復點 #8**: 如果在此階段中斷，請從 T056 開始執行

- [ ] T056 [US1] 執行 User Story 1 驗收測試
  - Given: PM 在 Slack 上傳 BRD
  - When: @Spec Bot 觸發
  - Then: Bot 在 30 秒內回應「✅ 已收到 BRD」
  - 測試: `pytest tests/acceptance/test_us1.py -v`

- [ ] T057 [US2] 執行 User Story 2 驗收測試
  - Given: Bot 收到 BRD
  - When: Docker 容器執行 SpecKit
  - Then: GitHub PR 建立，包含 spec.md, plan.md, tasks.md
  - 測試: `pytest tests/acceptance/test_us2.py -v`

- [ ] T058 [US3] 執行 User Story 3 驗收測試
  - Given: PR 已建立
  - When: SA/Architect 審核
  - Then: 可以留言、Request Changes、Approve
  - 測試: 手動測試（在 GitHub 實際操作）

- [ ] T059 [US4] 執行 User Story 4 驗收測試
  - Given: PR 已合併
  - When: GitHub Actions 觸發
  - Then: 產生 PNG, PDF, DOCX，建立 Release
  - 測試: 檢查 GitHub Release 頁面

- [ ] T060 [US5] 執行 User Story 5 驗收測試
  - Given: 任何錯誤發生
  - When: 系統捕捉錯誤
  - Then: Slack 錯誤通知，日誌記錄，提供疑難排解步驟
  - 測試: `pytest tests/acceptance/test_us5.py -v`

- [ ] T061 執行效能測試
  - 測試: BRD → SDD 完整流程 < 3 分鐘 (P95)
  - 測試: Slack 初步回應 < 5 秒
  - 測試: GitHub PR 建立 < 30 秒
  - 測試: 5 個並行請求成功處理

- [ ] T062 執行安全測試
  - 測試: Docker 容器無法存取宿主機
  - 測試: 日誌中無 PII 或 secrets 洩漏
  - 測試: 環境變數正確注入與遮罩

- [ ] T063 執行測試覆蓋率檢查
  - 執行: `pytest --cov=gpt5_orchestrator --cov-report=html`
  - 驗證: 覆蓋率 ≥ 80%
  - 產生報告: `htmlcov/index.html`

**✅ Checkpoint #8 完成**: 所有驗收測試通過

---

## Phase 9: 憲法檢查與品質審核

**目的**: 確保所有實作符合專案憲法原則

**⚠️ Session 恢復點 #9**: 如果在此階段中斷，請從 T064 開始執行

- [ ] T064 憲法原則 I 檢查：單一事實來源
  - 驗證: 所有 SDD 產出儲存於 GitHub
  - 驗證: Bot 完全無狀態（無本地持久化）
  - 驗證: Docker 容器銷毀後無狀態殘留

- [ ] T065 憲法原則 II 檢查：輕量沙箱
  - 驗證: 所有自動化操作在 Docker 中執行
  - 驗證: 容器任務完成後自動銷毀
  - 驗證: 容器資源限制正確設定

- [ ] T066 憲法原則 III 檢查：測試驅動開發
  - 驗證: 所有功能測試先於實作
  - 驗證: 測試覆蓋率 ≥ 80%
  - 驗證: TDD 紅-綠-重構循環完整

- [ ] T067 憲法原則 IV 檢查：整合測試
  - 驗證: 所有 API 使用 mock 測試
  - 驗證: Docker 容器整合測試完整
  - 驗證: 端到端測試涵蓋所有 User Stories

- [ ] T068 憲法原則 V 檢查：簡約與 YAGNI
  - 驗證: 無過度工程（使用官方 SDK）
  - 驗證: 無未使用的抽象層
  - 驗證: plan.md 無未列出的複雜性

- [ ] T069 憲法原則 VI 檢查：完整可追溯性
  - 驗證: 所有日誌包含 correlation_id
  - 驗證: 日誌格式為結構化 JSON
  - 驗證: 錯誤可透過 correlation_id 追蹤

- [ ] T070 憲法原則 VII 檢查：語意化版本
  - 驗證: Commit 訊息遵循 Conventional Commits
  - 驗證: PR 需審核後才能合併
  - 驗證: Release 使用語意化版本標籤

- [ ] T071 憲法原則 VIII 檢查：零信任與權限最小化
  - 驗證: GitHub Token 使用 Fine-grained token
  - 驗證: 權限為最小必要 (contents:write, pull_requests:write, workflows:write)
  - 驗證: 所有 secrets 透過環境變數注入
  - 驗證: 容器以非 root 使用者執行

- [ ] T072 憲法原則 IX 檢查：AI 回應有據
  - 驗證: Mermaid 圖表通過 mmdc 驗證
  - 驗證: SpecKit 輸出經過品質檢查
  - 驗證: GPT-5 nano Prompt 包含防注入機制

- [ ] T073 憲法原則 X 檢查：原生整合優先
  - 驗證: 使用官方 Claude CLI
  - 驗證: 使用官方 SpecKit CLI
  - 驗證: 使用 Git CLI (非 SDK wrapper)

**✅ Checkpoint #9 完成**: 所有憲法檢查通過

---

## Phase 10: 上線準備與最終審核

**目的**: 最終審核與上線準備

**⚠️ Session 恢復點 #10**: 如果在此階段中斷，請從 T074 開始執行

- [ ] T074 產生測試報告
  - 產生: 測試覆蓋率報告 (htmlcov/)
  - 產生: 效能測試報告 (P50, P95, P99)
  - 產生: 安全測試報告

- [ ] T075 撰寫 Release Notes
  - 版本: 1.0.0
  - 功能: BRD → SDD 自動化轉換
  - 已知限制: 僅支援繁體中文
  - 下一步計畫: 多語言支援, 自動審核

- [ ] T076 建立部署檢查清單
  - [ ] Docker 映像已建立並推送至 Registry
  - [ ] 所有環境變數已設定
  - [ ] GITHUB_TOKEN 權限已驗證
  - [ ] Slack App 已安裝至 Workspace
  - [ ] CODEOWNERS 已設定
  - [ ] 測試覆蓋率 ≥ 80%
  - [ ] 所有憲法檢查通過

- [ ] T077 執行 Beta 測試
  - 邀請 2-3 位 PM 進行 Alpha 測試
  - 收集回饋並記錄問題
  - 修正關鍵問題

- [ ] T078 最終程式碼審核
  - 審核者: [填寫審核者名稱]
  - 審核項目:
    - [ ] 所有測試通過
    - [ ] 文件完整且正確
    - [ ] 憲法檢查通過
    - [ ] 安全性審核通過
    - [ ] 效能指標達標

**✅ Checkpoint #10 完成**: 所有任務完成，系統已準備上線

---

## 總任務統計

- **總任務數**: 78 個任務
- **User Story 覆蓋**:
  - US1 (PM 上傳 BRD): T030, T031, T038, T056
  - US2 (自動生成 SDD): T016-T024, T025-T029, T035, T038, T057
  - US3 (審核 SDD): T058
  - US4 (自動產出): T044-T048, T059
  - US5 (錯誤處理): T026, T029, T036, T039-T040, T060
- **測試覆蓋率**: ≥ 80% (驗證於 T063)
- **憲法檢查**: 10 項原則全數通過 (T064-T073)

---

## 恢復指令

如果 session 在任何 Phase 中斷，使用以下指令恢復：

```bash
# 恢復至 Phase N Checkpoint
git status  # 確認當前狀態
git log --oneline -5  # 查看最近 commits

# 從 tasks.md 找到最近完成的 Checkpoint
# 例如: Checkpoint #5 完成，從 T035 開始

# 繼續執行未完成的任務
# 例如: pytest tests/e2e/test_brd_to_pr_flow.py -v
```

---

**文件狀態**: ✅ 任務清單完成
**總任務數**: 78 個任務（TDD 模式，順序執行，10 個 Checkpoint）
**下一步**: 執行 Phase 1 - 建立 Docker 容器環境
**負責人**: [填寫技術負責人]
**審核者**: [填寫審核者]
