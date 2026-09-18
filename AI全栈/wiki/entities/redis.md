---
title: Redis
type: entity
domain: data
tags: [redis, cache, data]
status: growing
confidence: medium
source_count: 16
created: 2026-09-18
updated: 2026-09-18
---

# Redis

> 开源的内存数据结构服务器，架在数据库前做加速层。定位是「让系统变快」而非「让数据可靠」——可靠性要靠持久化与复制另付代价。

## 核心要点

- 本质差异在**按数据结构组织数据**（非 KV 存字符串），这是它相对 Memcached 的根本分野；Memcached 只做纯 KV 无持久化，Redis 支持丰富类型、持久化、原生集群、Lua/事务/发布订阅。
- **"单线程"指网络 IO + 命令执行**；进程本身有后台线程（BIO：关闭文件、AOF 刷盘、lazy free 异步释放内存——`unlink` 删大 key 不阻塞的原因）。**6.0 起网络 IO 多线程**（默认只多线程写响应，`io-threads` 建议 4 核设 2-3），命令执行仍单线程——所有命令天然原子。
- 单线程为何快：内存操作 + 高效数据结构（见 [[redis-internals]]）+ IO 多路复用（epoll）+ 无锁无切换。瓶颈通常在内存和网络带宽而非 CPU。
- 部署阶梯：单实例 → 主从复制 → Sentinel → Cluster，每一步用复杂度换能力（见 [[redis-cluster]]）。
- 实战三大必答题：缓存异常（[[cache-pitfalls]]）、双写一致性（[[cache-coherence]]）、过期与淘汰（[[redis-expiration-eviction]]）。

## 细节

### 数据类型 × 场景选型表

| 类型 | 一句话场景 | 关键命令 |
|---|---|---|
| String | 缓存对象 / 原子计数 / [[distributed-lock\|分布式锁]] / 共享 Session | SET NX PX、INCR |
| List | 简单消息队列（无自动 ID、无消费组） | LPUSH+BRPOP、BRPOPLPUSH |
| Hash | 购物车、对象部分字段频繁变更 | HINCRBY cart:{uid} {sku} 1 |
| Set | 去重、点赞、共同关注（SINTER）、抽奖 | SADD/SPOP（⚠️ 大集合聚合阻塞，放从库算） |
| Zset | 排行榜、延迟队列（score=执行时间）、字典序区间 | ZINCRBY/ZREVRANGE、ZRANGEBYSCORE |
| BitMap（2.2+） | 签到、登录态（5000 万用户 6MB）、连续签到（BITOP AND） | SETBIT/BITCOUNT/BITPOS |
| HyperLogLog（2.8+） | 海量 UV 去重计数，12KB 数 2^64，误差 0.81% | PFADD/PFCOUNT |
| GEO（3.2+） | 附近的人/车（GeoHash 编码存 Zset） | GEOADD/GEORADIUS |
| Stream（5.0+） | 消息队列：自动唯一 ID、消费组、PENDING+XACK 确认 | XADD/XREADGROUP/XACK |

**Stream 当 MQ 的边界**：中间件环节仍可能丢（everysec 异步刷盘、主从切换），内存堆积有 OOM 风险——轻量可容忍用 Redis，海量不可丢用 Kafka/RabbitMQ。Pub/Sub 完全不能当 MQ（不持久化、发后即忘、积压强断连接）。

### 版本演进里程碑（特性史，非当前版本号）

2.8 增量复制与 Sentinel / 3.0 Cluster 与默认 noeviction / 3.2 quicklist / 4.0 混合持久化、LFU、unlink 异步删除 / 5.0 Stream、listpack 设计 / 6.0 网络 IO 多线程 / **7.0 ziplist 全面换 listpack、Multi-Part AOF**。

### 大 Key 治理

- 判定：String >10KB、集合 >5000 元素。危害：命令阻塞、网络打满（1MB×1000QPS=千兆网卡满）、DEL 卡顿、集群槽倾斜、fork/COW 阻塞（见 [[redis-persistence]]）。
- 查找：`--bigkeys`（在**从节点**跑）、SCAN + `MEMORY USAGE`、RdbTools 解析 RDB。
- 治理：设计期拆分；删除用 `unlink` 或分批（hscan+hdel / ltrim / sscan+srem / zremrangebyrank），配 `lazyfree-lazy-*` 自动异步。

### 事务与管道

- 事务（MULTI/EXEC）**无回滚**：入队错全弃，运行时错则正确命令照常执行（不保证原子性）；官方理由：编程错误不该进生产 + 保持简单。
- Pipeline 是**客户端**批量发送技术，省网络往返，非原子（对比 Lua 脚本是服务端原子执行）。

## 与其他页面的关系

- 构成：[[redis-internals]]（底层结构）、[[redis-persistence]]、[[redis-cluster]]、[[redis-expiration-eviction]]
- 实战模式：[[cache-pitfalls]]、[[cache-coherence]]、[[distributed-lock]]
- 与 AI 工程交叉：LLM 应用会话记忆存储（见 [[java-ai-project-skeleton]] 的 MemoryStore）；RediSearch 向量检索能力**仍待查证**（见疑点）

## 疑点与待验证

- **当前稳定版本号仍未核实**（本页版本信息是特性演进史，截至 Redis 7.0 特性；7.x/8.x 现状待查官方源）
- RediSearch 向量检索的生产可用性（维度上限、性能、与 pgvector 对比）——与 [[rag]] 直接相关，**高优先级待查**
- min-slaves-to-write / min-slaves-max-lag 在新版本已更名 min-replicas-*，确切版本与语义待核实
- Java 客户端选型（Jedis vs Lettuce vs Redisson 的 Cluster 拓扑刷新、看门狗支持差异）待整理成对比页

## 来源

- [[redis-overview]] — 定位、Memcached 对比、部署阶梯（机翻稿，已被后续单篇交叉验证）
- [[redis-interview-qa]] — 线程模型、大 key 定义与治理、事务无回滚、Stream 边界（机翻稿，结论以单篇为准）
- [[redis-data-types]] / [[redis-data-structures]] — 数据类型场景表、版本演进里程碑
- [[redis-bigkey]] — 大 key 对持久化/网络/集群的危害
