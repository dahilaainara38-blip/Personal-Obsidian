---
title: LangChain4j
type: entity
domain: ai
tags: [framework, llm, java, rag, agent]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# LangChain4j

> 框架无关的 Java LLM 应用工具箱，社区驱动，是 Python LangChain 在 Java 侧的对应物（但并非官方移植）。

## 核心要点

- **生态位：应用框架层。** 站在 [[spring-ai]] 这样的基础设施之上，提供开箱即用的应用级组件。
- 最大特色：**`AiServices` 声明式编程** —— 你定义 Java 接口，它帮你实现。写 AI 代码像写 MyBatis Mapper。
- 强项：RAG 组件最齐全（含 Easy RAG 零配置上手）、工具调用原生、模型支持广、社区迭代快
- 弱项：官方文档质量一般（这是社区普遍吐槽点），版本间 API 变动较多
- 不仅限 Spring：也能跑在 Quarkus、Micronaut，或纯 Java main 方法

## 细节

### 声明式写法（它的灵魂）

```java
interface Assistant {
    @SystemMessage("你是资深 Java 架构师，回答简洁")
    String chat(@UserMessage String question);
}

Assistant assistant = AiServices.builder(Assistant.class)
    .chatLanguageModel(model)
    .chatMemory(MessageWindowChatMemory.withMaxMessages(20))
    .tools(new OrderTools())
    .build();
```

好处：AI 调用变成普通 Java 方法调用，可 mock、可单测、可被 Spring 注入。

### 关键能力

| 能力 | 说明 |
|---|---|
| AiServices | 声明式接口 + 自动代理，支持返回 POJO |
| RAG | `EmbeddingStoreIngestor`、`ContentRetriever`、多种检索器、Easy RAG |
| Tools | `@Tool` 注解，见 [[tool-calling]] |
| 记忆 | 消息窗口、令牌窗口、持久化实现 |
| 模型 | 15+ 家主流模型与本地模型（Ollama 等） |
| 流式 | `TokenStream` + 响应式接口 |

### 版本与选型提示

> ⚠️ **版本号待核实。** 初始化检索时看到过 1.13.x 与 1.19.x 两种说法且时间线冲突，**动手前必须以 docs.langchain4j.dev 官方为准。**

- JDK 17+ 基线，支持 Spring Boot 3.x
- **版本间 API 变动较大**，升级前必看 changelog，别照抄老教程

### 什么时候选它

- 想快速做出能跑的 RAG / Agent 原型
- 不一定在 Spring 生态，或想要框架中立
- 想要社区最活跃的 Java AI 组件库

### 什么时候别选

- 强依赖官方 SLA 与长期支持的企业场景
- 团队对文档质量敏感、需要大量权威示例

## 与其他页面的关系

- 对比：[[spring-ai]]、[[agentscope-java]]、[[spring-ai-alibaba]]
- 依赖概念：[[rag]]、[[tool-calling]]、[[agent]]
- 常与 [[spring-ai]] 组合使用（基座 + 应用框架）

## 疑点与待验证

- 当前稳定版本究竟是多少？官方文档站是否已迁移（有说法称旧站点过期）？
- 与 Spring AI 混用时的依赖冲突与重复抽象问题，实际体验如何？
- 社区吐槽的"文档一般"在当前版本是否改善？需实际走一遍 quickstart 验证。

## 来源

- 无（种子页，待素材支撑）
