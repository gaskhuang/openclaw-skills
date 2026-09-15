#!/bin/bash
# Install the listed OpenClaw skill repositories. Requires Bash and Git.
set -e

GITHUB_USER="gaskhuang"
PREFIX="openclaw-skill"
INSTALL_DIR="${SKILLS_DIR:-$HOME/skills}"
ONLY=""
usage() {
  echo "Usage: bash install.sh [--dir DIRECTORY] [--only skill,skill] [--help]"
  echo "Default directory: SKILLS_DIR, otherwise ~/skills"
}
die() { echo "Error: $*" >&2; exit 2; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir|--only)
      option="$1"
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$option requires a non-empty value"
      if [[ "$option" == --dir ]]; then INSTALL_DIR="$2"; else ONLY="$2"; fi
      shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

ALL_SKILLS=(
  agent-browser
  agent-reach
  am-i-hacked
  api-gateway
  atxp-2
  auto-social-posting
  auto-updater
  automation-workflows
  chrome-cdp
  chrome-cdp-skill
  cognitive-memory
  daily-reddit-digest
  data-analyst
  dogfood
  electron
  exec-resilience
  find-skills
  gdrive-uploader
  gog-reauth
  humanizer
  kang_yong_style
  lesson
  multi-source-tech-news
  nano-pdf
  news-aggregator-skill
  one-click-fb
  openclaw-auto-updater
  openclaw-backup
  openclaw-control-center
  openclaw-tavily-search
  opennews
  opennews-mcp
  opentwitter
  opentwitter-mcp
  proactive-agent
  quota-guardian
  reddit
  second-brain
  self-improving
  self-improving-agent
  self-reflection
  skill-install-safe
  skio
  summarize
  tavily
  tavily-search
  telegram-bot-group-setup
  telegram-send-media
  twitter
  xiao_s_style
)

if [[ -n "$ONLY" ]]; then
  [[ "$ONLY" != ,* && "$ONLY" != *, && "$ONLY" != *,,* ]] || die "--only contains an empty skill name"
  IFS=',' read -r -a REQUESTED <<< "$ONLY"
  SELECTED=()
  for skill in "${REQUESTED[@]}"; do
    found=0
    for available in "${ALL_SKILLS[@]}"; do
      if [[ "$skill" == "$available" ]]; then found=1; break; fi
    done
    [[ "$found" == 1 ]] || die "Unknown skill: $skill"
    for selected in "${SELECTED[@]}"; do
      [[ "$skill" != "$selected" ]] || die "Duplicate skill: $skill"
    done
    SELECTED+=("$skill")
  done
  ALL_SKILLS=("${SELECTED[@]}")
fi
command -v git >/dev/null 2>&1 || die "Git is required"
mkdir -p -- "$INSTALL_DIR"
# Canonicalize a relative destination before passing it to Git.
INSTALL_DIR="$(cd -- "$INSTALL_DIR" && pwd -P)"
echo "🦞 OpenClaw Skills Installer"
echo "📁 安裝目錄：$INSTALL_DIR"
echo "📦 共 ${#ALL_SKILLS[@]} 個 skills"
SUCCESS=0
FAIL=0

for skill in "${ALL_SKILLS[@]}"; do
  repo_url="https://github.com/$GITHUB_USER/$PREFIX-$skill"
  target="$INSTALL_DIR/$skill"
  ok=0
  if [[ -L "$target" ]]; then
    echo "❌ $skill: refusing a symbolic-link destination" >&2
  elif [[ -d "$target/.git" || -f "$target/.git" ]]; then
    echo "🔄 更新 $skill ..."
    origin="$(git -C "$target" remote get-url origin 2>/dev/null || true)"
    if [[ "${origin%.git}" != "$repo_url" ]]; then
      echo "❌ $skill: origin does not match expected repository $repo_url" >&2
    elif ! changes="$(git -C "$target" status --porcelain)"; then
      echo "❌ $skill: cannot inspect working tree" >&2
    elif [[ -n "$changes" ]]; then
      echo "❌ $skill: working tree has local changes; resolve them before updating" >&2
    elif git -C "$target" pull --ff-only --quiet; then
      ok=1
    fi
  elif [[ -e "$target" ]]; then
    echo "❌ $skill: destination exists and is not a Git checkout" >&2
  else
    echo "⬇️ 安裝 $skill ..."
    if git clone --quiet "$repo_url" "$target"; then ok=1; fi
  fi
  if [[ "$ok" == 1 ]]; then
    SUCCESS=$((SUCCESS + 1))
    echo "✅ $skill"
  else
    FAIL=$((FAIL + 1))
    echo "❌ $skill: failed ($repo_url)" >&2
  fi
done

printf "✅ 成功：%s  ❌ 失敗：%s\n" "$SUCCESS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  echo "安裝未全部完成；請檢查上述 Git 錯誤、來源是否存在及存取權限。" >&2
  exit 1
fi
echo "🎉 完成！Skills 路徑：$INSTALL_DIR"
echo "請依使用中的 OpenClaw 版本設定技能搜尋目錄。"
