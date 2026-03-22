#!/bin/bash
# install.sh — 一鍵安裝所有 OpenClaw Skills
# Usage: curl -fsSL https://raw.githubusercontent.com/gaskhuang/openclaw-skills/main/install.sh | bash
# Or:    bash install.sh [--dir ~/skills] [--only gog-reauth,summarize]

set -e

GITHUB_USER="gaskhuang"
PREFIX="openclaw-skill"
INSTALL_DIR="${SKILLS_DIR:-$HOME/skills}"
ONLY=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) INSTALL_DIR="$2"; shift 2 ;;
    --only) ONLY="$2"; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$INSTALL_DIR"

# All available skills
ALL_SKILLS=(
  agent-browser
  agent-reach
  am-i-hacked
  api-gateway
  atxp-2
  auto-updater
  automation-workflows
  chrome-cdp
  cognitive-memory
  data-analyst
  dogfood
  electron
  find-skills
  firecrawl
  gdrive-uploader
  gog-reauth
  humanizer
  nano-banana-pro
  nano-pdf
  openai-whisper
  openclaw-backup
  openclaw-control-center
  openclaw-tavily-search
  opennews
  opentwitter
  proactive-agent
  quota-guardian
  reddit
  second-brain
  summarize
  tavily
  telegram-bot-group-setup
  telegram-send-media
  twitter
  x-account-analysis
)

# Filter if --only specified
if [ -n "$ONLY" ]; then
  IFS=',' read -ra ALL_SKILLS <<< "$ONLY"
fi

echo "🦞 OpenClaw Skills Installer"
echo "📁 安裝目錄：$INSTALL_DIR"
echo "📦 共 ${#ALL_SKILLS[@]} 個 skills"
echo ""

SUCCESS=0
FAIL=0

for skill in "${ALL_SKILLS[@]}"; do
  repo_url="https://github.com/$GITHUB_USER/$PREFIX-$skill"
  target="$INSTALL_DIR/$skill"

  if [ -d "$target/.git" ]; then
    echo -n "🔄 更新 $skill ... "
    git -C "$target" pull --quiet && echo "✅" || echo "❌"
  else
    echo -n "⬇️  安裝 $skill ... "
    if git clone --quiet "$repo_url" "$target" 2>/dev/null; then
      echo "✅"
      ((SUCCESS++))
    else
      echo "❌ (找不到 $repo_url)"
      ((FAIL++))
    fi
  fi
done

echo ""
echo "✅ 成功：$SUCCESS　❌ 失敗：$FAIL"
echo ""
echo "🎉 安裝完成！Skills 路徑：$INSTALL_DIR"
echo "   在 openclaw.json 確認 skills.path 指向 $INSTALL_DIR"
