---
title: Spring AI Alibaba
type: entity
domain: ai
tags: [framework, llm, spring, agent, 国内]
status: seed
confidence: low
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Spring AI Alibaba

> 阿里基于 Spring AI 构建的 Agent 全家桶，把通义千问、百炼平台与阿里云生态能力接进 Spring 体系。

## 核心要点

- **它是 [[spring-ai]] 的上层扩展，不是替代品。** 选它意味着你也选了 Spring AI。
- 核心价值：**国内落地的最短路径** —— 通义千问原生支持、阿里云服务打通、中文文档、国内合规与网络环境友好。
- 定位偏"Agent 全家桶"：不止是调模型，还包括工作流编排、多 Agent 协作、企业级集成。
- ⚠️ **当前页可信度标注为 low**：初始化时仅有二手检索信息，无官方文档核实。

## 细节

### 与 Spring AI 的关系

```
Spring AI（基础设施层：ChatClient / VectorStore / MCP）
        ↑ 依赖
Spring AI Alibaba（应用层：通义集成 / Agent 编排 / 百炼 / 工作流）
```

**注意**：这个依赖关系意味着版本必须对齐 —— Spring AI Alibaba 会锁定某个 Spring AI 版本，升级时要连带考虑。

### 关键信息（均待核实）

| 项 | 状态 |
|---|---|
| 当前版本 | 待核实（初始化检索看到 1.1.x 系列的说法） |
| 官方文档站 | 有说法称旧站 sca.aliyun.com 已过期，新站为 java2ai.com —— **待核实** |
| 适配 JDK | 17+（待核实） |
| 适配 Spring Boot | 3.x（待核实） |

### 什么时候选它

- 项目已经在阿里云上，或必须用国内大模型
- 需要中文文档与国内技术支持
- 想要现成的 Agent 工作流编排，而不是自己搭

### 什么时候别选

- 不锁定阿里云，需要多云/私有化 —— 直接用 [[spring-ai]] 更干净
- 追求最新版本节奏 —— 它会滞后于上游 Spring AI

## 与其他页面的关系

- 上层基于 [[spring-ai]]，与 [[langchain4j]] 是不同路线
- 与 [[agentscope-java]] 同为阿里系，但定位不同（本页偏 Spring 集成，AgentScope 偏独立多 Agent 框架）
- 依赖概念：[[agent]]、[[tool-calling]]

## 疑点与待验证

- **全部信息待核实。** 官方文档站到底是哪个？
- Spring AI Alibaba 与 AgentScope Java 在阿里内部是什么关系？会不会合并或其中一个被边缘化？
- 百炼平台的绑定深度：脱离百炼还能用多少能力？
- 开源协议与商业使用限制？

## 来源

- 无（种子页，且仅有未核实的二手信息，请勿据此选型）
