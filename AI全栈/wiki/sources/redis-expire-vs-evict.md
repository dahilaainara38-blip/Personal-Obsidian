---
title: 素材摘要 · 过期删除 vs 内存淘汰（小林coding）
type: source
domain: data
tags: [redis, cache, eviction]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · 过期删除策略和内存淘汰策略的区别（小林coding）

> 一句话：过期删除删"到期的 key"（惰性+定期），内存淘汰在"内存满"时删 key（8 种策略）；LRU 是近似采样实现，LFU 用对数计数器。

- 来源：https://www.xiaolincoding.com/redis/module/strategy.html · 收录 2026-09-18
- 原始素材：`raw/redis-expire-vs-evict.md`

## 关键论点

1. **过期字典**（redisDb.expires）存全部 key 的过期时间；查询时 O(1) 判断是否过期。
2. **过期删除 = 惰性 + 定期**：惰性（访问时 `expireIfNeeded` 检查删除，CPU 友好内存不友好）；定期（默认每秒 10 次 `hz 10`，随机抽 20 个 key 检查删除，**过期占比 >25% 则继续下一轮**，单轮上限 25ms 防卡死）。
3. **内存淘汰 8 种**（触发条件：运行内存超 `maxmemory`）：不淘汰的 `noeviction`（3.0+ 默认，写入报错读删正常）；volatile-{random,ttl,lru,lfu}（只在设了过期时间的 key 里淘汰）；allkeys-{random,lru,lfu}（全部范围）。
4. **近似 LRU**：不做全局链表（省内存省移动开销），redisObject 的 `lru:24bit` 记录最后访问时间戳，淘汰时**随机采样 5 个**（可配）淘汰最久未用。缺点：缓存污染（一次性批量读入的冷数据占着不走）。
5. **LFU（4.0+）**：24bit 拆成高 16bit `ldt`（时间）+ 低 8bit `logc`（对数频次，新 key 初始 5）。访问时**先按时间差衰减、再按概率增长**（越大越难加）——统计的是"访问频率"而非次数。可调：`lfu-decay-time`（默认 1 分钟）、`lfu-log-factor`。

## 支撑的 wiki 页面

- [[redis-expiration-eviction]]（新建概念页）
- [[redis]]
