---
title: 素材摘要 · 分布式锁的高可用与高性能（小林coding）
type: source
domain: data
tags: [redis, distributed-lock, concurrency, architecture]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · 如何保证 Redis 分布式锁的高可用和高性能（小林coding）

> 一句话：工业级分布式锁 = 等待策略 + 幂等重试 + 续约与中断策略 + Redlock 及其争议 + "干脆不用锁"的替代方案。

- 来源：https://www.xiaolincoding.com/redis/cluster/redlock.html · 收录 2026-09-18
- 原始素材：`raw/redis-distributed-lock-ha.md`（进阶篇，含量最高）

## 关键论点

1. **等待策略**：自旋（简单但空耗，总等待时间 ≈ 锁平均持有时间，如 P99=800ms 则设 1s）vs 事件监听（订阅 DEL 的 Pub/Sub / Keyspace Notifications，实时但"检测→订阅"间隙可能错过通知）。
2. **超时重试要幂等**：加锁超时后先 `GET`——nil 则重试 SETNX；等于自己的 UUID 则上次其实成功了（重置过期即可）；等于别人的则进等待逻辑。
3. **过期时间设多长**：取业务 P999 + buffer；过期时间主要防宕机死锁，正常应由业务主动 DEL，设长些（30s/1min）是安全的。
4. **续约失败的两难**：保守策略（推荐）——续约失败即视为丢锁，**中断业务并回滚**；激进策略——继续执行赌概率。中断靠业务代码在循环/步骤间检查 `lock.isInterrupted()`，框架只能发信号不能替你停。
5. **误删场景**：Full GC 停顿 35s > 锁 30s 过期 → 醒来 DEL 掉别人的锁（Lua 校验可防误删，但业务已双跑）。
6. **主从切换锁失效**：异步复制下 master 加锁未同步即宕机，新 master 上无此 key，第二个客户端也加锁成功——**Redlock 就是为这个设计的**。
7. **Redlock 争议（Kleppmann vs antirez，2016）**：时钟跳变（NTP/手动调）、进程暂停（GC/换页）都可能让客户端拿着"已过期的锁"继续写。Martin 结论：依赖时钟的锁无法严格互斥，需要 **fencing token**（单调递增版本号，由资源侧丢弃迟到请求）。antirez 回应：混淆了故障模型，fencing 也需改造资源端。**工程共识：资金/强一致场景用 ZooKeeper/etcd + fencing；"尽力而为"互斥用单实例锁或 Redlock 足够。**
8. **性能优化**：Singleflight（实例内选一个线程去竞争，N 实例 N 线程而非 N×M）；本地锁交接（省一次 DEL+SETNX 但有锁泄漏与一致性边界问题，少用）；**釜底抽薪——不用锁**：数据库乐观锁（version 字段 CAS）、一致性哈希把同 key 请求固定路由到同实例（分布式问题退化成单机 ReentrantLock）。

## 支撑的 wiki 页面

- [[distributed-lock]]（争议、fencing token、替代方案为主要增量）
- [[data-sharding]]（一致性哈希路由的应用场景）
