---
title: 素材摘要 · Redis 数据类型与应用场景（小林coding）
type: source
domain: data
tags: [redis, data-structure, best-practice]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · Redis 常见数据类型和应用场景（小林coding）

> 一句话：5 基本类型 + 4 扩展类型（BitMap/HLL/GEO/Stream）各有明确场景；选型口诀是"二值状态用位图、去重计数用 HLL、排序用 Zset、消息队列用 Stream"。

- 来源：https://www.xiaolincoding.com/redis/data_struct/command.html · 收录 2026-09-18
- 原始素材：`raw/redis-data-types.md`

## 关键论点

1. **String**：SDS 底层，编码 int/embstr/raw（embstr↔raw 边界随版本：2.x=32B、3.0-4.0=39B、5.0=44B；embstr 只读，修改即转 raw）。场景：缓存对象（JSON 或 MSET 拆字段）、计数器（单线程=原子 INCR）、[[distributed-lock|分布式锁]]（SET NX PX）、共享 Session。
2. **List**：3.2 起底层只有 quicklist。消息队列三板斧：LPUSH+RPOP（保序）、BRPOP（阻塞读省 CPU）、BRPOPLPUSH（备份 List 保可靠）；**缺陷：消息无自动 ID、不支持消费组**。
3. **Hash**：（field,value）适合购物车（`HINCRBY cart:{uid} {sku} 1`）与对象部分字段频繁变更。
4. **Set**：无序去重 + 交并差。点赞（SADD/SISMEMBER）、共同关注（SINTER）、抽奖（SPOP 不重复/SRANDMEMBER 可重复）。**⚠️ 聚合计算复杂度高，大数据量会阻塞实例**——放到从库算或客户端算。
5. **Zset**：score 排序。排行榜（ZADD/ZINCRBY/ZREVRANGE）、区间查询 ZRANGEBYSCORE、字典序 ZRANGEBYLEX（仅同分集合可用，电话/姓名排序）。无差集运算。
6. **BitMap**（2.2+，底层就是 String 的 bit 数组）：签到（SETBIT/BITCOUNT/BITPOS 首签日）、登录态（5000 万用户仅 6MB）、连续签到（多天位图 BITOP AND 再 BITCOUNT）。
7. **HyperLogLog**（2.8+）：12KB 统计 2^64 基数，**标准误差 0.81%**——百万级 UV 够用，要精确就用 Set。
8. **GEO**（3.2+）：GeoHash 编码经纬度存进 Zset，GEORADIUS 搜附近（滴滴叫车）。
9. **Stream**（5.0+）：为消息队列设计——XADD 自动全局唯一 ID（毫秒时间戳-序号）、XREAD BLOCK 阻塞读、XGROUP/XREADGROUP 消费组、PENDING List + XACK 消费确认。**与专业 MQ 的差距**：中间件环节仍会丢（everysec 异步刷盘、主从切换），内存堆积有 OOM 风险（限长会删旧消息）。结论：轻量、可容忍丢失用 Redis；海量、不可丢用 Kafka/RabbitMQ。
10. **Pub/Sub 不能当 MQ**：不持久化（不进 RDB/AOF）、发后即忘（离线收不到）、积压超限（32MB 或 60s 内 8MB）强断客户端。

## 支撑的 wiki 页面

- [[redis]]（数据类型×场景选型表）、[[redis-internals]]（类型→底层数据结构映射）
