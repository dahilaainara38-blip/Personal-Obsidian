---
title: 分布式锁
type: concept
domain: data
tags: [distributed-lock, redis, concurrency, architecture]
status: growing
confidence: medium
source_count: 2
created: 2026-09-18
updated: 2026-09-18
---

# 分布式锁

> 在多节点间保证"同一时刻只有一个执行单元操作共享资源"。Redis 实现的最小闭环：`SET NX EX` 原子加锁 + Lua 原子释放；工业级还要回答等待、重试、续约、中断和高可用五件事。

## 核心要点

- **互斥、防死锁、归属正确**三要素分别由 NX、EX、unique_value 承担，且加锁三要素必须**一条命令原子完成**：`SET lock_key unique_value NX EX 30`。
- **释放必须 Lua**：GET 比对是自己的 value 再 DEL，原子执行——否则会删掉"已过期被别人抢走"的锁。
- **过期时间是防宕机的保险，不是业务闹钟**：取业务 P999 + buffer；正常路径永远由业务主动释放。
- **看门狗续约**解决"业务比锁活得久"：后台线程周期续期；进程宕机看门狗同死，锁自然过期——所以业务要"短平快"+ 兜底。
- **主从异步复制会让锁失效**（主节点加锁未同步即宕机，新主上无此锁）——Redlock 用多数派解决，但它依赖时钟假设，**不是强正确性方案**。
- 最高明的优化是**不用锁**：乐观锁（version CAS）或一致性哈希路由把竞争退化回单机。

## 细节

### 从玩具到工业级的完整阶梯

| 层 | 问题 | 方案 |
|---|---|---|
| 加锁 | 查+占两步分离 | SET NX EX 一条命令 |
| 释放 | 误删他人的锁 | Lua：验 value 再 DEL |
| 等待 | 自旋空耗 | 总等待 ≈ 锁平均持有时间；进阶：订阅锁的 DEL 事件 |
| 重试 | 超时后"我到底锁上没" | 先 GET：nil→重试；=自己 UUID→上次已成功，续期即可；=他人→进等待 |
| 续约 | 业务超时锁先过期 | 看门狗（**Redisson 内置**）；续约失败→保守策略：中断业务回滚（业务代码在循环/步骤间主动查中断标志） |
| 高可用 | 单点/主从切换失效 | Redlock：≥3（常 5）个**独立**节点，超半数加锁成功才算持有；释放要向**全部**节点发起 |

### Redlock 争议（必读）

Kleppmann（DDIA 作者）2016 年质疑：**时钟跳变**（NTP/手动调整）与**进程暂停**（GC/换页几十秒）会让客户端拿着"其实已过期的锁"继续写共享资源——任何依赖时钟的锁都无法严格互斥；正确做法是资源侧配合 **fencing token**（单调递增版本号，丢弃迟到请求）。antirez 回应：混淆了故障模型，fencing 也需要资源端改造。**工程共识：资金/库存类强一致场景用 ZooKeeper/etcd + fencing；去重、防重复执行类"尽力而为"互斥，单实例 Redis 锁或 Redlock 足够。**

### 性能与替代

- **Singleflight**：同实例内同 key 只派一个线程去 Redis 竞争（N 实例 → N 个竞争者而非 N×M）。
- 本地锁交接（持锁线程在内存里把锁转交给本实例下一个等待者，省一次网络往返）：有锁泄漏风险、破坏"Redis 单一仲裁"语义，生产少用。
- **乐观锁替代**：`UPDATE ... SET v=v+1 WHERE id=? AND version=?`，失败重试，无锁高并发。
- **一致性哈希路由**：同 ID 请求固定到同实例 → 分布式问题退化成单机 ReentrantLock（见 [[data-sharding]]）。

## 与其他页面的关系

- 主要载体：[[redis]]（SETNX/Lua）；Java 实现：Redisson（看门狗内置）
- 缓存重建互斥 是 [[cache-pitfalls]] 击穿的标准解；缓存更新的串行化 见 [[cache-coherence]]
- 与单机锁（synchronized/ReentrantLock）的本质关系：语义同源，仲裁者从 JVM 内存换成了共享存储

## 疑点与待验证

- Redisson 看门狗默认续期阈值（lockWatchdogTimeout=30s、每 10s 续）与自定锁 TTL 的交互规则待实测
- fencing token 在 MySQL 资源侧的最简实现（版本号列 + 条件更新）值得写成 practice 页
- etcd/ZooKeeper 锁与 Redis 锁的延迟对比数据缺失，待收录

## 来源

- [[redis-distributed-lock]] — 支撑了三要素、Lua 释放、Redlock 部署与三大陷阱
- [[redis-distributed-lock-ha]] — 支撑了等待/重试/续约/中断策略、Kleppmann 争议、Singleflight 与替代方案
