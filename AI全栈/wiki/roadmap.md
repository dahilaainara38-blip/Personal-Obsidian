---
title: Java + AI 全栈学习路线
type: analysis
domain: engineering
tags: [meta, architecture, selection]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Java + AI 全栈学习路线

> 六个阶段，从 Java 底座到 AI 生产化。每个阶段标注"该填哪些 wiki 页面"，学完一段就顺手把对应页面从 `seed` 推到 `stable`。

## 一句话判断

**你的差异化不在"会调大模型 API"——那层已经商品化了。你的价值在"用 Java 工程能力把 AI 变成可运维、可评测、可上线的系统"。** 所以阶段 1、4、6 不是陪跑，是主战场。

---

## 阶段 1 · Java 底座加固（2-4 周）

目标：JDK 17/21 现代特性 + Spring Boot 3 熟练到不用查文档。

- 虚拟线程（Project Loom）与结构化并发 —— 直接影响 AI 应用的高并发流式场景
- record / sealed / pattern matching —— 写 AI 的 DTO 与消息结构很顺手
- JVM：内存模型、GC 选型、排障工具（jfr / async-profiler）
- Spring Boot 3：自动配置原理、Actuator、Observation API（**这是后面接 AI 可观测的地基**）

该建/填的页面：`entities/spring-boot.md`、`concepts/virtual-threads.md`、`concepts/jvm-tuning.md`

## 阶段 2 · AI 基础原理（2-3 周）

目标：能看懂论文摘要，能判断一个 AI 方案靠不靠谱。

- Transformer / token / 上下文窗口 / 温度与采样参数
- Embedding 是什么、为什么余弦相似度有意义
- Prompt 工程与结构化输出
- 关键认知：**模型不记事、不算数、不会用你的私有数据** —— 这三条缺陷分别催生了 Memory、Tool Calling、RAG

该建/填的页面：[[rag]]、[[prompt-engineering]]、`concepts/embedding.md`、`concepts/llm-fundamentals.md`

## 阶段 3 · Java AI 工程（4-6 周，核心）

目标：能用 Spring AI 或 LangChain4j 从零搭出一个带 RAG 和工具调用的应用。

- 框架选型：见 [[java-ai-framework-selection]]
- RAG 全链路：切分 → embedding → 向量库 → 检索 → rerank → 生成 → 引用
- Tool Calling / Function Calling
- 记忆与多轮对话管理
- MCP：见 [[mcp]]
- Agent 编排：见 [[agent]]

该建/填的页面：[[spring-ai]]、[[langchain4j]]、[[spring-ai-alibaba]]、[[agentscope-java]]、[[rag]]、[[agent]]、[[mcp]]、[[tool-calling]]

## 阶段 4 · 数据层与基础设施（3-4 周）

目标：让 AI 应用能存、能快、能扩。

- PostgreSQL + pgvector（**中小规模首选，别一上来就上 Milvus**）
- Redis：缓存、会话、以及作为向量库的适用边界
- MQ（Kafka/RocketMQ）：AI 长任务的异步化是刚需
- Docker / K8s / CI-CD
- 可观测：Micrometer + OTel，**LLM 应用的 token 成本与延迟必须进监控**

该建/填的页面：[[redis]]（已建）、`entities/pgvector.md`、`entities/milvus.md`、`concepts/vector-search.md`、`practices/llm-observability.md`

> 阶段 4 已完成的部分：Redis 的定位、部署架构、持久化、分片已收录（素材：小林coding 综述）。**仍缺缓存三剑客与双写一致性** —— 这是实战高频但综述类文章不覆盖的内容，建议单独找素材。

## 阶段 5 · 前端与产品化（2-3 周）

目标：做出能给人用的对话界面。

- TypeScript + React（或 Vue）
- **流式输出**：SSE / WebSocket，别让用户干等 30 秒
- Markdown / 代码高亮 / 图表渲染
- 前端也要处理"AI 会失败"：中断、重试、引用展示

该建/填的页面：`concepts/sse-streaming.md`、`practices/chat-ui-patterns.md`

## 阶段 6 · 生产化（持续）

目标：从 demo 走到能交付。

- 评测体系：RAGAS 或自建评测集，**没有评测就没有优化**
- 成本工程：模型分级路由、缓存、prompt 压缩
- 安全：prompt 注入、数据脱敏、权限边界
- 灰度与回滚：AI 输出不稳定，必须有兜底

该建/填的页面：`concepts/llm-evaluation.md`、`concepts/prompt-injection.md`、`practices/rag-tuning-checklist.md`

---

## 建议的收录顺序

1. 本知识库方法论本身（Karpathy LLM Wiki）
2. 你选定框架的官方文档（Spring AI 或 LangChain4j，二选一起步）
3. RAG 的权威综述
4. 你自己的项目代码与踩坑记录（**这类素材价值最高，因为别处没有**）

## 疑点与待验证

- 六阶段的周数是拍的，需要根据你每天能投入的时间重估。
- 阶段顺序假设你是"Java 熟练、AI 新手"。如果反过来，阶段 1 与 2 应互换。
- 阶段 5 前端是否必要？取决于你是要做独立产品还是只做后端。待你确认。

## 来源

- 无（初始化时的结构化假设，待素材验证后修订）
