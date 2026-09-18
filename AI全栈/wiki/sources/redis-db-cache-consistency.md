---
title: 素材摘要 · 数据库与缓存一致性（小林coding）
type: source
domain: data
tags: [redis, cache, architecture, best-practice]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · 数据库和缓存如何保证一致性（小林coding）

> 一句话：Cache Aside「先更新数据库，再删除缓存」+ 过期时间兜底；删除失败用 MQ 重试或 Canal 订阅 binlog 补偿。

- 来源：https://www.xiaolincoding.com/redis/architecture/mysql_redis_consistency.html · 收录 2026-09-18
- 原始素材：`raw/redis-db-cache-consistency.md`

## 关键论点

1. **"更新缓存"两个顺序都有并发问题**：两个写请求交错时，无论先更 DB 还是先更缓存，都可能出现"DB 是 B 的值、缓存是 A 的值"。
2. **Cache Aside**：写 = 更新 DB + **删除**缓存；读 = 未命中则查 DB 回填。**先删缓存再更 DB 也不行**（读请求在删后、更前把旧值回填）。**先更 DB 再删缓存**理论上仍有一致性窗口（读请求查到旧值、还没回填时写请求已更 DB 删缓存，然后读请求才回填旧值），但**实际概率极低——缓存写入远快于数据库写入**。再加过期时间兜底 → 最终一致。
3. **删除失败的两个补偿**：①消息队列重试（代码侵入强）；②**Canal 订阅 MySQL binlog**（伪装从库拉 binlog → 解析 → 发 MQ → 消费者删缓存，与业务代码零耦合）。关键细节：**必须删缓存成功后再回 ACK**，否则消息丢了没法重试。
4. **延迟双删**（针对"先删缓存再更 DB"的补救）：删 → 更 DB → sleep N → 再删。N 要大于"读请求查库+回填"耗时，**具体多久是玄学**，只能尽可能一致。结论：不如直接用"先更 DB 再删"。
5. **为什么是删缓存不是更新缓存**：删除更轻、出错概率小；缓存值常是多表聚合，更新代价大；且更新后的缓存未必被读（Lazy Loading 思想）。
6. 高命中率需求的例外：可改用"更新 DB + 更新缓存"，但要加**分布式锁**串行化或配**短 TTL** 接受短暂不一致。

## 支撑的 wiki 页面

- [[cache-coherence]]（新建概念页，从待建清单落地）
- [[distributed-lock]]（更新缓存加锁的方案）、[[redis]]
