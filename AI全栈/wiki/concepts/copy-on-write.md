---
title: 写时复制（Copy-on-Write）
type: concept
domain: engineering
tags: [concurrency, performance, os, java, redis]
status: growing
confidence: medium
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 写时复制（Copy-on-Write, COW）

> 一种延迟复制策略：**先共享，到真要改的时候才复制**。把"复制"的成本从必然支出变成按需支出。

## 核心要点

- 一句话：**读时共享，写时复制。**
- 适用前提是**读多写少，或者写只集中在一小部分数据上** —— 这是它划算的前提，也是它的边界。
- 它同时出现在两个看似无关的层面：**操作系统进程 fork**（Redis 持久化的基础），和**应用层并发容器**（Java 的 `CopyOnWriteArrayList`）。
- 本质是一种**用写放大换读无锁/快照一致性**的权衡。

## 细节

### 场景一：进程 fork（OS 层）

父进程 `fork` 子进程时，不立即复制内存，而是让二者**共享同一批内存页**。只有当某个页被修改时，内核才把该页复制一份给修改方。

结果：如果复制期间没有任何写入，**完全不发生内存复制** —— 于是可以用极小的额外内存，拿到数千 GB 内存的时间点快照。

典型应用：[[redis-persistence]] 的 RDB 快照。子进程拿着"冻结"的内存视图慢慢写盘，主进程继续服务。

### 场景二：并发容器（应用层）

`CopyOnWriteArrayList`：读操作**完全无锁**直接访问当前数组；写操作则复制一份新数组、改完再原子替换引用。

| | 读 | 写 |
|---|---|---|
| 代价 | 极低（无锁） | 高（复制整个数组） |
| 一致性 | 可能读到旧快照（弱一致） | 强一致 |

适用：**监听器列表、配置注册表、路由表** —— 几百个元素、几乎不写、读极其频繁。
不适用：频繁增删的大列表 —— 每次写都复制整个数组，直接把内存和 GC 打爆。

### 什么时候不该用 COW

- 写多读少 → 复制成本远大于锁的成本
- 数据量大且写频繁 → 内存与 GC 压力失控
- 要求强一致的读 → COW 的读天然可能拿到旧快照

## 与其他页面的关系

- 被 [[redis-persistence]] 依赖（RDB 快照的底层机制）
- 上层实体：[[redis]]
- Java 侧对应：`CopyOnWriteArrayList` / `CopyOnWriteArraySet`（`java.util.concurrent`）
- 同族思路：MVCC、快照隔离 —— 都是"用版本/副本来避免阻塞读"

## 疑点与待验证

- Java 的 `CopyOnWriteArrayList` 在大列表上的真实 GC 压力量级，缺实测数据
- Redis fork 在超大实例（数十 GB 以上）时的延迟尖刺有多严重？经验阈值待查
- COW 与 MVCC 的边界在哪里？两者都靠"多版本"，但 COW 是复制整块、MVCC 是版本链，需要澄清

## 来源

- [[redis-overview]] — 支撑了 fork + COW 的机制描述
- Java 侧部分属于外部常识，**未经素材验证**，用时请自行核实
