---
title: 素材摘要 · RDB 快照（小林coding）
type: source
domain: data
tags: [redis, persistence]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · RDB 快照是怎么实现的（小林coding）

> 一句话：RDB 是全量二进制快照；save 阻塞主线程、bgsave 靠 fork+COW 不阻塞；快照期间的新写入进不了本次 RDB。

- 来源：https://www.xiaolincoding.com/redis/storage/rdb.html · 收录 2026-09-18
- 原始素材：`raw/redis-rdb.md`

## 关键论点

1. **save vs bgsave**：save 在主线程生成（阻塞）；bgsave 创建子进程（不阻塞）。自动快照配置 `save 900 1 / 300 10 / 60 10000`，满足任一即触发 **bgsave**。
2. **全量快照、频率两难**：太频繁伤性能，太稀疏丢数据多。通常至少 5 分钟一次 = 最多丢 5 分钟。
3. **bgsave 期间数据可改**：fork 复制页表共享物理内存，主线程改某页时才 COW 复制，子进程继续写"旧视图"——**因此快照期间主线程的修改不会进本次 RDB，只能等下一次**。
4. **COW 极端情况**：快照期间所有共享页都被修改 → 内存占用翻倍。写多场景要监控内存。
5. **RDB vs AOF**：RDB 是二进制实际数据（加载快），AOF 是命令日志（更完整、恢复慢）。

## 可复用结论

- **混合持久化（Redis 4.0，`aof-use-rdb-preamble yes`）**：AOF 重写时前半段写 RDB 全量、后半段写 AOF 增量——启动快 + 丢数据少，生产推荐。代价：文件可读性差、不兼容 4.0 前版本。

## 支撑的 wiki 页面

- [[redis-persistence]]（补齐混合持久化、save/bgsave、COW 快照语义）
- [[copy-on-write]]
