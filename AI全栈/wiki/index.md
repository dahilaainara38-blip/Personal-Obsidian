---
title: 索引
type: index
domain: engineering
tags: [meta]
status: growing
confidence: high
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# 索引

> 全量页面目录。**每次 ingest / 新建页面后必须更新本文件。**
> 图例：`seed` 种子未验证 · `growing` 有源未稳 · `stable` 多源可引用 · `stale` 待更新 · `contested` 有矛盾

## 导航

| 页面 | 一句话 |
|---|---|
| [[overview]] | 知识库总览、当前状态、怎么用 |
| [[conventions]] | 你的操作偏好，Agent 每次必读 |
| [[roadmap]] | Java+AI 全栈六阶段学习路线 |
| [[log]] | 操作日志（时间序） |

## 概念（concepts/）— 抽象原理与模式

| 页面 | 一句话 | domain | status | 源数 |
|---|---|---|---|---|
| [[rag\|RAG]] | 先检索再生成，解决私有数据、时效与幻觉 | ai | seed | 0 |
| [[agent\|Agent]] | LLM + 工具 + 记忆 + 规划循环，自主决定下一步 | ai | seed | 0 |
| [[tool-calling\|Tool Calling]] | 模型出调用意图、你的代码执行，是 Agent 的地基 | ai | seed | 0 |
| [[mcp\|MCP]] | 模型上下文协议，AI 应用的 USB-C 接口 | ai | seed | 0 |
| [[prompt-engineering\|Prompt 工程]] | 把模糊意图翻译成模型能稳定执行的规格 | ai | seed | 0 |
| [[redis-persistence\|Redis 持久化]] | 无/RDB/AOF/混合，靠 fork + COW 不阻塞主线程 | data | growing | 1 |
| [[redis-cluster\|Redis 高可用与集群]] | 单实例→主从→Sentinel→Cluster 四档阶梯 | data | growing | 1 |
| [[data-sharding\|数据分片]] | 哈希槽用一层间接解决取模分片的映射漂移 | data | growing | 1 |
| [[copy-on-write\|写时复制]] | 读时共享、写时才复制；横跨 OS fork 与 Java 并发容器 | engineering | growing | 1 |

## 实体（entities/）— 具体框架与工具

| 页面 | 一句话 | domain | status | 源数 |
|---|---|---|---|---|
| [[spring-ai\|Spring AI]] | Spring 官方 AI 框架，「AI 世界的 JDBC」，基础设施层 | ai | seed | 0 |
| [[langchain4j\|LangChain4j]] | 社区驱动的全功能 LLM 工具箱，应用框架层 | ai | seed | 0 |
| [[spring-ai-alibaba\|Spring AI Alibaba]] | 阿里系 Agent 全家桶，国内落地路径 | ai | seed | 0 |
| [[agentscope-java\|AgentScope Java]] | 阿里开源生产级多 Agent 框架 | ai | seed | 0 |
| [[redis\|Redis]] | 内存数据结构服务器，架在数据库前做加速层 | data | growing | 1 |

## 分析（analyses/）— 对比与综合结论

| 页面 | 一句话 | domain | status | 源数 |
|---|---|---|---|---|
| [[java-ai-framework-selection\|Java AI 框架选型]] | 不是五选一，是「基座 + 按需叠加」，附决策树 | ai | seed | 0 |
| [[roadmap]] | Java+AI 全栈六阶段学习路线 | engineering | seed | 0 |

## 实践（practices/）— 能抄走用的

| 页面 | 一句话 | domain | status | 源数 |
|---|---|---|---|---|
| [[java-ai-project-skeleton\|Java AI 项目标准骨架]] | 四层包结构 + prompt 外置 + 上线检查清单 | java | seed | 0 |

## 素材摘要（sources/）

| 页面 | 素材 | 收录日期 |
|---|---|---|
| [[llm-wiki\|LLM Wiki（Karpathy）]] | 本知识库的方法论原文 | 2026-09-16 |
| [[redis-overview\|Redis 综述（小林coding）]] | Redis 定位/架构/持久化宏观框架（机翻稿） | 2026-09-18 |

## 待建页面（被引用但尚未创建）

按优先级排序，收录相关素材时优先补这些：

- [ ] `concepts/vector-search.md` — 向量检索原理（HNSW / IVF / 混合检索）—— 被 [[rag]] 依赖
- [ ] `concepts/embedding.md` — 嵌入模型与中文选型 —— 被 [[rag]] 依赖
- [ ] `concepts/cache-pitfalls.md` — 缓存穿透/击穿/雪崩 —— **Redis 收录后暴露的最大空白**
- [ ] `concepts/cache-coherence.md` — Redis 与 MySQL 双写一致性
- [ ] `entities/pgvector.md` — 中小规模首选向量方案
- [ ] `entities/milvus.md` — 大规模向量库
- [ ] `entities/spring-boot.md` — 底座
- [ ] `concepts/consistent-hashing.md` — 与 [[data-sharding]] 的哈希槽路线对照
- [ ] `analyses/rag-vs-finetuning.md` — 知识固化的两条路线
- [ ] `concepts/llm-evaluation.md` — 没有评测就没有优化
- [ ] `concepts/prompt-injection.md` — AI 应用安全底线
- [ ] `concepts/sse-streaming.md` — 流式输出，前端体验刚需
- [ ] `concepts/virtual-threads.md` — 影响 AI 高并发流式场景
- [ ] `practices/llm-observability.md`
- [ ] `practices/rag-tuning-checklist.md`

## 统计

- 页面总数：23（含本页）
- 素材数：2
- `status: seed` 页面：15 —— **AI 侧全部未验证，不要直接用于选型**
- `status: growing` 页面：6 —— Redis 相关，已有素材支撑但结论未稳
- `source_count > 0` 页面：7
- 领域分布：ai 9 · data 5 · engineering 5 · 元页面 4
