---
title: 素材摘要 · 分布式锁实现（小林coding）
type: source
domain: data
tags: [redis, distributed-lock, concurrency]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · Redis 分布式锁是怎么实现的（小林coding）

> 一句话：SET NX EX 一条原子命令解决"抢锁+防死锁"，Lua 脚本解决"验身份再删锁"，Redlock 多数派解决单点。

- 来源：https://www.xiaolincoding.com/redis/module/setnx.html · 收录 2026-09-18
- 原始素材：`raw/redis-distributed-lock.md`

## 关键论点

1. **分布式锁四大问题**：锁争抢（查+占两步分离）、僵尸锁（无过期时间+宕机）、锁过期（业务没做完锁先没了→两节点同时操作）、存储单点。
2. **加锁一条命令**：`SET lock_key unique_value NX EX 30` —— NX（互斥）+ EX（防僵尸）+ unique_value（防误删）三件事一次原子完成，杜绝分步执行的中间缝隙。
3. **释放锁用 Lua**：`GET` 比对 value 是自己才 `DEL`——必须原子，否则"刚验完身份锁恰好过期被别人抢走，删掉的是别人的锁"。
4. **看门狗（Watch Dog）**：后台线程定期检查业务是否还在执行、在则续期。**Redisson 已内置**。局限：持锁进程宕机则看门狗同死，锁最终仍会过期释放——业务要"短平快"+异常兜底。
5. **Redlock**：向 ≥3（常 5）个**互相独立**（无主从复制、跨机房）的 Redis 节点加锁，超过半数成功才算持锁；失败则向**全部**节点发起释放。部署：奇数节点、每节点加锁请求超时 50-100ms。
6. **三条实践警告**：看门狗不是万能的；Redlock 勿滥用（非核心业务用"单节点+看门狗"足够）；锁粒度适中（太粗排队、太细锁爆炸）。

## 支撑的 wiki 页面

- [[distributed-lock]]（新建概念页）
- [[redis]]
