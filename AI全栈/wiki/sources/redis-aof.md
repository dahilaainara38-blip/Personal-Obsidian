---
title: 素材摘要 · AOF 持久化（小林coding）
type: source
domain: data
tags: [redis, persistence]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · AOF 持久化是怎么实现的（小林coding）

> 一句话：AOF 先执行命令后追加日志；三种写回策略本质是 fsync() 时机；靠 bgrewriteaof 子进程 + COW 做后台重写压缩。

- 来源：https://www.xiaolincoding.com/redis/storage/aof.html · 收录 2026-09-18
- 原始素材：`raw/redis-aof.md`（原创中文，质量好）

## 关键论点

1. **先执行命令，后写 AOF**：避免语法检查开销、不阻塞当前命令；代价是宕机时未落盘数据丢失、可能阻塞"下一个"命令（写日志在主进程）。
2. **写回三策略 = fsync() 调用时机**：Always（每次同步刷盘，最可靠最慢）/ Everysec（BIO 后台线程每秒 fsync，折中）/ No（交给 OS，最快丢数据不定）。写路径：命令 → `aof_buf` → `write()` 到 page cache → 内核决定落盘。
3. **重写机制**：按"当前键值对最新状态"各生成一条命令写入新文件，覆盖旧文件——多条历史命令压成一条。写新文件而非复用，是为了重写失败不污染现有 AOF。
4. **后台重写 bgrewriteaof**：子进程读全量数据生成新 AOF，主进程继续服务。重写期间主进程写命令**双写**「AOF 缓冲区 + AOF 重写缓冲区」；子进程完成后发信号，主进程把重写缓冲区追加进新文件并改名替换（信号处理函数会短暂阻塞主进程）。
5. **fork 只复制页表不复制物理内存**，改内存才触发写时复制——所以选子进程而非线程（免加锁）。
6. **Redis 7.0 Multi-Part AOF**：拆为 manifest（清单）+ base（RDB 格式全量）+ 若干 incr（AOF 增量）；重写只需开新 incr + 子进程写 base + 原子更新 manifest，废除重写缓冲区，主进程压力更小。

## 可复用结论

- 选型：高性能选 No、高可靠选 Always、默认推荐 Everysec（最多丢 1 秒）
- 重写触发：AOF 文件超过阈值（示例 64MB）
- AOF 恢复慢的原因：单线程顺序重放每条命令

## 支撑的 wiki 页面

- [[redis-persistence]]（fsync 三档语义、AOF rewrite、MP-AOF —— 均为该页原"疑点与待验证"项，本次补齐）
- [[copy-on-write]]（fork 页表复制 + 写保护中断的机制描述）
