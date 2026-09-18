---
title: Agent（智能体）
type: concept
domain: ai
tags: [agent, llm, tool-calling, architecture]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# Agent（智能体）

> 让 LLM 在一个循环里自主决定"下一步做什么、调什么工具"，直到完成任务 —— 而不是一次性输入进、一次性输出。

## 核心要点

- 最小定义：**Agent = LLM + 工具 + 记忆 + 规划循环**。四者缺一，就退化成 chatbot 或 workflow。
- 与 workflow 的区别：workflow 的**路径由人写死**，Agent 的**路径由模型运行时决定**。可控性换来了灵活性，这是全部权衡的起点。
- 主流范式：**ReAct**（思考-行动-观察循环）、**Plan-and-Execute**（先规划再执行）、**Reflection**（做完自我检查再重试）。
- **真正的难点不在"让 Agent 跑起来"，而在"让它稳定停下来"。** 死循环、工具误调、成本失控是三大生产事故。
- 工程上必须有的四件事：步数上限、超时、幂等工具、全链路可观测。

## 细节

### 三种范式对比

| 范式 | 流程 | 适用 | 代价 |
|---|---|---|---|
| ReAct | 每步 Think → Act → Observe | 探索性、路径不确定 | 步数多、成本高、易打转 |
| Plan-and-Execute | 先出完整计划，再逐步执行 | 步骤可预估、需人工审阅计划 | 计划错了整条链崩 |
| Reflection | 执行 → 自评 → 修正重来 | 有明确评判标准的任务 | 额外一轮 token |

### 生产化的硬要求

1. **终止条件**：最大步数 + 最大 token + 最大耗时，三重保险，任一触发就退出并要求模型总结。
2. **工具幂等**：写操作（下单、发消息）必须带幂等键，模型重试不能造成副作用。
3. **沙箱**：让模型生成的代码只能在容器里跑，禁止直连生产库。
4. **HITL（人类在环）**：高风险动作（付款、删数据、外发）必须暂停等人工确认。
5. **状态持久化 + 会话恢复**：长任务跑了 20 步崩了，不能从头再来。
6. **可观测**：每一步的输入输出、token、耗时、工具调用都要能回放复盘。

### 多 Agent

- 适用场景：任务天然可分解（调研 + 写作 + 评审）、上下文装不下、需要并行提速。
- 反模式：为了"看起来高级"而拆多 Agent —— 调试难度是指数级上升的，**能用单 Agent + 好工具解决的，别拆**。
- 通信协议：[[mcp]] 管"Agent 怎么用工具"，A2A 管"Agent 之间怎么说话"。

### Java 侧实现位置

- Spring AI：`ChatClient` + Advisor 链 + `ToolCallback`，Agent 编排能力偏基础（2.x 在补）
- LangChain4j：`AiServices` 声明式定义，`@Tool` 注解暴露工具，Agent 能力成熟
- AgentScope Java：为生产级多 Agent 设计，原生支持分布式、多层记忆压缩、HITL、会话恢复
- 详见 [[java-ai-framework-selection]]

## 与其他页面的关系

- 强依赖 [[tool-calling]]（Agent 的手）、[[prompt-engineering]]（系统提示词就是 Agent 的"岗位说明书"）
- [[rag]] 在 Agent 语境下退化为一个可选工具
- [[mcp]] 是工具供给的标准化协议
- 实体：[[agentscope-java]]、[[langchain4j]]、[[spring-ai]]

## 疑点与待验证

- 多 Agent 在真实业务中的收益是否覆盖其调试成本？目前缺自己项目的数据。
- Java 生态里哪个框架的 Agent 可观测做得最完整？待对比测试。
- Agent 的错误恢复策略（重试 vs 回退 vs 转人工）有没有行业通用模式？待查。

## 来源

- 无（种子页，待素材支撑）
