---
title: Redis 高可用与集群
type: concept
domain: data
tags: [redis, architecture, distributed, cache, ha]
status: growing
confidence: high
source_count: 5
created: 2026-09-18
updated: 2026-09-18
---

# Redis 高可用与集群

> 从单实例到 Cluster 是"用复杂度换能力"的阶梯：主从换冗余、Sentinel 换自动故障转移、Cluster 换容量。贯穿全部形态的一条事实：**复制是异步的**——所有丢数据风险都源于此。

## 核心要点

- 四档形态各解决一个问题：单实例（快无 HA）→ 主从（读扩展/冗余）→ Sentinel（自动故障转移+服务发现）→ **Cluster（水平扩容，哨兵给不了容量——6 台 64G 主从的可用内存仍是 64G）**。
- 主从复制三模式：**全量复制**（首次，bgsave RDB + replication buffer 补发）、**长连接命令传播**（日常）、**增量复制**（断线重连，靠 repl_backlog 环形缓冲区）。
- Sentinel 两轮投票：①quorum 票判**客观下线**；②半数以上且 ≥quorum 选出执行切换的 **leader 哨兵**。哨兵 ≥3 取奇数、quorum = N/2+1。
- Cluster 数据分片用 **16384 哈希槽**（见 [[data-sharding]]）；客户端是 Smart Client（本地缓存槽表），错了靠 **MOVED（永久搬家）/ ASK（迁移中临时借道）** 重定向。
- **Cluster 偏 AP 会丢数据**：异步复制 + 故障转移存在丢失窗口；强一致场景要 DB 兜底或 etcd/ZooKeeper。

## 细节

### 复制机制深挖

- 首次同步三阶段：`psync ? -1` → 主回 `FULLRESYNC <runID> <offset>` → bgsave 发 RDB（期间写命令入 replication buffer）→ 从清空载入 RDB → 主补发缓冲区命令。
- **增量复用的前提**：断线期间的写命令还在 **repl_backlog_buffer**（环形，默认仅 1MB）里；被覆盖则退回全量。大小估算 = 断线平均重连秒数 × 每秒写量 × 2。
- 两个 buffer 的区别：repl_backlog 每主一个、环形、满了覆盖旧数据；replication buffer 每从一个、满了**断开连接重新全量**。
- 从节点可级联（"经理"节点）分摊主库 bgsave/传输压力。
- 心跳：主每 10s PING 从；从每 1s `replconf ack <offset>` 上报。**从库不做过期扫描**，过期 key 由主库发 DEL 同步。

### Sentinel 深挖

- 主观下线（单哨兵 PING 超时 down-after-milliseconds）→ 问其他哨兵拉票 → ≥quorum = 客观下线 → 第一个判定的哨兵成为候选者 → 拉票选 leader（半数以上 且 ≥quorum；每哨兵一票先到先得）。
- **为什么至少 3 个且奇数**：2 个哨兵挂 1 个永远凑不齐票；推演（1主4从5哨兵 quorum=3）：挂 2 个哨兵仍可判定+切换，挂 3 个只能判定不能切换（所以 quorum 设 N/2+1 让判定与切换能力对齐）。
- 选新主三轮：过滤（下线 + 断连超限）→ `slave-priority` 小 → `slave_repl_offset` 最接近 master → runID 小。
- 故障转移四步：新主 `SLAVEOF no one` → 其余从节点指向新主 → `+switch-master` 频道 pub/sub 通知客户端 → 旧主回归降级为从。
- 哨兵集群自组成：订阅主节点 `__sentinel__:hello` 频道相互发现；每 10s INFO 主节点拿从节点列表。

### Cluster 深挖

- **Smart Client**：启动拉取"槽→节点"表缓存本地，CRC16 算槽直接命中（Jedis/Lettuce/go-redis/`redis-cli -c`）。
- **MOVED vs ASK**：MOVED = 槽永久易主 → 更新本地表并重发；ASK = 槽迁移中 → **不更新表**，先发 `ASKING`（目标节点破例处理这一次）再发请求。这是不停机迁移的关键。
- **Gossip 状态同步**：ping/pong（每秒随机节点、捎带集群状态）、meet（新节点握手）、fail（广播下线）。**集群总线端口 = 业务端口+10000（16379），防火墙必须两个都放**。消息量随节点数平方增长 → 官方建议主节点 ≤1000。
- **故障转移**：pfail（单节点主观）→ 超半数持槽主节点认定 → fail 广播；选主：资格检查（失联太久出局）→ **复制越新等待越短**排队发起 → 仅持槽主节点有投票权、一轮一票 → 半数当选。
- **两个新手坑**：①多 key 操作报 CROSSSLOT → **Hash Tag** `{user:1}:name`（只按花括号内算槽，MSET/事务/Lua/pipeline 同理）；②从节点默认拒读（MOVED 回主），`READONLY` 后可读（接受旧数据）。

### 丢数据两来源与缓解（主从通用）

1. **异步复制窗口**：主写完即回客户端，未同步就宕机则丢。缓解：`min-slaves-to-write N` + `min-slaves-max-lag T`——从节点不足或 ACK 延迟超限时**主拒写**。
2. **脑裂**：旧主被网络隔离期间接受写入，哨兵已切新主；旧主回归被降级从库、清空重同步 → 隔离期写入全丢。上面两参数同样是解法：隔离期内旧主凑不齐 ACK 就写不进去。
3. 代价：拿可用性换一致性（主可能频繁拒写），参数要配合 down-after-milliseconds 推演（例：to-write=1 / max-lag=12s / down-after=10s）。

## 与其他页面的关系

- 上层实体 [[redis]]；分片原理 [[data-sharding]]；数据可靠性 [[redis-persistence]]
- 主从切换导致锁失效 → [[distributed-lock]] 的 Redlock 动机
- 通用分布式概念（Quorum、脑裂、Gossip、CAP 取舍）可迁移到注册中心、K8s 等系统

## 疑点与待验证

- ~~客户端重连/拓扑刷新、MOVED/ASK、16384 之谜~~ —— **本次收录已补齐**（2026-09-18）
- min-slaves-* 已更名 min-replicas-*（新版本），确切版本边界待核实
- Cluster 的读写分离（READONLY）在实际客户端库中的封装与坑待实践
- "为什么 2 副本"的严格推导（vs 1 副本）仍缺数学论证，见 [[data-sharding]]

## 来源

- [[redis-overview]] — 四档阶梯框架、复制 ID/偏移量、Gossip/脑裂概念（机翻稿）
- [[redis-replication]] — 三种复制模式、repl_backlog、两 buffer、min-slaves 防丢
- [[redis-sentinel]] — 两轮投票、选主三轮考察、故障转移四步、哨兵集群自组成
- [[redis-cluster-why]] — 容量动机、Smart Client、MOVED/ASK、Gossip、CROSSSLOT、偏 AP
