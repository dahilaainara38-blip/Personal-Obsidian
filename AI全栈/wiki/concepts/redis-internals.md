---
title: Redis 底层数据结构
type: concept
domain: data
tags: [redis, data-structure, performance]
status: growing
confidence: medium
source_count: 2
created: 2026-09-18
updated: 2026-09-18
---

# Redis 底层数据结构

> 类型（String/List/Hash/Set/Zset）与结构（SDS/ziplist/quicklist/listpack/dict/skiplist/intset）分离，`encoding` 字段按数据大小动态切换——小数据用紧凑结构省内存，大数据换高效结构。

## 核心要点

- **演进主线是"连锁更新"的消灭史**：ziplist 有连锁更新隐患 → quicklist（3.2）用"链表套小 ziplist"缓解 → listpack（5.0 设计、7.0 替换）只记自身长度，根治。
- **SDS** 用 len/alloc/flags 三个元数据解决 C 字符串三大缺陷：O(1) 取长度、二进制安全、不会缓冲区溢出。
- **哈希表用渐进式 rehash**：ht[2] 双表 + 每次操作顺带迁移，把一次性大迁移的开销摊到日常请求里——与 [[redis-persistence]] 的后台重写思路同构。
- **跳表（skiplist）只服务于 Zset**：多层链表 O(logN)，span 跨度支持 O(logN) 算排名；层数随机生成（每层 25% 概率），不做严格平衡。
- **Zset 是 dict + skiplist 双结构**：哈希管 O(1) 点查分值，跳表管范围查询。

## 细节

### 类型 → 结构映射（随版本演进）

| 类型 | 旧（≤3.0） | 现代 |
|---|---|---|
| String | SDS（int / embstr / raw，边界 32→39→44B 随版本） | 同左 |
| List | 双向链表 / ziplist | **quicklist（3.2+）**，节点内 ziplist 于 7.0 换 listpack |
| Hash | ziplist / 哈希表 | **listpack（7.0+）** / 哈希表 |
| Set | intset / 哈希表 | 同左 |
| Zset | ziplist / 跳表 | **listpack（7.0+）** / 跳表 |

紧凑编码切换阈值（默认）：list/hash 512 元素或 64B 值；zset 128 元素。

### 连锁更新（ziplist 的原罪）

每个 entry 记 **prevlen**（前节点长度：<254B 占 1 字节，≥254B 占 5 字节）。连续多个 250-253B 节点前插入大节点 → 第一个的 prevlen 1→5 字节 → 自身长度破 254 → 下一个也要扩 → **多米诺全表重分配**。listpack 的解法：只记录**自己**的 encoding+data+len，新节点不影响任何旧节点。

### 渐进式 rehash

- dict 含 ht[2]：平时只用 ht[0]；rehash 时给 ht[1] 分配 2 倍空间，**每次增删改查顺带迁移 ht[0] 一个桶**，迁完交换。
- 期间：查两表、新增只进 ht[1]（保证 ht[0] 只减不增）。
- 触发：负载因子 ≥1 且无 bgsave/bgrewriteaof（子进程期间尽量不动内存），或 ≥5 无条件强制。

### 跳表为什么不用平衡树（antirez 的三个理由）

1. 内存可调：p=1/4 时平均每节点约 2.33 个指针，参数可压比 B 树省；
2. ZRANGE 类范围操作 = 沿底层链表遍历，缓存局部性不差于平衡树且实现直白；
3. 实现/调试简单得多（插入删除只改相邻指针）。

### 其他

- intset：全整数小集合，升级（int16→32→64 原地扩容重排）**不降级**。
- `__attribute__((packed))` 取消结构体对齐，sdshdr 按实际字节分配省内存。

## 与其他页面的关系

- 上层实体：[[redis]]（类型与场景选型见 [[redis-data-types]]）
- fork 共享只读内存 → [[copy-on-write]]；后台重写同构思路 → [[redis-persistence]]

## 疑点与待验证

- Redis 7.x listpack 全面替换后的实际性能收益（官方 benchmark 与生产数据）待查
- 跳表 span 排位计算（ZRANK O(logN)）的实现细节，源码级理解待补
- 面试题：dictEntry 的 value 联合体（指针/uint64/int64/double 内嵌）如何省一次指针跳转——已从源码确认结构，但 Set 场景浪费 val 8 字节的问题值得深挖

## 来源

- [[redis-data-structures]] — 支撑了 9 种结构的机制与演进史
- [[redis-data-types]] — 支撑了类型→结构映射与编码切换阈值
