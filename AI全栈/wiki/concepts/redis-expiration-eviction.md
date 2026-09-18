---
title: 过期删除与内存淘汰
type: concept
domain: data
tags: [redis, cache, eviction, performance]
status: growing
confidence: medium
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 过期删除与内存淘汰

> 两个常被混淆的删除机制：**过期删除**删"到期的 key"（惰性+定期），**内存淘汰**在内存超 `maxmemory` 时按 8 种策略删 key 保命。

## 核心要点

- 触发条件不同：过期删除 = key 到了 TTL；内存淘汰 = 运行内存超过 maxmemory（64 位系统 maxmemory 默认 0 = 不限制，直到 OOM）。
- 过期删除 = **惰性 + 定期** 组合：惰性对 CPU 友好、定期补内存回收，各取所长。
- 淘汰 8 策略两轴：**范围**（volatile-* 只在设了 TTL 的 key 里 / allkeys-* 全库）× **算法**（random / ttl / lru / lfu）。
- Redis 的 LRU 是**近似 LRU**（随机采样 5 个挑最久未用），LFU 是**对数频率计数器**（随时间衰减 + 概率增长）——都不追求精确，换内存与性能。

## 细节

### 过期删除的执行细节

- 过期字典（redisDb.expires）以 O(1) 判断过期；查询/修改前先 `expireIfNeeded` 检查。
- 定期删除：默认 `hz 10`（每秒 10 轮）；每轮随机抽 20 个 key 检查删除，**过期占比 >25% 则再抽一轮**，单轮上限 25ms 防主线程卡死。
- 主从模式下**从库不做过期扫描**，过期 key 仍可从从库读到，靠主库同步 DEL 命令删除。

### 淘汰策略速查

| 策略 | 范围 | 行为 |
|---|---|---|
| noeviction（3.0+ 默认） | — | 不淘汰，写入报错，读/删正常 |
| volatile-random / volatile-ttl | 有 TTL | 随机 / 越早过期越先删 |
| volatile-lru / volatile-lfu | 有 TTL | 最久未用 / 最少使用 |
| allkeys-random / allkeys-lru / allkeys-lfu | 全部 | 同上 |

纯缓存场景常用 `allkeys-lru`/`allkeys-lfu`；兼做存储时用 volatile-* 保护无 TTL 的 key。

### 近似 LRU 与 LFU 的实现

- 共用 redisObject 的 `lru:24bit` 字段。LRU 模式：存访问时间戳，淘汰时随机采样 5 个（可配）删最旧。
- LRU 的缺陷：**缓存污染**——一次性批量扫描的冷数据会把热数据挤出去。
- LFU（4.0+）：24bit 拆高 16bit `ldt`（最后衰减时间）+ 低 8bit `logc`（对数频次，新 key 初始 5）。访问时先按时间差衰减、再按概率增长（logc 越大越难加）——衡量的是**频率**不是次数。`lfu-decay-time`（默认 1 分钟）与 `lfu-log-factor` 可调。

## 与其他页面的关系

- 应用主体：[[redis]]；淘汰触发的异步删除（lazyfree）与大 key 治理见 [[redis-bigkey]]
- TTL 打散是 [[cache-pitfalls]] 雪崩的预防手段

## 疑点与待验证

- LFU 在"热点轮换"业务（早晚高峰不同 key）下衰减参数怎么调？缺实战调参案例
- 定期删除 25ms 上限在高过期率场景是否成为吞吐瓶颈？待压测
- Java 客户端侧（Lettuce/Jedisson）有无对应的淘汰事件监听可接监控？待查

## 来源

- [[redis-expire-vs-evict]] — 支撑了过期删除流程、8 策略、LRU/LFU 实现
