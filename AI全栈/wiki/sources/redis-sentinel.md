---
title: 素材摘要 · 哨兵机制（小林coding）
type: source
domain: data
tags: [redis, architecture, distributed, ha]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · 为什么要有哨兵（小林coding）

> 一句话：哨兵 = 监控 + 选主 + 通知；两轮投票（客观下线判定 + leader 哨兵选举），quorum 建议 N/2+1、哨兵数取奇数。

- 来源：https://www.xiaolincoding.com/redis/cluster/sentinel.html · 收录 2026-09-18
- 原始素材：`raw/redis-sentinel.md`

## 关键论点

1. **主观下线 vs 客观下线**：单哨兵 PING 超时（`down-after-milliseconds`）→ 主观下线；拿到 ≥quorum 赞成票 → 客观下线（仅对主节点，防单哨兵网络误判）。
2. **两轮投票**：①判客观下线（票数 ≥ quorum）；②选出执行故障转移的 **leader 哨兵**（候选者 = 第一个判客观下线者；当选条件：**半数以上 且 ≥ quorum**；每个哨兵一票先到先得）。两个候选者并发时，先收到投票请求者胜。
3. **为什么至少 3 个且取奇数**：2 个哨兵时挂 1 个就永远凑不齐 2 票，无法转移；quorum = N/2+1（3→2，5→3）。文中给出 1主4从5哨兵 quorum=3 挂 2 哨兵仍可切换、挂 3 个不行的完整推演。
4. **选新主三轮考察**：过滤（已下线 + 断连超 10 次）→ ①`slave-priority` 优先级小者 → ②复制进度 `slave_repl_offset` 最接近 `master_repl_offset` → ③runID 小者。
5. **故障转移四步**：新主 `SLAVEOF no one`（哨兵每秒 INFO 确认角色切换）→ 其余从节点指向新主 → `+switch-master` 频道 pub/sub 通知客户端 → 旧主回归后降为从。
6. **哨兵集群自组成**：无需配置彼此地址——都订阅主节点的 `__sentinel__:hello` 频道相互发现；每 10s 向主节点 `INFO` 拿从节点列表。

## 支撑的 wiki 页面

- [[redis-cluster]]（补齐哨兵选主与两轮投票细节、与旧综述页互补）
- [[redis]]、[[distributed-lock]]（主从切换导致锁失效的场景源头）
