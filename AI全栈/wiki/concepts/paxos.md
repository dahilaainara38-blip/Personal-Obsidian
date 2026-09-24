---
title: Paxos 共识算法
type: concept
domain: engineering
tags: [distributed, architecture, consensus]
status: growing
confidence: low
source_count: 1
created: 2026-09-24
updated: 2026-09-24
---

# Paxos 共识算法

> Lamport 于 1980s 末提出的容错共识算法，分布式一致性的理论基石。数学优雅但难懂难实现，实践中多被 Raft 取代。

## 核心要点

- **三角色**：proposer（提议值）/ acceptor（选择值）/ learner（学习被选中的值）——节点可兼任多角。
- **两阶段**：prepare（proposer 向过半 acceptor 申请编号 n）→ accept（携带已知最大编号对应的值，过半接受即选定）。
- **核心机制**：proposer 与过半 acceptor 的"预沟通"——先探明自己的提案是否可能被接受，不行就换策略（加大编号或转投已有值），最终过半收敛于一个值。
- **线性一致写的来源**：提议编号保证"后接受的值编号必更大"，等价于写操作的线性一致。
- **历史地位与现实**：理论基石，但官方描述缺实现细节、实现方式过于自由——这是工程界倒向 [[raft]] 的根本原因。Zookeeper 的 ZAB 属其变种（见 [[zookeeper]]）。

## 细节

（本页为骨架级。Multi-Paxos、活锁、proposal 编号的 round-robin 分配等关键机制素材未展开，待专门素材后填充。）

### 两阶段速记

```
proposer: 选编号 n → prepare(n) → 过半 acceptor
acceptor: 承诺不再接受 <n 的提议，返回已接受的最大编号值
proposer: 取回复中最大编号的值（或自己的值）→ accept(n, v) → 过半接受 → 选定
learner:  被通知选定值
```

## 与其他页面的关系

- 被工程化替代：[[raft]]（详细对比在那边）
- 变种载体：[[zookeeper]]（ZAB）
- 与 [[etcd]] 无直接关系（etcd 是 Raft 阵营）

## 疑点与待验证

- 本页信息来自一篇 2021 年的综述性文章，**置信度标 low**：Paxos 细节（两阶段的边界条件、LiveLock 规避）需要原始论文或权威解读验证
- Multi-Paxos 与 Basic Paxos 的差异完全未覆盖
- "Paxos 保证写线性一致"这句话的严格前提条件（读路径呢？）待验证

## 来源

- [[kv-stores-comparison-raft]] — 三角色、两阶段流程、与 Raft 的工程取舍
