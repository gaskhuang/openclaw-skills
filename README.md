# OpenClaw Skills

G大的 OpenClaw Skill 集合。一鍵安裝所有 skills：

```bash
curl -fsSL https://raw.githubusercontent.com/gaskhuang/openclaw-skills/main/install.sh | bash
```

或指定安裝目錄：

```bash
curl -fsSL https://raw.githubusercontent.com/gaskhuang/openclaw-skills/main/install.sh | bash -s -- --dir ~/skills
```

只安裝特定 skill：

```bash
curl -fsSL https://raw.githubusercontent.com/gaskhuang/openclaw-skills/main/install.sh | bash -s -- --only gog-reauth,summarize
```

## Skills 列表

| Skill | 說明 |
|-------|------|
| gog-reauth | Google Workspace (gws) 安裝、OAuth 認證、永久防過期 |
| summarize | 總結 URL/影片/PDF/音訊 |
| agent-browser | 無頭瀏覽器自動化 |
| am-i-hacked | 本機安全掃描 |
| nano-banana-pro | Gemini 3 Pro 圖片生成/編輯 |
| openclaw-backup | 加密備份 workspace 檔案 |
| tavily | Tavily 網頁搜尋 |
| reddit | Reddit 公開內容搜尋 |
| twitter | X/Twitter 操作 |
| opentwitter | OpenClaw Twitter 整合 |
| opennews | 新聞聚合 |
| telegram-send-media | Telegram 媒體傳送 |
| data-analyst | 資料分析/視覺化 |
| cognitive-memory | 智慧記憶系統 |
| dogfood | Web app QA 測試 |
| electron | Electron 桌面 app 自動化 |
| quota-guardian | API 配額監控 |
| second-brain | 第二大腦知識庫 |
| gog-reauth | gws OAuth 重新認證 |
| ... | 更多陸續加入 |

## 需求

- Node.js 18+
- Git
- OpenClaw 已安裝
