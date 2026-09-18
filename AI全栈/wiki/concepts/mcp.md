---
title: MCP（模型上下文协议）
type: concept
domain: ai
tags: [mcp, llm, tool-calling, protocol]
status: seed
confidence: medium
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# MCP（Model Context Protocol）

> 由 Anthropic 提出、现已成为事实标准的开放协议，用于标准化「LLM 应用」与「外部数据源/工具」之间的连接。类比：AI 应用的 USB-C 接口。

## 核心要点

- 解决的是 **M×N 集成问题**：M 个应用 × N 个数据源，没有标准就是 M×N 套集成，有了 MCP 变成 M+N。
- 三个角色：**Host**（宿主应用，如 IDE / 你的 Java 服务）、**Client**（协议客户端）、**Server**（暴露能力的提供方）。
- 服务器能暴露三类能力：
  - **Tools** — 可被模型调用的函数（主要用法）
  - **Resources** — 可被读取的数据（文件、数据库记录）
  - **Prompts** — 预置的提示词模板
- 传输层：本地用 **stdio**，远程用 **Streamable HTTP**（早期是 HTTP+SSE，已演进）。
- **MCP ≠ Function Calling。** Function Calling 是模型侧能力（模型说"我要调 X"），MCP 是传输与供给侧的协议（去哪找到 X、怎么调、权限怎么管）。两者是上下游关系。

## 细节

### 为什么对 Java 开发特别重要

- **你现有的 Spring Boot 服务可以直接变成 MCP Server** —— 业务能力不用重写，加一层协议适配就能被任意 AI 客户端调用。这是 Java 存量资产接 AI 最短的路径。
- Spring 团队维护官方 **MCP Java SDK**（`spring-ai-mcp`），提供 server / client 两端 starter。
- 生态位置：基础设施层，见 [[java-ai-framework-selection]]

### 典型架构

```
你的 Spring Boot 服务
   └── @Tool / @McpTool 暴露的业务方法
          └── MCP Server（stdio 或 HTTP）
                 └── 被 Claude Desktop / IDE / 自家 Agent 调用
```

### 风险与注意点

- **安全**：MCP Server 拿到的是真实权限。第三方 server 必须审代码，生产环境要沙箱 + 最小权限。
- **工具数量**：一次性挂几十个工具会显著拉低模型选对工具的概率，建议按场景分组动态挂载。
- **版本演进快**：协议仍在迭代（transport 已从 SSE 演进到 Streamable HTTP），写死细节容易过时。

## 与其他页面的关系

- 是 [[tool-calling]] 的标准化供给层
- [[agent]] 通过 MCP 获得手和眼
- 与 A2A（Agent-to-Agent）互补：MCP 管 Agent↔工具，A2A 管 Agent↔Agent
- 实体：[[spring-ai]]（官方 SDK 由 Spring 团队维护）

## 疑点与待验证

- MCP Java SDK 的当前版本与 Spring AI 版本的对应关系，待查官方文档确认（初始化检索时看到过 "MCP Java SDK 2.0.0 GA" 的说法，**未核实，勿直接引用**）。
- 国内 MCP 生态（阿里云百炼、各家的 MCP 市场）与开源标准的兼容性如何？
- 企业内部把几十个 Spring 服务 MCP 化后，工具路由与权限治理怎么做？这是个真问题，值得单独开页。

## 来源

- 无（种子页，待素材支撑）
