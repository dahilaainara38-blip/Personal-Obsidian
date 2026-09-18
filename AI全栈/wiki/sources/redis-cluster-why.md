---
title: 素材摘要 · 为什么要有 Redis Cluster（小林coding）
type: source
domain: data
tags: [redis, cluster, distributed, sharding]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · 为什么要有 Redis Cluster 集群（小林coding）

> 一句话：Cluster 解决的是"容量"问题（哨兵只做冗余不做扩容）；Smart Client 缓存槽表 + MOVED/ASK 重定向 + Gossip 同步状态；整体偏 AP。

- 来源：https://www.xiaolincoding.com/redis/cluster/cluster.html · 收录 2026-09-18
- 原始素材：`raw/redis-cluster-why.md`（信息密度最高的一篇）

## 关键论点

1. **哨兵解决不了容量**：主从存的是同一份数据，6 台 64G 机器可用内存仍是 64G。Cluster = 官方切片集群（3.0+），容量随节点数线性扩展。
2. **Smart Client**：客户端启动时拉取"槽→节点"映射表缓存在本地，每次请求本地算槽（CRC16）直接命中。Jedis/Lettuce/go-redis/`redis-cli -c` 都是。
3. **MOVED vs ASK**：MOVED = 槽**永久**搬家 → 客户端更新地图并重发；ASK = 槽**正在迁移**中的临时借道 → 不更新地图，先发 `ASKING`（让目标节点破例处理这一次）再发请求。没有 ASK 就无法不停机迁移。
4. **Gossip**：去中心化状态同步。消息四类 ping/pong（每秒随机节点、携带集群状态）/meet（新节点加入握手）/fail（广播下线）。**集群总线端口 = 业务端口 + 10000（6379→16379），防火墙两个都要放**。代价：消息量随节点数**平方级**增长 → 官方建议主节点 ≤1000。
5. **故障转移**：pfail（单节点主观认为挂了）→ 超半数持槽主节点都 pfail → fail（客观下线）广播。选主：资格检查（`cluster-replica-validity-factor` 失联太久出局）→ **复制越新等待越短**（排队发起选举）→ 向所有持槽主节点拉票（**只有持槽主节点有投票权**，一轮一票先到先得）→ 半数以上当选。从节点默认不服务读（MOVED 回主），`READONLY` 命令后可读（接受旧数据）。
6. **⚠️ Cluster 偏 AP 会丢数据**：主从异步复制 + 故障转移 = 有丢失窗口。强一致场景（资金/库存）要 DB 兜底或 ZooKeeper/etcd。
7. **两个新手坑**：①多 key 操作（MSET/事务/Lua/pipeline）报 `CROSSSLOT` → 用 **Hash Tag** `{user:1}:name` 让相关 key 只按花括号内内容算槽、落同槽；②从节点读要先 `READONLY`。
8. **为什么是 16384**（antirez 本人在 GitHub 的回答）：①Gossip 每秒带槽位图，65536 槽 = 8KB、16384 槽 = **2KB**，省带宽；②槽数要 > 最大节点数（≤1000 主节点时 16384/1000≈16 槽/节点，均衡够用；8192 太紧）；③16384=2^14，取模可写成位运算 `CRC16(key) & 16383`。

## 支撑的 wiki 页面

- [[redis-cluster]]、[[data-sharding]]（"为什么 16384"正是该页积压的疑点，本次补齐）
