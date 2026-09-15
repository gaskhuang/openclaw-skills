# OpenClaw Skills

這個 repository 提供 OpenClaw skill 的批次 Git 安裝器。`install.sh` 的 `ALL_SKILLS` 是完整清單，共 50 個名稱；每個來源依 `https://github.com/gaskhuang/openclaw-skill-<名稱>` 組成。

**來源狀態（2026-09-15）：本次檢查 50 個來源皆回覆 `Repository not found`。** 這代表在檢查帳號下目前無法取得，不能區分不存在、已移動或缺少權限。來源擁有者需先確認 repository 與存取權；本工具修正後會逐項回報失敗並以非零狀態結束，不代表來源已修復。

## 使用

需求：Bash、Git，以及可取得的來源 repository。實際 skill 的執行依賴需另查各自文件；這個安裝器只處理 Git checkout，不安裝 Node.js、OAuth 或 OpenClaw，也不驗證執行時相容性。

先下載並閱讀安裝器，再執行：

```bash
curl -fSL https://raw.githubusercontent.com/gaskhuang/openclaw-skills/main/install.sh -o install.sh
bash install.sh --help
bash install.sh --dir "$HOME/skills" --only agent-browser,summarize
```

省略 `--only` 會處理完整 50 個來源。預設目錄為 `SKILLS_DIR` 環境變數，未設定時使用 `~/skills`；`--dir` 優先。安裝前請依實際 OpenClaw 版本確認技能搜尋目錄。CLI 路徑含空白時須加引號。

未知參數、未知 skill、空清單、缺少值及重複名稱會在建立目錄前拒絕。

> 上述下載 URL 指向遠端 `main`。本地尚未發佈的修正不會自動出現在該 URL；測試或使用本地修正版請直接執行本地 `install.sh`。

## 更新與結果

- 不存在的目標：嘗試 clone，保留 Git 原始錯誤及來源 URL。
- 已有 checkout：僅在 origin 符合預期 HTTPS 來源（可帶 `.git`）、工作樹乾淨時執行 `git pull --ff-only --quiet`。來源使用其他合法 URL 形式時仍會拒絕，請人工核對。
- 同名一般檔案、非 Git 目錄或 symbolic link：拒絕，保留現有內容。
- 每項安裝及更新都計入結果；個別失敗不會跳過後續項目。
- Exit code：`0` 全數成功或顯示 help；`1` 執行失敗／部分失敗；`2` 參數錯誤或缺少 Git。

更新跟隨各 checkout 目前分支的 upstream；本工具沒有版本鎖定、回復或自動替換遠端功能。要固定版本，請人工核對 commit 並管理 checkout。成功表示 Git 操作成功，不代表 skill 已被 OpenClaw 載入或依賴已可用。

## Hermes 的範圍

本安裝器沒有引用或安裝 `Zonetech-Hermes-skill`；不會將其分類目錄展開，也不設定 `HERMES_HOME`。該 repository 的 skill、腳本與 Hermes 工具需求需獨立核對，不能只更換安裝目錄就視為已相容。

## 離線測試

```bash
python3 -m unittest discover -s tests -v
# 若有其他版本 Bash，可另外指定：
TEST_BASH=/path/to/bash python3 -m unittest discover -s tests -v
```

測試以 mock Git 及暫存目錄驗證成功、失敗、參數、更新與目標保護，不連網也不安裝至個人 skill 目錄。
