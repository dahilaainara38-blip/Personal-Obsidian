---
title: 素材摘要 · Redis 底层数据结构（小林coding）
type: source
domain: data
tags: [redis, data-structure]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · Redis 数据结构（小林coding）

> 一句话：9 种底层结构支撑 5 种数据类型；主线是"ziplist 的连锁更新问题 → quicklist 缓解 → listpack 根治"，外加跳表与渐进式 rehash 两个经典设计。

- 来源：https://www.xiaolincoding.com/redis/data_struct/data_struct.html · 收录 2026-09-18
- 原始素材：`raw/redis-data-structures.md`（1.5 万字长文，源码级）

## 关键论点

1. **键值对全景**：redisDb → dict（含 ht[2] 双哈希表）→ dictEntry（void* key/value 指向 redisObject：type + encoding + ptr）。"类型"与"结构"分离，encoding 记录实际用的结构。
2. **SDS**：len/alloc/flags 三元数据解决 C 字符串三大缺陷（O(N) 取长度、`\0` 不二进制安全、缓冲区溢出）；空间预分配（<1MB 翻倍、≥1MB 加 1MB）；sdshdr5/8/16/32/64 按长度选头部长度 + `__attribute__((packed))` 取消对齐省内存。
3. **ziplist（压缩列表）与连锁更新**：连续内存省空间；每个 entry 记 **prevlen**（前节点 <254B 用 1 字节，否则 5 字节）——插入大节点可能引发后续节点 prevlen 1→5 字节的**多米诺式连锁重分配**。
4. **quicklist（3.2）**：双向链表，每个节点装一个小 ziplist——控制单节点大小以缓解（但不根治）连锁更新。List 类型从此只用它。
5. **listpack（5.0 设计，7.0 替换 ziplist）**：只记录**自身**节点长度、不记前节点 → 从根上消灭连锁更新。Hash/Zset 的紧凑编码改用它。
6. **哈希表**：链式哈希解决冲突；**渐进式 rehash**——ht[2] 双表，增删改查时顺带迁移少量桶，查询两表都查、新增只进新表。触发：负载因子 ≥1（且无 bgsave/bgrewriteaof）或 ≥5 强制。
7. **跳表（仅 Zset 用）**：多层有序链表 O(logN)；节点含 backward 指针 + level[]（forward + **span 跨度，用于 O(logN) 算排位/排名**）；层数随机生成（每次 25% 概率 +1，最高 32 层（7.0）；头节点直接建满 64/32 层）。**为什么不用平衡树**（antirez 原话三理由）：内存可调（p=1/4 平均约 2.33 指针/节点）、范围查询链式遍历缓存友好、实现简单。Zset = dict（O(1) 查分）+ skiplist（范围查询）双结构。
8. **intset**：全整数小集合用；只升不降级（int16→int32 扩容原地重排）。

## 支撑的 wiki 页面

- [[redis-internals]]（新建概念页）
- [[redis]]、[[redis-data-types]]（同系列姐妹篇）
