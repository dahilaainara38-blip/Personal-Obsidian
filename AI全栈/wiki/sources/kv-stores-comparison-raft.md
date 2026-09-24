---
title: 素材摘要 · KV 存储对比与 Raft（wohu007）
type: source
domain: data
tags: [selection, architecture, distributed]
status: growing
confidence: medium
source_count: 1
created: 2026-09-24
updated: 2026-09-24
---

# 素材摘要 · KV 存储对比与 Raft（wohu007）

> 一句话：先按「业务数据 vs 元数据」把四个 KV 存储切成两个世界（Redis/Memcached vs etcd/Zookeeper），再展开 etcd 背后的 Raft 共识算法全流程。

- 来源：CSDN（wohu007），发布 2021-08-22 · 收录 2026-09-24
- 原始素材：`raw/kv-stores-comparison-raft.md`
- **素材结构**：前半（§1-3）是选型对比，原创度一般；后半（§4-5）是 Raft/Paxos 算法讲解，Raft 部分明确引自极客时间专栏（time.geekbang.org/column/article/601253）

## 关键论点

1. **四件套按用途分两半**：Redis/Memcached 缓存**业务数据**（高吞吐读写）；etcd/Zookeeper 存储**元数据**（服务名、配置、节点 IP）。选型第一问不是"谁快"，而是"我存的是哪类数据"。
2. **Redis 赢 Memcached 的原因不是性能**——原文明确说"Memcached 性能稍好"，赢在：数据结构（5 种类型 vs 只有 string）、原子操作与事务、主从备份与故障转移、持久化。与 [[redis]] 页结论一致，交叉验证通过。
3. **etcd 赢 Zookeeper 的原因**：Raft（可理解可运维）替代 Paxos（难懂难实现）、v3 纯 KV 结构比 zk 树形遍历快、HTTPS/RBAC/命名空间安全能力、Go 单二进制易部署、HTTP+gRPC 接口、watch 机制。K8s/Traefik/Casbin 背书。
4. **两者都是 CP 系统**：一致性 + 分区容错，牺牲可用性。这是元数据存储的合理取舍。
5. **Raft 三角色循环**：Leader（处理写、心跳）→ Follower（心跳超时则 Term+1 变 Candidate）→ Candidate（拉票，过半当选，随机选举超时 150-300ms 防瓜分选票）。
6. **Raft 核心机制 = 复制状态机**：所有节点持相同日志、按序执行相同命令 → 达到相同状态。Entry 被多数节点认可即 Committed，只有 Committed Entry 会被执行。
7. **两个选举限制防数据丢失**：Leader 必须包含所有过去的 Committed Entry；只有日志最新（Term 最大、同 Term 更长）的节点才能当选。这堵住了"已提交 Entry 被新 Leader 覆盖"的洞。
8. **一致性级别**：Raft 写是线性一致；**读默认只有最终一致**（Follower 可能读到旧数据），要强一致读需转发到 Leader——性能妥协。
9. Paxos 三角色（proposer/acceptor/learner）与两阶段 prepare/accept 只做概览；其"难理解、实现自由度大"正是业界倒向 Raft 的原因。

## 可复用的具体结论

- 选型口诀：**缓存业务数据 → Redis；元数据/服务发现 → etcd；别拿 ZK 新项目当默认**
- Raft 选举超时随机化区间 150-300ms（防多节点同时竞选）
- 强一致读的实现方式：读请求也走 Leader
- 日志一致性判定：相同 (index, Term) ⇒ 相同 Command 且之前全部相同

## 与既有页面的交叉验证

- "Redis 赢 Memcached 靠数据结构而非性能"：与 [[redis]] 核心要点第 1 条**互相印证**，redis.md 可提升该结论置信度
- "6.0 多线程 IO"：本文称 Memcached"多线程架构"为优势，与 [[redis]] 页"6.0 起网络 IO 多线程（命令执行仍单线程）"**不矛盾**，是对同一事实的互补视角
- 未发现矛盾 → 无需标 contested

## 本次收录动作

- 新建：`entities/etcd.md`、`entities/zookeeper.md`、`concepts/raft.md`、`concepts/paxos.md`（合并 Raft/Paxos 对比）、本摘要页
- 更新：`entities/redis.md`（来源+1，Memcached 对比交叉验证）、`index.md`、`log.md`

## 疑点与待验证

- 原文发布于 **2021-08**，etcd/zk 生态五年后的现状（如 K8s 之外的采用度、zk 是否进一步式微）未更新，时效风险
- "etcd 性能比 zk 好"归因于存储结构（KV vs 树），但**没有给出量化数据**，待找 benchmark
- Raft 的租约读（lease read）等性能优化本文未提，只给了"转发 Leader"这一种强一致读
- Consul/Nacos 等国内更常见的注册中心未入对比池，选型图不完整

## 来源

- `raw/kv-stores-comparison-raft.md`
