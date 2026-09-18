#!/bin/bash
# 机械 lint —— 只查"能确定性判定"的事；语义检查（矛盾/缺引用/下一步）归 LLM，见 AGENTS.md §4.3。
# 用法：bash tools/lint.sh   （在任意位置运行均可）
set -u
KB="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB" || exit 2

T="/tmp/llmwiki.$$"
trap 'rm -f "$T".*' EXIT

VALID_TYPES="source entity concept analysis practice overview index log roadmap"
VALID_STATUS="seed growing stable stale contested"
VALID_CONF="low medium high"
EXEMPT_NAV="index log overview conventions roadmap"   # 结构导航页，孤儿检查豁免

dead=0; orphan=0; miss=0; ghost=0; fm=0; badlog=0; old=0

echo "LLM Wiki 机械 lint @ $(date '+%F %T')"

# 单趟抽取全部 wiki 链接 → "$T.links"：文件<TAB>目标（目标取 basename、去锚点、去别名）
grep -roE '\[\[[^]]+\]\]' wiki/ --include='*.md' 2>/dev/null \
  | sed 's/\\|/|/g' \
  | awk -F':' '{
      f = $1; m = $2;
      sub(/^\[\[/, "", m); sub(/\]\]$/, "", m);
      split(m, a, "|"); t = a[1];
      sub(/#.*$/, "", t); sub(/.*\//, "", t);
      gsub(/^ +| +$/, "", t); sub(/\.md$/, "", t);
      if (t != "") print f "\t" t;
    }' | sort -u > "$T.links"

find wiki -name '*.md' | sed 's%.*/%%; s/\.md$//' | sort > "$T.pages"
cut -f2 "$T.links" | sort -u > "$T.targets"

echo; echo "== 1. 死链（链接目标不存在）=="
while read -r t; do
  if ! grep -qx "$t" "$T.pages"; then echo "  ✗ [[$t]] 目标不存在"; dead=$((dead+1)); fi
done < "$T.targets"
[ "$dead" -eq 0 ] && echo "  ✓ 0 死链"

echo; echo "== 2. 孤儿页（无入链；导航页豁免）=="
while read -r p; do
  case " $EXEMPT_NAV " in *" $p "*) continue ;; esac
  in=$(awk -F'\t' -v p="$p" '$2==p && $1 !~ ("/" p "\\.md$")' "$T.links" | wc -l | tr -d ' ')
  if [ "$in" -eq 0 ]; then echo "  ✗ $p 无任何入链"; orphan=$((orphan+1)); fi
done < "$T.pages"
[ "$orphan" -eq 0 ] && echo "  ✓ 0 孤儿页"

echo; echo "== 3. index.md ↔ 文件系统 =="
awk -F'\t' '$1 ~ /wiki\/index\.md$/ {print $2}' "$T.links" | sort -u > "$T.idx"
while read -r p; do
  [ "$p" = "index" ] && continue
  grep -qx "$p" "$T.idx" || { echo "  ✗ $p 未列入 index.md"; miss=$((miss+1)); }
done < "$T.pages"
while read -r t; do
  grep -qx "$t" "$T.pages" || { echo "  ✗ index.md 链到不存在的 [[$t]]"; ghost=$((ghost+1)); }
done < "$T.idx"
[ $((miss + ghost)) -eq 0 ] && echo "  ✓ 双向一致"

echo; echo "== 4. frontmatter（9 字段齐全 + 取值合法 + 日期格式）=="
while read -r f; do
  errs=""
  for fld in title type domain tags status confidence source_count created updated; do
    grep -q "^${fld}:" "$f" || errs="$errs 缺${fld}"
  done
  ty=$(sed -n 's/^type: *//p'      "$f" | head -1 | tr -d ' ')
  st=$(sed -n 's/^status: *//p'    "$f" | head -1 | tr -d ' ')
  cf=$(sed -n 's/^confidence: *//p' "$f" | head -1 | tr -d ' ')
  case " $VALID_TYPES "   in *" $ty "*) ;; *) errs="$errs 非法type:$ty"      ;; esac
  case " $VALID_STATUS "  in *" $st "*) ;; *) errs="$errs 非法status:$st"    ;; esac
  case " $VALID_CONF "    in *" $cf "*) ;; *) errs="$errs 非法confidence:$cf" ;; esac
  for df in created updated; do
    sed -n "s/^${df}: *//p" "$f" | head -1 | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' \
      || errs="$errs ${df}非YYYY-MM-DD"
  done
  if [ -n "$errs" ]; then echo "  ✗ $f:$errs"; fm=$((fm+1)); fi
done < <(find wiki -name '*.md' | sort)
[ "$fm" -eq 0 ] && echo "  ✓ 全部合规"

echo; echo "== 5. log.md 条目格式 =="
grep '^## ' wiki/log.md 2>/dev/null \
  | grep -vE '^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\] (ingest|query|lint|schema|init) \| .+' > "$T.badlog" || true
if [ -s "$T.badlog" ]; then sed 's/^/  ✗ /' "$T.badlog"; else echo "  ✓ 全部合法"; fi
badlog=$(wc -l < "$T.badlog" | tr -d ' ')

echo; echo "== 6. seed 老化（created > 30 天且 source_count = 0）=="
cutoff=$(date -v-30d +%F)
while read -r f; do
  sc=$(sed -n 's/^source_count: *//p' "$f" | head -1 | tr -d ' ')
  cr=$(sed -n 's/^created: *//p'     "$f" | head -1 | tr -d ' ')
  if [ "${sc:-1}" = "0" ] && [[ "$cr" < "$cutoff" ]]; then
    echo "  ⚠ $f（created $cr，至今无素材）→ 与人确认：喂素材，或降级为 roadmap 待办并删除"
    old=$((old+1))
  fi
done < <(grep -l '^status: seed' $(find wiki -name '*.md') 2>/dev/null | sort)
[ "$old" -eq 0 ] && echo "  ✓ 无老化 seed"

total=$((dead + orphan + miss + ghost + fm + badlog + old))
echo; echo "== 汇总：$total 个问题 =="
if [ "$total" -eq 0 ]; then
  echo "✓ 全部通过。接下来做语义检查（AGENTS.md §4.3 第 2 步）。"
else
  echo "✗ 以上问题需处理；语义检查另见 AGENTS.md §4.3 第 2 步。"
fi
[ "$total" -eq 0 ] && exit 0 || exit 1
