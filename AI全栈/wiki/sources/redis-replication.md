---
title: 素材摘要 · 主从复制（小林coding）
type: source
domain: data
tags: [redis, replication, architecture]
status: growing
confidence: high
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · 主从复制是怎么实现的（小林coding）

> 一句话：三种模式——全量复制（首次）、长连接命令传播（日常）、增量复制（断线重连）；增量能否走取决于 repl_backlog 环形缓冲区够不够大。

- 来源：https://www.xiaolincoding.com/redis/cluster/master_slave_replication.html · 收录 2026-09-18
- 原始素材：`raw/redis-replication.md`

## 关键论点

1. **首次全量同步三阶段**：`psync ? -1` → 主回 `FULLRESYNC <runID> <offset>` → 主 bgsave 生成 RDB 发送（期间写命令进 **replication buffer**）→ 从清空旧数据载入 RDB → 主补发缓冲区命令。
2. **命令传播**：长连接，主每条写命令实时发给从（避免频繁建连开销）。
3. **增量复制（2.8+）**：断线重连后从带上自己的 offset；主在 **repl_backlog_buffer 环形缓冲区**（默认仅 1MB）里找差距——还在则 `CONTINUE` 增量补发，被覆盖了则退回全量同步。
4. **repl_backlog_size 估算公式**：断线平均重连秒数 × 每秒写量，再 ×2 冗余（例：5s × 1MB/s → 设 10MB）。太小 → 频繁全量同步（fork+bgsave+传输三重开销）。
5. **两个 buffer 的区别**：repl_backlog（每主一个、环形、满了覆盖旧数据）vs replication buffer（每从节点一个、满了断开连接触发重新全量）。
6. **分摊主库压力**：从节点可以有从节点（级联/树状），"经理"节点承接下层同步，避免主库为 N 个从库重复 bgsave。
7. **一致性本质是异步**：主执行完就回客户端，不等从。应对：同机房部署；外部程序 `INFO replication` 监控 master/slave offset 差值超阈值则摘除该从节点。
8. **减少切换丢数据**：`min-slaves-to-write N` + `min-slaves-max-lag T`——从节点数不足 N 或 ACK 延迟超 T 时**主节点拒绝写入**（同时是防脑裂丢数据的关键：旧主在被隔离期间写不进去，网络恢复后被降级为从也不会丢已切换的数据）。文中给出完整参数配合推演（例：min-slaves-to-write 1 / max-lag 12s / down-after 10s / 主卡 15s）。
9. 心跳：主每 10s PING 从；从每 1s `replconf ack <offset>` 上报偏移。过期 key 由主节点生成 DEL 命令同步给从（**从库不自己做过期扫描**）。

## 支撑的 wiki 页面

- [[redis-cluster]]（复制机制细节、min-slaves 防脑裂）
- [[redis-persistence]]（全量同步复用 bgsave/COW）、[[redis]]
