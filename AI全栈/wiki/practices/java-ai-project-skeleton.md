---
title: Java AI 项目标准骨架
type: practice
domain: java
tags: [spring, best-practice, architecture, llm]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Java AI 项目标准骨架

> 一套可直接复用的 Spring Boot + AI 应用分层结构。**版本号均为占位，动手前必须替换为官方当前版本。**

## 核心要点

- AI 应用不是"把大模型塞进 Controller"，它有自己的四层结构：**接入层 → 编排层 → 能力层 → 模型层**
- 最容易错的架构决策：**把 prompt 硬编码在 Java 字符串里** —— 改一次要重新发版，无法做 A/B
- 三个必须一开始就建好的东西：prompt 外置、token 成本埋点、失败兜底
- 见 [[java-ai-framework-selection]] 先定框架再套这套骨架

## 细节

### 推荐包结构

```
com.example.aiapp
├── web/                    # 接入层
│   ├── ChatController          # HTTP / SSE 流式接口
│   └── dto/                    # 请求响应 DTO
├── orchestration/          # 编排层（业务语义）
│   ├── AssistantService        # 组装 prompt + 工具 + 记忆 + 检索
│   └── guard/                  # 输入输出防护（敏感词、注入检测、长度截断）
├── capability/             # 能力层（可被模型调用的原子能力）
│   ├── OrderTools              # @Tool 标注的业务工具
│   ├── KnowledgeRetriever      # RAG 检索封装
│   └── MemoryStore             # 会话记忆持久化
├── model/                  # 模型层（配置与适配）
│   ├── ModelConfig             # ChatModel / EmbeddingModel Bean
│   └── ModelRouter             # 按场景路由到不同模型（成本优化）
└── observability/          # 可观测
    ├── TokenCostRecorder       # token 与成本统计
    └── AiExceptionHandler      # 统一降级与兜底
```

### Prompt 外置

```
src/main/resources/prompts/
├── system-assistant.st      # 系统提示词
├── rag-qa.st                # RAG 回答模板
└── intent-classify.st       # 意图分类模板
```

用 `PromptTemplate` 加载渲染，**改 prompt 不需要动 Java 代码**。上线后考虑配置中心热更新。

### 最小配置示例（结构示意，版本自适应）

```java
@Configuration
public class ModelConfig {

    @Bean
    public ChatModel chatModel(/* 各家 starter 的参数 */) {
        // 由 Spring AI / LangChain4j 的 starter 提供
        // 关键：超时、重试、最大 token 必须显式配置，别用默认值
        return chatModel;
    }

    @Bean
    public ChatMemory chatMemory() {
        return MessageWindowChatMemory.builder()
                .maxMessages(20)          // 窗口大小 = 成本与效果的权衡点
                .build();
    }
}
```

### 必须显式配置的四个参数

| 参数 | 为什么不能默认 |
|---|---|
| 超时 | AI 调用可能几十秒，默认值要么太短超时要么太长拖垮线程池 |
| 重试 | 默认无限重试会在故障时把成本打爆 |
| 最大 token / 最大步数 | 防 Agent 死循环的第一道闸 |
| 并发限流 | 模型侧有 RPM/TPM 限额，不限流会被限流报错 |

### 上线检查清单

- [ ] 流式接口用 SSE，且支持客户端中断（别让后端白烧 token）
- [ ] token 消耗按用户/会话维度埋点，接 Micrometer
- [ ] 模型超时/限流有降级回答，不是直接 500
- [ ] 所有工具调用有审计日志与幂等键
- [ ] 高风险工具（写操作）走人工确认
- [ ] prompt 注入防护：用户输入用分隔符隔离 + 输出过滤
- [ ] 敏感数据脱敏后再进模型

## 与其他页面的关系

- 依赖选型：[[java-ai-framework-selection]]
- 依赖概念：[[agent]]、[[tool-calling]]、[[rag]]、[[prompt-engineering]]
- 可观测部分：`practices/llm-observability.md`（待建）

## 疑点与待验证

- 骨架中的分层是否过重？小项目可能 `orchestration` 与 `capability` 合并更合适。
- 流式 + 工具调用 + 记忆三者同时使用时，各框架的兼容性问题需要实测。
- 记忆持久化到 Redis vs PostgreSQL 的取舍，取决于是否需要跨会话记忆。

## 来源

- 无（种子页，基于通用工程实践整理，未针对具体框架版本验证）
