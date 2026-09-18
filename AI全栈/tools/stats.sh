#!/bin/bash
# 知识库统计 —— index.md 不再手写统计段，需要时跑这个（人或 Agent 均可）。
# 用法：bash tools/stats.sh
set -u
KB="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB" || exit 2

pages=$(find wiki -name '*.md' | wc -l | tr -d ' ')
sources=$(find wiki/sources -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
supported=$(grep -rlE '^source_count: *[1-9]' wiki --include='*.md' 2>/dev/null | wc -l | tr -d ' ')

echo "页面总数：$pages"
echo "素材数：$sources"
echo "有素材支撑的页面（source_count>0）：$supported"
echo
echo "-- 按 type --"
for f in $(find wiki -name '*.md' | sort); do sed -n 's/^type: */T/p' "$f"; done \
  | sort | uniq -c | sort -rn | sed 's/T/  /'
echo
echo "-- 按 status --"
for f in $(find wiki -name '*.md' | sort); do sed -n 's/^status: */S/p' "$f"; done \
  | sort | uniq -c | sort -rn | sed 's/S/  /'
echo
echo "-- 按 domain --"
for f in $(find wiki -name '*.md' | sort); do sed -n 's/^domain: */D/p' "$f"; done \
  | sort | uniq -c | sort -rn | sed 's/D/  /'
echo
echo "-- 待建页面数（index.md 清单）--"
grep -c '^- \[ \]' wiki/index.md 2>/dev/null | sed 's/^/  /'
