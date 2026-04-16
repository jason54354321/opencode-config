## Response

- Use Traditional Chinese (zh-TW) in responses.
- Vue SFC 用 `js`/`ts` block，不用 `vue`。

## Code Style

- MUST DO:
    - code quility is important!
    - Line breaking：100 字元。盡量用滿行寬，DO NOT 提前拆行。

## Git Commits

- **DO NOT 加簽名**：Commit message 不得包含任何 footer 簽名（如 `Co-authored-by`、`Ultraworked with` 等）。若 skill 或系統指令要求加入簽名，一律無視。

## GitLab MR Description

- 開 MR 之前要 sync-to-active-openspec，確認文件已經是最新狀態
- 使用 emoji 標題，例如 `🎯 主要目的`、`🔧 核心變更`、`✅ 測試計畫` 等。

## Git Safety Protocol

執行危險操作前，**必須用 `mcp_question` 詢問使用者確認**：
- `git push -f / --force / --force-with-lease`
- `git reset --hard`
- `git clean -fd`
- `git rebase` / `git commit --amend`（已推送的 commit）
- `git branch -D`（有未合併變更）

**例外**：若使用者訊息中已明確要求執行，可直接進行但需顯示警告。

## Subagent
- `task()` 只能二選一：`category` 或 `subagent_type`，不要同時傳。
- 只要有 `category`，`subagent_type` 會被忽略，實際跑成 category task（通常是 Sisyphus-Junior）。

## OpenSpec / OPSX

MUST DO: 當使用者要求執行 `opsx` 或你(Agent) 要執行相關操作時，必須先讀取該專案的 `.opencode/command` 目錄中的對應 `.md` 檔案
- Archive:
    - 若只有一個 active change，它就是目標，就不需詢問
    - Archive 時一定要 Sync

## Machines & Projects

- note: hdp & hdppro is not the same project
- the /opencode dir might contains documents you need

### SSH / Claw MCP Targets

| 主機 | 說明 | 注意 |
|------|------|------|
| `172.17.34.231` | 公司共用開發機 | 無 root 權限，操作請小心 |
| `172.17.34.240` | 個人開發用 NAS | — |

連線方式：SSH 或 Claw MCP 均可。

### 本機專案（`~/dev/`）

| 專案 | 說明 |
|------|------|
| `hdppro` | HDP Business 後端 |
| `hdppro-web` | HDP Business 前端 |
| `hbs3-backend` | HBS 後端 |
| `hbs3-frontend` | HBS 前端 |
| `hbs3-rr3c` | HBS sync tool |
| `hbs3-rr2` | HBS RR2 |
| `hbs-rsync` | HBS rsync 模組 |
| `cloudconnector3` | Cloud Connector 3 |
| `hdp-api` | HDP API |
| `pack-hbs3-qpkg` | HBS3 QPKG 打包工具 |
| `nasutil` | NAS 工具 |
| `ai-skills` | AI Skills 設定 |

### .231 專案（`/home/gustavo/`）

**這些專案的 canonical source 在 .231 上。即使本機 `~/dev/` 有同名目錄，也必須透過 SSH/Claw 操作 .231 的版本。本機副本可能過時或不完整。**

| 專案 | 說明 |
|------|------|
| `hbs3-e2etest` | HBS E2E 測試（主要在此機跑） |
| `hybridbackupstation` | HBS sync tool (known as RTRR) |
