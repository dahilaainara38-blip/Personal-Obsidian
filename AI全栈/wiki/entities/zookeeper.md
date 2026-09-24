---
title: Zookeeper
type: entity
domain: infra
tags: [distributed, metadata, consensus]
status: growing
confidence: medium
source_count: 1
created: 2026-09-24
updated: 2026-09-24
---

# Zookeeper

> 老牌分布式协调服务，树形 ZNode 存储 + Paxos 系共识（ZAB）。Hadoop 时代的元数据标准，正被 etcd 取代。

## 核心要点

- 与 [[etcd]] 同赛道：存**元数据**、走 **CP** 路线，但两处关键落后：共识用 [[paxos]] 系（ZAB，难懂难实现）、存储是**树形 ZNode**（访问要遍历，慢于 etcd v3 的平坦 KV）
- **新项目默认不该再选它**——素材原文即持此立场，K8s/Traefik/Casbin 等新一代系统均选 etcd
- 但存量巨大：Hadoop/HBase/Kafka（旧版依赖 ZK，KRaft 模式已在去 ZK 化）/Dubbo 老版本仍大量在用，**面试与维护旧系统绕不开**
- 安全（基础 ACL vs etcd 的 HTTPS/RBAC）、部署（Java 系 vs Go 单二进制）、接口（自有协议 vs HTTP/gRPC）全面处于下风

## 细节

（本页暂为骨架。ZAB 协议、ZNode/watcher 语义、临时节点做服务发现等核心机制，当前素材未展开，待补专门素材后填充。）

## 与其他页面的关系

- 被替代者视角对照：[[etcd]]（详细对比表在那边）
- 共识族谱：[[paxos]]（ZAB 属 Paxos 变种）
- 与 [[redis]] 不同用途，勿混

## 疑点与待验证

- ZAB 与标准 Paxos 的具体差异（素材只说"用的 Paxos"，ZAB 是其变种）——待专门素材
- KRaft 模式（Kafka 去 ZK）的成熟度与迁移现状
- Curator 客户端的当前维护状态

## 来源

- [[kv-stores-comparison-raft]] — 与 etcd 的对比、生态趋势
