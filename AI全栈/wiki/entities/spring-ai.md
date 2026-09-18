---
title: Spring AI
type: entity
domain: ai
tags: [framework, llm, spring, java]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Spring AI

> Spring 官方的 AI 应用层框架，官方定位「AI 世界的 JDBC」—— 用写 Spring Boot 业务代码的姿势调大模型，换模型像换数据源一样简单。

## 核心要点

- **生态位：基础设施层。** 它不跟业务框架竞争，它是地基层。见 [[java-ai-framework-selection]]
- 核心抽象：`ChatClient`（统一入口，流式 + 阻塞）、`ChatModel`（可插拔模型实现）、`VectorStore`、`Advisor` 链
- 最大优势：**与 Spring 全家桶天然打通** —— Spring Boot 自动配置、Spring Security、Micrometer/Observation 可观测、Actuator。这是社区框架补不上的。
- 官方维护 **MCP Java SDK**，见 [[mcp]]
- 换模型只改配置和依赖，业务代码不动 —— 这是它最值钱的地方

## 细节

### 关键能力

| 能力 | 说明 |
|---|---|
| 多模型统一 | OpenAI、Anthropic、Azure、Ollama、DeepSeek、通义等，一套 `ChatClient` API |
| Advisor 链 | 类似 Servlet Filter，可插拔地做记忆、RAG、日志、防护栏 |
| 结构化输出 | 直接把模型返回映射成 Java POJO |
| Tool Calling | `@Tool` 注解，见 [[tool-calling]] |
| VectorStore 抽象 | 20+ 种向量库实现，统一接口，见 [[rag]] |
| ETL Pipeline | 文档读取 → 切分 → 向量化 → 写入 的官方管线 |
| 可观测 | 基于 Micrometer Observation，token 消耗与延迟自动埋点 |

### 版本与选型提示

> ⚠️ **版本号待核实。** 初始化检索时看到过互相矛盾的信息（有说 2.0.x 已 GA，也有说 1.1.x 是主线、2.0 仍是预览）。**动手前必须以 spring.io/projects/spring-ai 官方页面为准。**

- 官方曾同时维护主线版与 LTS 版两条稳定分支，选型时先确认哪条适合你
- 与 Spring Boot 3.x / 4.x 的对应关系必须查官方兼容矩阵，别凭印象
- JDK 基线：17+

### 什么时候选它

- 团队已经在 Spring 生态里，**只想加 AI 能力，不想换技术栈**
- 看重官方支持、长期维护、企业可审计
- 需要把 AI 调用纳入已有的 Spring 监控/安全体系

### 什么时候别选

- 需要成熟的多 Agent 编排 —— 它的 Agent 能力相对基础
- 需要非常激进地跟进最新模型特性 —— 社区框架通常更快

## 与其他页面的关系

- 对比：[[langchain4j]]、[[spring-ai-alibaba]]、[[agentscope-java]]
- 依赖概念：[[rag]]、[[tool-calling]]、[[mcp]]、[[agent]]
- 上层：Spring Boot 3（待建 `entities/spring-boot.md`）

## 疑点与待验证

- 当前 GA 版本究竟是哪个？必须查官方源确认（**当前页所有版本信息均不可信**）。
- Advisor 链与 LangChain4j 的拦截器相比，可扩展性差距有多大？
- Spring 官方与 DeepSeek 的战略合作落地到了哪些具体模块？（初始化检索时看到过此说法，未核实）
- 国内模型（通义、DeepSeek、智谱）的官方 starter 覆盖度与维护质量？

## 来源

- 无（种子页，待素材支撑）
