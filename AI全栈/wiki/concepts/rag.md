---
title: RAG（检索增强生成）
type: concept
domain: ai
tags: [rag, llm, vector-db, embedding]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# RAG（Retrieval-Augmented Generation）

> 在生成前先去外部知识库检索相关片段，塞进上下文，让模型"看着答案回答"，从而解决私有数据、时效性和幻觉问题。

## 核心要点

- RAG 解决的是模型的**三个缺陷**：不知道你的私有数据、知识有截止日期、会一本正经地编。
- 相比微调，RAG 的优势是**知识可即时更新、可溯源引用、成本低**；劣势是不改变模型的"说话方式"。
- 公式：`RAG = 索引（离线） + 检索（在线） + 生成（在线）`。绝大多数效果问题出在前两步，不在模型。
- **检索质量决定上限，模型只决定下限。** 换更强的模型救不了烂召回。
- 典型链路：切分 → embedding → 存向量库 → 查询改写 → 混合检索 → 重排 → 拼上下文 → 生成 → 带引用输出。

## 细节

### 索引阶段（离线）

| 环节 | 关键决策 | 常见坑 |
|---|---|---|
| 解析 | PDF/表格/代码怎么抽成干净文本 | 解析丢表格，后面全白搭 |
| 切分 | 固定长度 / 语义 / 按结构；chunk size 与 overlap | 切太碎丢上下文，切太大噪声多 |
| 向量化 | embedding 模型选型、维度、是否要中文专用 | 用英文模型压中文，召回率崩 |
| 存储 | 向量 + 原文 + 元数据（来源、时间、权限） | 不存元数据就没法做过滤和引用 |

### 检索阶段（在线）

- **混合检索**（向量 + BM25 关键词）几乎总是优于纯向量：专有名词、型号、报错码这类词向量检索抓不住。
- **Rerank**：先用召回模型粗排 top-50，再用 cross-encoder 精排 top-5，是性价比最高的一个提升点。
- **查询改写**：用户问的是口语，文档写的是术语。用 LLM 把问题改写成 2-3 个检索 query 再查。
- 元数据过滤（时间范围、部门权限）要**前置**，别在生成阶段靠 prompt 拦。

### 生成阶段

- 明确要求**只依据给定上下文回答，找不到就说不知道**，并强制输出引用编号。
- 上下文顺序有讲究：相关信息放首尾（模型对中间部分注意力较弱）。
- 控制上下文长度，塞满不等于更好，噪声会拉低质量。

### Java 侧实现位置

- Spring AI：`VectorStore` 抽象 + `ETL Pipeline`（读取→转换→写入）+ `QuestionAnswerAdvisor` / `RetrievalAugmentationAdvisor`
- LangChain4j：`EmbeddingStore` + `EmbeddingStoreIngestor` + `ContentRetriever`，开箱 Easy RAG
- 详见 [[java-ai-framework-selection]]

## 与其他页面的关系

- 依赖 `concepts/vector-search.md`（待建，底层检索能力）、[[prompt-engineering]]（上下文拼装与约束）
- 常与 [[tool-calling]] 配合：检索是一种工具，Agent 可自主决定是否检索
- 替代关系：知识固化场景下与**微调**对立，见 `analyses/rag-vs-finetuning.md`（待建）
- 相关实体（待建）：pgvector、Milvus、bge-m3

## 疑点与待验证

- 中文场景下 embedding 模型（bge-m3 / gte / 通义 text-embedding）的实测排序，待用真实语料跑评测。
- chunk size 的"经验值"（512/1024）在你的业务文档上未必最优，需要网格搜索。
- GraphRAG / 知识图谱增强是否值得投入？目前 hype 大于产出，待观察。
- Rerank 模型（bge-reranker-v2-m3 等）的延迟成本在 Java 侧如何承接？

## 来源

- 无（种子页，待素材支撑）
