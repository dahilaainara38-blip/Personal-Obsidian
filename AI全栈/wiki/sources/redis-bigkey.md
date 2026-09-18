---
title: 素材摘要 · 大 Key 对持久化的影响（小林coding）
type: source
domain: data
tags: [redis, persistence, pitfall, performance]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · Redis 大 Key 对持久化有什么影响（小林coding）

> 一句话：大 Key 从三个环节阻塞主线程——Always 的 fsync、fork 复制页表、COW 复制物理页；内存大页会把它放大 512 倍。

- 来源：https://www.xiaolincoding.com/redis/storage/bigkey_aof_rdb.html · 收录 2026-09-18
- 原始素材：`raw/redis-bigkey.md`（字节面试题引出）

## 关键论点

1. **Always 策略 + 大 Key**：主线程同步 fsync 大数据量，阻塞久。Everysec 明显减轻（fsync 在 BIO 线程），但 `write()` 本身同步执行、且**上次 fsync 未完成时 write 会被迫等待**；No 策略无此问题。
2. **fork 阻塞与页表成正比**：fork 不复制物理内存但复制页表；大 Key 多 → 内存大 → 页表大 → fork 久 → 阻塞主线程。监控指标 `info` 的 `latest_fork_usec`，超过 1 秒必须处理。
3. **fork 优化三招**：单实例内存控制在 **10GB 以下**；纯缓存场景关 AOF/重写（不再 fork）；调大 `repl-backlog-size` 避免从节点频繁全量同步（全量同步要 bgsave → fork）。
4. **COW + 大 Key**：快照/重写期间修改大 Key，复制物理页耗时 → 阻塞。
5. **⚠️ 内存大页（THP）陷阱**：2MB 页 vs 常规 4KB，改 100B 也要复制 2MB（放大 512 倍）。默认关闭，若开了要关：`echo never > /sys/kernel/mm/transparent_hugepage/enabled`。
6. **大 Key 的其他危害**：命令执行阻塞（单线程）、网络流量（1MB key × 1000 QPS = 千兆网卡打满）、DEL 阻塞、集群槽倾斜。删除用 `unlink`（4.0+ 异步）。

## 支撑的 wiki 页面

- [[redis-persistence]]、[[copy-on-write]]（fork 两阶段阻塞、THP 放大）
- [[redis]]（大 Key 危害清单与治理）
