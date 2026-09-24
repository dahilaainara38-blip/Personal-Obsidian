---
title: Raft 共识算法
type: concept
domain: engineering
tags: [distributed, architecture, consensus]
status: growing
confidence: medium
source_count: 1
created: 2026-09-24
updated: 2026-09-24
---

# Raft 共识算法

> 用"选一个 Leader、日志复制过半即提交"换取分布式强一致的可理解共识算法。etcd、TiDB 等现代分布式系统的标配。

## 核心要点

- **问题域**：不可靠网络 + 会崩溃的节点之间，就"日志内容与顺序"达成一致。
- **核心抽象是复制状态机**：每个节点持一份含相同命令、相同顺序的日志，按序执行 → 所有节点到达相同状态。崩溃恢复后重放日志即可追平。
- **一切写经 Leader**：客户端写请求（到 Follower 也）被转发给 Leader，包装成 Entry 追加进日志，经 AppendEntries RPC 复制；**过半节点认可 = Committed**，只有 Committed Entry 会被状态机执行。
- **三个角色、一个任期**：Leader（写+心跳）/ Follower（心跳超时→升级竞选）/ Candidate（拉票，过半当选）。Term 单调递增，是逻辑时钟——节点见到更大 Term 立即自降为 Follower。
- **随机选举超时（150-300ms）** 是防选票瓜分的关键：几乎总有一个节点先超时、先拉票、先当选。
- **一致性级别**：写线性一致；**读默认最终一致**（Follower 可能读到旧数据），强一致读需转发 Leader——性能妥协，也可用租约读优化（待查）。
- 两种 RPC：RequestVote（竞选拉票）、AppendEntries（复制日志 + 心跳）。

## 细节

### 选举流程

```
Follower 在 election timeout 内没收到 Leader/Candidate 的 RPC
  → Term + 1，自己变 Candidate，给自己投票
  → 向所有节点发 RequestVote
      ├─ 过半票 → 当选 Leader，立刻发 AppendEntries 心跳止选
      ├─ 收到更大 Term 的 AppendEntries → 退回 Follower
      └─ 无人过半（选票瓜分）→ 等下一轮随机超时重来
```

### 日志一致性两个不变式

1. 不同节点日志中 **(index, Term) 相同 ⇒ Command 相同**
2. **(index, Term) 相同 ⇒ 该 Entry 之前的所有 Entry 都相同**

异常场景（a–f 六种崩溃姿势，素材配图）都会破坏不变式，修复手段：**Leader 强制 Follower 日志与自己对齐**——Leader 为每个 Follower 维护 nextIndex，从分歧点起用 AppendEntries 覆盖，Follower 删除不一致尾部。

### 防止已提交 Entry 被覆盖的两个选举限制

最凶险的场景（素材 s1/s5 交替崩溃的例子）：已 Committed 的 Entry 2 被新 Leader 覆盖。Raft 用两条规则堵死：

1. **当选者必须包含所有已提交的 Entry**（日志最新：Term 最大优先，同 Term 更长优先）
2. 数学保证：Committed 意味着 Entry 已在过半节点上，而当选也需过半票 → 选举人集合与持有者集合**必然相交于至少一个节点**，该节点不会投给日志更旧的 Candidate

### 与 Paxos 的关系

Raft 是对 [[paxos]] 核心思想的"工程化重写"：分解为领袖选举、日志复制、安全性三个子问题，每个都可独立理解与测试。Paxos 证明优雅但实现自由度太大，这是业界（etcd、TiDB）倒向 Raft 的根本原因。

## 与其他页面的关系

- 载体：[[etcd]]（生产最大规模应用）
- 对照：[[paxos]]、[[zookeeper]]（Paxos 系阵营）
- 通用件呼应：Quorum 过半思想同 [[redis-cluster|Redis Sentinel 的 quorum]]、[[data-sharding]] 一族——"过半"是分布式容错的通用货币

## 疑点与待验证

- 快照/日志压缩（生产必备，日志不能无限涨）素材未提
- 成员变更（加/减节点时怎么保证两个多数派不相交）素材未提
- 租约读（lease read）、read index 等读优化的具体机制
- "写线性一致"在 Leader 刚当选、尚未确认提交前的心跳空洞期（素材图 d→e 场景的完整时序）值得用 raft.github.io 动画走一遍

## 来源

- [[kv-stores-comparison-raft]] — 角色与选举、日志复制、一致性不变式、选举限制（该部分引自极客时间专栏 601253）
