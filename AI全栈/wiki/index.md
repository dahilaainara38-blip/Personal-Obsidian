---
title: 索引
type: index
domain: engineering
tags: [meta]
status: growing
confidence: high
source_count: 0
created: 2026-09-16
updated: 2026-09-18
---

# 索引

> 全量页面目录。**每次 ingest / 新建页面后必须更新本文件。**
> 只做目录（链接 + 一句话）；状态与源数看各页 frontmatter，统计跑 `bash tools/stats.sh`。

## 导航

| 页面 | 一句话 |
|---|---|
| [[overview]] | 知识库总览、当前状态、怎么用 |
| [[conventions]] | 你的操作偏好，Agent 每次必读 |
| [[roadmap]] | Java+AI 全栈六阶段学习路线 |
| [[log]] | 操作日志（时间序） |

## 概念（concepts/）— 抽象原理与模式

| 页面 | 一句话 |
|---|---|
| [[rag\|RAG]] | 先检索再生成，解决私有数据、时效与幻觉 |
| [[agent\|Agent]] | LLM + 工具 + 记忆 + 规划循环，自主决定下一步 |
| [[tool-calling\|Tool Calling]] | 模型出调用意图、你的代码执行，是 Agent 的地基 |
| [[mcp\|MCP]] | 模型上下文协议，AI 应用的 USB-C 接口 |
| [[prompt-engineering\|Prompt 工程]] | 把模糊意图翻译成模型能稳定执行的规格 |
| [[redis-persistence\|Redis 持久化]] | 无/RDB/AOF/混合；fork 子进程 + COW 不阻塞主线程 |
| [[redis-cluster\|Redis 高可用与集群]] | 主从→哨兵→Cluster 阶梯；复制是异步的这条事实贯穿全部风险 |
| [[data-sharding\|数据分片]] | 哈希槽用一层间接解决取模分片的映射漂移 |
| [[copy-on-write\|写时复制]] | 读时共享、写时才复制；横跨 OS fork 与 Java 并发容器 |
| [[cache-pitfalls\|缓存雪崩、击穿、穿透]] | 三种"请求绕过缓存打到数据库"的故障模式与解法 |
| [[cache-coherence\|数据库与缓存一致性]] | 先更 DB 再删缓存 + TTL 兜底；失败靠 MQ/Canal 补偿 |
| [[redis-expiration-eviction\|过期删除与内存淘汰]] | 惰性+定期删到期的；8 种策略删超内存的 |
| [[distributed-lock\|分布式锁]] | SET NX EX + Lua 释放 + 看门狗 + Redlock 及其争议 |
| [[redis-internals\|Redis 底层数据结构]] | SDS→listpack 演进史、跳表、渐进式 rehash |

## 实体（entities/）— 具体框架与工具

| 页面 | 一句话 |
|---|---|
| [[spring-ai\|Spring AI]] | Spring 官方 AI 框架，「AI 世界的 JDBC」，基础设施层 |
| [[langchain4j\|LangChain4j]] | 社区驱动的全功能 LLM 工具箱，应用框架层 |
| [[spring-ai-alibaba\|Spring AI Alibaba]] | 阿里系 Agent 全家桶，国内落地路径 |
| [[agentscope-java\|AgentScope Java]] | 阿里开源生产级多 Agent 框架 |
| [[redis\|Redis]] | 内存数据结构服务器：9 种类型选型、大 Key 治理、线程模型 |

## 分析（analyses/）— 对比与综合结论

| 页面 | 一句话 |
|---|---|
| [[java-ai-framework-selection\|Java AI 框架选型]] | 不是五选一，是「基座 + 按需叠加」，附决策树 |

## 实践（practices/）— 能抄走用的

| 页面 | 一句话 |
|---|---|
| [[java-ai-project-skeleton\|Java AI 项目标准骨架]] | 四层包结构 + prompt 外置 + 上线检查清单 |

## 素材摘要（sources/）

| 页面 | 素材 | 收录日期 |
|---|---|---|
| [[llm-wiki\|LLM Wiki（Karpathy）]] | 本知识库的方法论原文 | 2026-09-16 |
| [[redis-overview\|Redis 综述（小林coding）]] | 定位/架构/持久化框架（⚠️ 机翻稿） | 2026-09-18 |
| [[redis-aof\|AOF 持久化]] | 三种写回策略 = fsync 时机；bgrewriteaof；7.0 MP-AOF | 2026-09-18 |
| [[redis-rdb\|RDB 快照]] | save/bgsave；混合持久化（4.0） | 2026-09-18 |
| [[redis-bigkey\|大 Key 对持久化的影响]] | fsync/fork/COW 三重阻塞；THP 放大 512 倍 | 2026-09-18 |
| [[redis-expire-vs-evict\|过期删除 vs 内存淘汰]] | 惰性+定期；8 策略；近似 LRU 与 LFU | 2026-09-18 |
| [[redis-distributed-lock\|分布式锁实现]] | SET NX EX + Lua 释放 + Redlock | 2026-09-18 |
| [[redis-distributed-lock-ha\|分布式锁高可用高性能]] | 等待/重试/续约/中断；Kleppmann 争议；Singleflight | 2026-09-18 |
| [[redis-cache-avalanche\|缓存雪崩、击穿、穿透]] | 三模式解法；布隆过滤器 | 2026-09-18 |
| [[redis-db-cache-consistency\|数据库与缓存一致性]] | Cache Aside；Canal binlog 补偿；延迟双删 | 2026-09-18 |
| [[redis-sentinel\|哨兵机制]] | 两轮投票；选主三轮考察；quorum=N/2+1 | 2026-09-18 |
| [[redis-replication\|主从复制]] | 全量/命令传播/增量；repl_backlog；min-slaves 防脑裂 | 2026-09-18 |
| [[redis-cluster-why\|为什么要有 Redis Cluster]] | Smart Client；MOVED/ASK；Gossip；为什么 16384 | 2026-09-18 |
| [[redis-data-types\|数据类型与应用场景]] | 5+4 类型选型表；Stream 当 MQ 的边界 | 2026-09-18 |
| [[redis-data-structures\|底层数据结构]] | 9 种结构；连锁更新→listpack 演进 | 2026-09-18 |
| [[redis-interview-qa\|Redis 常见面试题（⚠️ 机翻）]] | 仅当索引；增量：线程模型、过期键×持久化、三策略 | 2026-09-18 |

## 待建页面（被引用但尚未创建）

按优先级排序，收录相关素材时优先补这些：

**AI 侧（当前最大空白，优先喂）**
- [ ] `concepts/vector-search.md` — 向量检索原理（HNSW / IVF / 混合检索）—— 被 [[rag]] 依赖
- [ ] `concepts/embedding.md` — 嵌入模型与中文选型 —— 被 [[rag]] 依赖
- [ ] `entities/pgvector.md` — 中小规模首选向量方案
- [ ] `entities/milvus.md` — 大规模向量库
- [ ] `entities/spring-boot.md` — 底座
- [ ] `analyses/rag-vs-finetuning.md` — 知识固化的两条路线
- [ ] `concepts/llm-evaluation.md` — 没有评测就没有优化
- [ ] `concepts/prompt-injection.md` — AI 应用安全底线
- [ ] `concepts/sse-streaming.md` — 流式输出，前端体验刚需
- [ ] `concepts/virtual-threads.md` — 影响 AI 高并发流式场景
- [ ] `practices/llm-observability.md`
- [ ] `practices/rag-tuning-checklist.md`

**data 侧（Redis 系列后暴露的新空白）**
- [ ] `concepts/bloom-filter.md` — 布隆过滤器原理与误判率设计 —— [[cache-pitfalls]] 依赖
- [ ] `concepts/consistent-hashing.md` — 与 [[data-sharding]] 哈希槽路线对照；也是 [[distributed-lock]] 的替代方案
- [ ] `entities/canal.md` — binlog 订阅组件，[[cache-coherence]] 的关键拼图
- [ ] `analyses/redis-java-clients.md` — Jedis/Lettuce/Redisson 对比（Cluster 拓扑刷新、看门狗）—— [[redis]] 疑点
- [ ] `concepts/cache-pitfalls.md` ✅ 已建 · ~~`concepts/cache-coherence.md`~~ ✅ 已建（2026-09-18）
