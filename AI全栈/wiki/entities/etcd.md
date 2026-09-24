---
title: etcd
type: entity
domain: infra
tags: [distributed, metadata, k8s, consensus]
status: growing
confidence: medium
source_count: 1
created: 2026-09-24
updated: 2026-09-24
---

# etcd

> 分布式键值存储，专存**元数据**（服务、配置、节点信息），靠 Raft 提供 CP 语义。Kubernetes 的心脏。

## 核心要点

- **定位：元数据存储，不是缓存。** 与 [[redis]] 分属两个世界：etcd 存"系统怎么组织"，Redis 存"业务怎么加速"。混用是架构错误。
- **CP 系统**：一致性与分区容错优先，牺牲可用性——元数据宁可暂时不可写，不可错。
- 共识层用 [[raft]]，胜在可理解、可运维（对比 [[paxos]]）
- v3 起纯 **KV 平坦结构**（对比 Zookeeper 树形），读取无需遍历
- **watch 机制**：客户端订阅 key 变更实时收到通知——配置热更新的基础设施
- 每次修改生成**自增修订 ID + 任期 ID**，天然带版本控制
- 生产部署：**奇数节点**（通常 3/5），过半存活才可用

## 细节

### 为什么赢过 Zookeeper

| 维度 | etcd | Zookeeper |
|---|---|---|
| 共识 | Raft | Paxos |
| 存储 | v3 纯 KV，直接寻址 | 树形 ZNode，访问要遍历 |
| 安全 | HTTPS、RBAC、命名空间 | 基础 ACL |
| 部署 | Go 单二进制 | Java 系，重 |
| 接口 | HTTP + gRPC | 自有客户端协议 |
| 生态 | K8s/Traefik/Casbin | Hadoop 系遗产 |

### 典型用法

- 服务注册发现（秒杀系统经注册中心拿商品中心/交易中心的元数据）
- 配置中心：管理后台改配置 → etcd watch 推送到全部 API 节点
- 集群协调：控制消费 MQ 的服务实例数

## 与其他页面的关系

- 共识内核：[[raft]]（写线性一致；读默认最终一致，强读走 Leader）
- 对照系：[[zookeeper]]（旧王）、[[redis]]（不同用途，勿混）
- 同族场景：[[data-sharding|分片]]、Quorum——分布式元数据治理的通用件

## 疑点与待验证

- 素材是 2021 年的，**当前版本与采用度未更新**；Consul/Nacos 未入对比池
- "比 zk 快"缺量化 benchmark
- watch 的性能边界（百万级 watcher？）未验证
- JVM 侧客户端（jetcd）成熟度待查——对 Java 全栈场景是关键缺口

## 来源

- [[kv-stores-comparison-raft]] — 定位、与 zk/redis 的分工、Raft 用法、watch 机制
