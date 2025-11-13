# Spec Bot 快速開始指南

**專案**: Spec Bot - Slack/GitHub/GPT 整合的 SDD 需求對齊工具
**版本**: 1.0.0
**最後更新**: 2025-11-13

## 概述

本指南將協助開發者在本地環境快速設定 Spec Bot 開發環境，並執行第一個 BRD → SDD 轉換流程。

## 前置需求

### 系統需求
- **作業系統**: macOS 12+ / Ubuntu 20.04+ / Windows 11 (with WSL2)
- **Python**: 3.11+
- **Node.js**: 18+ (用於 mermaid-cli)
- **Docker**: 20.10+ (用於沙箱環境)
- **Git**: 2.30+

### 帳號需求
1. **Slack Workspace**
   - 需擁有管理員權限以建立 Slack App
   - 測試用 workspace (建議獨立於正式環境)

2. **GitHub Account**
   - 需擁有目標 repository 的 write 權限
   - 已建立 Fine-grained Personal Access Token

3. **OpenAI Account**
   - 需擁有 GPT-4 API 存取權限
   - 已取得 API key

---

## 第一步：環境準備

### 1.1 安裝 Python 依賴

```bash
# 複製 repository
git clone https://github.com/your-org/spec-bot.git
cd spec-bot

# 建立虛擬環境
python3.11 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安裝依賴
pip install -r requirements.txt

# 驗證安裝
python -c "import slack_bolt, github, openai; print('✅ Python 依賴安裝成功')"
```

### 1.2 安裝 Node.js 工具

```bash
# 安裝 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 驗證安裝
mmdc --version
```

### 1.3 安裝 Docker

```bash
# macOS (使用 Homebrew)
brew install --cask docker

# Ubuntu
sudo apt-get update
sudo apt-get install docker.io docker-compose

# 驗證安裝
docker --version
docker ps
```

---

## 第二步：Slack App 設定

### 2.1 建立 Slack App

1. 前往 https://api.slack.com/apps
2. 點擊「Create New App」→「From scratch」
3. 填寫：
   - App Name: `Spec Bot (Dev)`
   - Workspace: 選擇測試用 workspace
4. 點擊「Create App」

### 2.2 配置 OAuth Scopes

在左側選單選擇「OAuth & Permissions」，在「Bot Token Scopes」新增以下權限：

```
chat:write          # 傳送訊息
files:read          # 讀取上傳的 BRD 檔案
app_mentions:read   # 偵測 @Spec Bot mention
reactions:write     # 新增 emoji 反應 (⏳, ✅, ❌)
channels:history    # 讀取頻道訊息歷史
```

### 2.3 啟用 Event Subscriptions

1. 選擇「Event Subscriptions」→ 開啟「Enable Events」
2. 訂閱以下 Bot Events：
   - `file_shared` (偵測 BRD 上傳)
   - `app_mention` (偵測 @Spec Bot)
3. 暫時留空 Request URL，後續步驟會設定

### 2.4 安裝 App 到 Workspace

1. 選擇「Install App」→ 點擊「Install to Workspace」
2. 授權所需權限
3. 複製「Bot User OAuth Token」(格式：`xoxb-...`)

---

## 第三步：GitHub Token 設定

### 3.1 建立 Fine-grained Personal Access Token

1. 前往 GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. 點擊「Generate new token」
3. 填寫：
   - Token name: `Spec Bot Dev Token`
   - Expiration: 90 days
   - Repository access: 選擇「Only select repositories」→ 選擇測試用 repository
4. 設定 Repository permissions：
   - Contents: **Read and write**
   - Pull requests: **Read and write**
   - Workflows: **Read and write**
   - Metadata: **Read-only** (自動勾選)
5. 點擊「Generate token」並複製 token

---

## 第四步：OpenAI API Key 設定

1. 前往 https://platform.openai.com/api-keys
2. 點擊「Create new secret key」
3. 填寫 Name: `Spec Bot Dev`
4. 複製 API key (格式：`sk-...`)

---

## 第五步：環境變數配置

建立 `.env` 檔案（**注意：請勿提交至 Git**）：

```bash
# 在專案根目錄執行
cat > .env << 'ENVEOF'
# Slack 配置
SLACK_BOT_TOKEN=xoxb-your-bot-token-here
SLACK_APP_TOKEN=xapp-your-app-token-here  # Socket Mode 專用
SLACK_SIGNING_SECRET=your-signing-secret-here

# GitHub 配置
GITHUB_TOKEN=ghp_your-github-token-here
GITHUB_REPO=your-org/your-repo  # 格式：owner/repo-name

# OpenAI 配置
OPENAI_API_KEY=sk-your-openai-key-here
OPENAI_MODEL=gpt-4-turbo-preview

# Docker 配置
DOCKER_SANDBOX_IMAGE=spec-bot-sandbox:latest
DOCKER_CPU_LIMIT=2
DOCKER_MEMORY_LIMIT=4g

# 日誌配置
LOG_LEVEL=INFO
LOG_FORMAT=json  # 或 console (開發時使用)
ENVEOF

# 載入環境變數
source .env  # 或使用 python-dotenv 自動載入
```

---

## 第六步：建立 Docker Sandbox 映像

```bash
# 建立 Dockerfile (如尚未存在)
cat > docker/sandbox-dockerfile << 'DOCKEREOF'
FROM python:3.11-slim

# 安裝系統工具
RUN apt-get update && apt-get install -y \
    git \
    curl \
    nodejs \
    npm \
    && npm install -g @mermaid-js/mermaid-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 建立非 root 使用者
RUN useradd -m -u 1000 specbot

# 切換使用者
USER specbot
WORKDIR /app

# 預設指令
CMD ["bash"]
DOCKEREOF

# 建立映像
docker build -f docker/sandbox-dockerfile -t spec-bot-sandbox:latest .

# 驗證映像
docker run --rm spec-bot-sandbox:latest mmdc --version
```

---

## 第七步：執行測試

### 7.1 單元測試

```bash
# 執行所有測試
pytest tests/ -v

# 執行特定測試
pytest tests/unit/test_brd_parser.py -v

# 產生覆蓋率報告
pytest tests/ --cov=src --cov-report=html
open htmlcov/index.html  # 查看覆蓋率報告
```

### 7.2 整合測試（需真實 API tokens）

```bash
# 執行整合測試（需設定環境變數）
pytest tests/integration/ -v --runlive

# 跳過整合測試（使用 mock）
pytest tests/ -v -m "not integration"
```

---

## 第八步：啟動 Bot

### 8.1 Socket Mode 模式（開發用，無需公開 URL）

```bash
# 啟用 Slack Socket Mode
# 前往 Slack App 設定 → Socket Mode → 啟用
# 複製 App-Level Token (xapp-...) 至 .env 的 SLACK_APP_TOKEN

# 啟動 Bot
python src/main.py

# 預期輸出：
# ⚡️ Bolt app is running! (Socket Mode)
# ✅ Connected to Slack workspace: your-workspace
```

### 8.2 測試第一個 BRD → SDD 流程

1. 在 Slack 測試頻道上傳測試 BRD 檔案 (範例：`tests/fixtures/sample_brd.md`)
2. 在同一訊息中 mention Bot：`@Spec Bot 請生成 SDD`
3. 觀察 Bot 回應：
   ```
   ✅ 已收到 BRD，開始處理
   預計 2-3 分鐘完成
   ```
4. 等待處理完成，Bot 會回傳 GitHub PR 連結
5. 前往 GitHub 查看自動建立的 PR

---

## 第九步：開發工作流程

### 9.1 TDD 流程（強制）

```bash
# 1. 撰寫測試（紅燈）
cat > tests/unit/test_new_feature.py << 'TESTEOF'
def test_new_feature():
    result = my_new_function()
    assert result == expected_value
TESTEOF

# 2. 執行測試，確認失敗
pytest tests/unit/test_new_feature.py -v
# Expected: FAILED

# 3. 實作功能（綠燈）
# 編輯 src/services/my_module.py

# 4. 再次執行測試，確認通過
pytest tests/unit/test_new_feature.py -v
# Expected: PASSED

# 5. 重構（保持綠燈）
# 優化程式碼，保持測試通過
```

### 9.2 Commit 與 PR 流程

```bash
# 1. 建立功能分支
git checkout -b feat/new-feature-name

# 2. 提交變更
git add .
git commit -m "feat: 新增 XXX 功能"

# 3. 推送至 GitHub
git push origin feat/new-feature-name

# 4. 建立 Pull Request
# 前往 GitHub，點擊「Compare & pull request」
# 填寫 PR 描述，參考模板：
# - 變更摘要（What）
# - 變更原因（Why）
# - 測試結果（如何驗證）
# - 審核清單（Checklist）

# 5. 等待 CI 通過與審核者批准
# GitHub Actions 會自動執行測試與 linting

# 6. 合併 PR
# 審核通過後，點擊「Squash and merge」
```

---

## 第十步：除錯技巧

### 10.1 檢視日誌

```bash
# 即時日誌（開發模式）
LOG_FORMAT=console python src/main.py

# 結構化日誌（生產模式）
LOG_FORMAT=json python src/main.py | jq .

# 過濾特定 correlation_id 的日誌
cat logs/app.log | jq 'select(.correlation_id == "abc-123")'
```

### 10.2 常見問題排查

**問題 1: Slack Bot 無回應**
```bash
# 檢查 Socket Mode 是否啟用
# 前往 Slack App 設定 → Socket Mode → 確認已啟用

# 檢查 SLACK_APP_TOKEN 是否正確
echo $SLACK_APP_TOKEN  # 應為 xapp-...

# 檢查 Bot 是否在頻道中
# Slack 頻道 → 整合 → 新增應用程式 → 選擇 Spec Bot
```

**問題 2: GPT API 錯誤**
```bash
# 檢查 API key 是否有效
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY" | jq .

# 檢查 rate limit
# 前往 https://platform.openai.com/account/rate-limits

# 檢查帳單餘額
# 前往 https://platform.openai.com/account/billing
```

**問題 3: GitHub PR 建立失敗**
```bash
# 檢查 token 權限
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_REPO | jq .permissions

# 檢查分支保護規則
# GitHub Repo → Settings → Branches → 查看 main 分支規則

# 檢查 CODEOWNERS 檔案
cat .github/CODEOWNERS
```

---

## 附錄：開發資源

### 相關文件
- [Spec Bot 規格書](./spec.md)
- [實作計畫](./plan.md)
- [資料模型設計](./data-model.md)
- [API 契約](./contracts/)

### 外部連結
- [Slack Bolt for Python 文件](https://slack.dev/bolt-python/)
- [PyGithub 文件](https://pygithub.readthedocs.io/)
- [OpenAI API 文件](https://platform.openai.com/docs/)
- [Mermaid 語法指南](https://mermaid.js.org/)

### 社群支援
- **GitHub Issues**: https://github.com/your-org/spec-bot/issues
- **Slack 頻道**: #spec-bot-dev (內部)
- **技術負責人**: [填寫聯絡資訊]

---

## 總結

完成以上步驟後，您應該能夠：

✅ 在本地執行 Spec Bot  
✅ 測試完整的 BRD → SDD 流程  
✅ 撰寫並執行單元測試與整合測試  
✅ 提交 PR 並通過 CI 檢查  
✅ 使用結構化日誌進行除錯  

**下一步**：閱讀 [實作計畫](./plan.md) 了解詳細的技術架構與設計決策。

**需要協助？** 請在 GitHub Issues 提出問題，或聯繫技術負責人。
