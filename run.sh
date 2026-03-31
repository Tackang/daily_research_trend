#!/bin/bash
export PATH="$HOME/.bun/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
WEBHOOK_URL="https://discord.com/api/webhooks/1488570493085945897/5QSPa79VyriB66tPBgykA_4rM4ehvjUKwzxh6L5zsHu9m3GbAAKUd1Wi89zp1sn5Ulh-"
REPO_DIR="/esail4/didxorkd/daily_research_trend"
TODAY=$(date +%Y-%m-%d)

# Claude Code로 브리핑 생성
REPORT=$(cd "$REPO_DIR" && claude -p \
  --model sonnet \
  --dangerously-skip-permissions \
  "오늘 날짜 기준으로 CLAUDE.md 룰에 따라 연구 동향 브리핑을 작성해줘. 반드시 웹 검색으로 확인된 논문만 포함하고, 각 항목에 실제 URL을 붙여줘." \
  2>/dev/null)

# 1) GitHub 아카이브
mkdir -p "$REPO_DIR/$(date +%Y/%m)"
echo "$REPORT" > "$REPO_DIR/$(date +%Y/%m)/$TODAY.md"
cd "$REPO_DIR"
git add .
git commit -m "📡 $TODAY briefing"
git push

# 2) Discord 전송
PAYLOAD=$(python3 -c "
import json, sys
text = sys.stdin.read()[:1900]
print(json.dumps({'content': text}))
" <<< "$REPORT")

curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
