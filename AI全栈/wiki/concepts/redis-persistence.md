---
title: Redis 持久化
type: concept
domain: data
tags: [redis, persistence, architecture]
status: growing
confidence: high
source_count: 5
created: 2026-09-18
updated: 2026-09-18
---

# Redis 持久化

> 核心矛盾：**单线程命令执行不能被磁盘 IO 阻塞**。解法是把落盘整体挪出主进程（fork 子进程 + 写时复制），用"最多丢多少"换"跑多快"。

## 核心要点

- 四种选择：**无持久化 / RDB / AOF / RDB+AOF 混合**，决策轴就两条——能丢多少数据、重启要多快。
- **AOF 三种写回策略本质是 fsync() 时机**：Always（每命令同步刷盘）慢而最可靠；Everysec（BIO 线程每秒）默认折中，最多丢 1 秒；No（交给 OS）最快丢得随机。
- **AOF 重写**按"当前键值最新状态"一 key 一命令压缩日志，bgrewriteaof 子进程后台执行，主进程照常服务。
- **混合持久化（4.0+，`aof-use-rdb-preamble yes`）是生产推荐**：AOF 前半 RDB 全量（启动快）+ 后半 AOF 增量（丢得少）。
- **fork 有两段阻塞**：复制页表（内存越大页表越大，fork 越久——实例建议 <10GB）；重写/快照期间改大 Key 触发 COW 复制物理页。监控 `latest_fork_usec`。

## 细节

### 全景对照

| 方式 | 机制 | 丢多少 | 恢复速度 | 适用 |
|---|---|---|---|---|
| 无 | 不落盘 | 全丢 | — | 纯缓存可重建 |
| RDB | 定时**全量**二进制快照（save 阻塞 / bgsave 子进程） | 两次快照之间 | 快（直接载入） | 可容忍分钟级丢失 |
| AOF | 追加写命令日志，先执行后记录 | 最多 1 秒（Everysec） | 慢（逐条重放） | 不可丢数据 |
| 混合 | AOF 重写时 = RDB 头 + AOF 尾 | ≈AOF | 快 | **默认推荐** |

自动快照默认配置：`save 900 1 / 300 10 / 60 10000`（满足任一触发 bgsave）。

### AOF 深挖

- **为什么先执行后记录**：免语法检查开销、不阻塞当前命令；代价是宕机丢未落盘命令、可能阻塞下一个命令。
- **重写期间的增量一致性**：主进程写命令**双写** AOF 缓冲区 + AOF 重写缓冲区；子进程完成后发信号，主进程把重写缓冲区追加进新文件再原子改名（信号处理函数短暂阻塞主进程）。
- **Redis 7.0 Multi-Part AOF**：manifest（清单）+ base（RDB 格式）+ incr（增量文件）——废除重写缓冲区与管道同步，主进程内存/CPU 压力更小、重写更健壮。
- AOF 文件是文本（`*3\r\n$3\r\nset...` RESP 格式），可读可审计。

### 大 Key 对持久化的三重打击（[[redis-bigkey]]）

1. Always 策略同步 fsync 大数据 → 主线程长阻塞；Everysec 下 `write()` 仍同步，且上次 fsync 未完时 write 被迫等。
2. fork 复制页表耗时 ∝ 内存 → 阻塞主线程。
3. 快照期间修改大 Key → COW 复制大物理页 → 阻塞。
4. **⚠️ 关闭内存大页（THP）**：2MB 页把 COW 放大 512 倍（改 100B 复制 2MB）。`echo never > /sys/kernel/mm/transparent_hugepage/enabled`。

### 与复制的联动

全量同步复用 bgsave：主节点生成 RDB 发给从节点，期间写命令进 replication buffer 后补发——见 [[redis-cluster]]。

## 与其他页面的关系

- 属于 [[redis]] 的子系统；核心机制 [[copy-on-write]]
- 与高可用强耦合：[[redis-cluster]]（异步复制 + 持久化的组合风险）
- 会话记忆是否落盘的取舍：[[java-ai-project-skeleton]]

## 疑点与待验证

- ~~fsync 三档语义~~、~~混合持久化细节~~、~~AOF rewrite 机制~~ —— **本次收录已补齐**（2026-09-18）
- RDB fork 尖刺在多大实例不可接受：经验线 10GB（fork >1s 需处理），具体随内核/页表规模浮动，待压测
- 7.0 MP-AOF 的 base/incr 文件管理（自动清理、 trunc 修复工具 `redis-check-aof`）实操待补
- 混合持久化 AOF 文件不可读带来的排障成本，生产案例待收集

## 来源

- [[redis-overview]] — 三方式对照、fork+COW 机制框架（机翻稿）
- [[redis-aof]] — 写回三策略、重写与重写缓冲区、MP-AOF
- [[redis-rdb]] — save/bgsave、自动快照配置、混合持久化
- [[redis-bigkey]] — 大 Key 三重阻塞、THP 陷阱
- [[redis-replication]] — bgsave 在全量同步中的复用
