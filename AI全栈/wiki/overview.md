---
title: 知识库总览
type: overview
domain: engineering
tags: [meta]
status: seed
confidence: high
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Java + AI 全栈知识库 · 总览

> 一个由 LLM 维护、持续复利的个人知识库，主题是 **Java 后端 + AI 工程 + 全栈落地**。

## 这个知识库是什么

不是收藏夹，不是 RAG 检索库。它是一层**已经消化过的中间认知**：

- 你往 `raw/` 丢素材（文章、文档、截图、代码），**永不修改**
- Agent 读素材、抽结论、更新 `wiki/` 里的实体页/概念页/分析页
- 你的提问产出的好答案，也会落盘成新页面

所以每加一份素材、每问一个问题，整个知识库都变厚一点。**知识是被编译一次、然后持续维护的，不是每次提问重新推导的。**

## 当前状态

- 初始化日期：2026-09-16
- 页面数：23（含本页）
- 素材数：2（[[llm-wiki|方法论原文]]、[[redis-overview|Redis 综述]]）
- 覆盖 domains：ai / java / data / infra / frontend / engineering

**认知分布是不均衡的：** Redis 相关 6 页已有素材支撑（`growing`），但 AI 侧 15 页仍是 `seed`、`source_count: 0` —— 只有坐标系，没有证据。**做选型和动手前，先补 AI 侧的素材。**

## 怎么开始用

1. 往 `raw/` 丢 1 份素材（推荐第一篇：[[sources/llm-wiki|Karpathy 的 LLM Wiki]]，就是这个知识库的方法论本身）
2. 对 Agent 说「收录」
3. 读完摘要后，用「提问」去压它
4. 攒够 10 份素材后说「体检」

详细工作流见 `AGENTS.md`，你的操作偏好见 [[conventions]]，学习路线见 [[roadmap]]。

## 知识地图（三层）

```
raw/                 素材层 —— 你写，Agent 只读
  ↓ ingest
wiki/                认知层 —— Agent 写，你读
  sources/           单份素材的摘要
  entities/          具体技术：Spring AI、LangChain4j、pgvector…
  concepts/          抽象原理：RAG、Agent、向量检索…
  analyses/          综合结论：选型、对比
  practices/         能抄走用的：骨架、清单、踩坑
  ↓ 沉淀
AGENTS.md            规范层 —— 共同演进
```

## 与其他页面的关系

- [[conventions]] — 收录与写作的操作偏好
- [[roadmap]] — 六阶段学习路线，标注了每阶段该填哪些页面
- [[index]] — 全量页面目录

## 疑点与待验证

- 这套分类法（entities/concepts/analyses/practices）在真实收录 20 份素材后是否还够用？可能要新增 `projects/`（实战项目记录）。
- `domain` 六个取值是否覆盖得住？前端目前几乎空白，可能是伪需求，也可能确实是短板。
- 规模到 100+ 页面时 `index.md` 是否还够用，届时需要引入 qmd 之类的本地搜索。

## 来源

- 无（本页为人工设定的初始骨架）
