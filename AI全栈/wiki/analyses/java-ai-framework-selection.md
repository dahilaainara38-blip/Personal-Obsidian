---
title: Java AI 框架选型
type: analysis
domain: ai
tags: [selection, framework, llm, java, architecture]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Java AI 框架选型

> 结论先行：**这不是"五选一"，而是"一个基座 + 按需叠加"。** 大多数项目该用的是 Spring AI 打底，再按需求叠 LangChain4j 或 AgentScope。

## 核心结论

### 1. 先竖着切：它们不在同一层

```
┌─ 应用编排层 ────────────────────────────┐
│  AgentScope Java    多 Agent / 生产运行时  │
│  Spring AI Alibaba  Agent 全家桶 / 通义     │
├─ 应用框架层 ────────────────────────────┤
│  LangChain4j        工具箱 / RAG / AiServices│
├─ 基础设施层 ────────────────────────────┤
│  Spring AI          ChatClient / VectorStore │
│                     / MCP / 可观测          │
└─────────────────────────────────────────┘
```

**把不同层的框架拿来对比，是选型最大的认知错误。** 说"Spring AI 和 LangChain4j 哪个强"就像问"JDBC 和 MyBatis 哪个好"。

### 2. 决策树

```
你要做什么？
│
├─ 只是接个模型、做个 RAG、加工具调用
│   └─ 团队在 Spring 生态？ → 是：[[spring-ai]]
│                          └─ 否：[[langchain4j]]
│
├─ 要成熟的 RAG 组件、快速出原型
│   └─ [[langchain4j]]（Easy RAG / AiServices 最省事）
│
├─ 要上生产的多 Agent（会话恢复/HITL/多租户）
│   └─ [[agentscope-java]]（叠加在基座之上）
│
├─ 用阿里云 + 通义，要中文文档和现成编排
│   └─ [[spring-ai-alibaba]]（注意它锁 Spring AI 版本）
│
└─ 不确定
    └─ 先用 Spring AI 起步，它是地基，后面加什么都不冲突
```

### 3. 推荐的四种组合拳

| 场景 | 组合 | 理由 |
|---|---|---|
| 企业内部系统加 AI 能力 | Spring AI 单用 | 与现有监控/安全体系打通，维护成本最低 |
| 快速做 RAG 产品原型 | Spring AI + LangChain4j | 基座要官方保障，RAG 组件用社区最全的 |
| 生产级多 Agent 平台 | Spring AI + AgentScope Java | 基座 + 生产运行时 |
| 阿里云上的国内业务 | Spring AI Alibaba | 一条龙，但被云锁定 |

### 4. 选型时的隐藏成本（比功能对比更重要）

- **版本绑定**：上层框架锁定下层版本，升级是连锁反应。[[spring-ai-alibaba]] 尤其明显。
- **API 稳定性**：社区框架（[[langchain4j]]）迭代快但 breaking change 多，老教程会坑人。
- **文档质量**：直接影响团队上手速度。官方系（Spring AI）文档最好，社区系参差。
- **团队技能栈复用**：已经在 Spring 上投入多年的团队，换框架的机会成本远高于框架本身的差异。
- **退出成本**：统一抽象层（Spring AI 的"AI 界 JDBC"定位）的核心价值就是降低这个成本。

## 与其他页面的关系

- 涉及实体：[[spring-ai]]、[[langchain4j]]、[[spring-ai-alibaba]]、[[agentscope-java]]
- 依赖概念：[[rag]]、[[agent]]、[[tool-calling]]、[[mcp]]
- 落地参考：[[java-ai-project-skeleton]]

## 疑点与待验证

- **本页所有版本号均未核实。** 初始化检索到的信息互相矛盾（Spring AI 到底是 1.1.x 还是 2.0.x GA，LangChain4j 是 1.13 还是 1.19），**必须先查官方源再动手**。
- 分层模型是二手资料 + 推理得出的，需要用官方文档交叉验证。
- "Spring 官方与 DeepSeek 达成战略合作"的说法未核实，若属实会改变国内选型格局。
- 缺少真实项目的性能与运维对比数据，只有功能层面的比较。

## 来源

- 无（种子页，结论为架构推理 + 未核实的二手信息）
