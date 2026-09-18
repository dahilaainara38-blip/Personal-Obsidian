---
title: 知识库总览
type: overview
domain: engineering
tags: [meta]
status: growing
confidence: high
source_count: 0
created: 2026-09-16
updated: 2026-09-18
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

- 初始化日期：2026-09-16 · 最近收录：2026-09-18（小林coding Redis 系列 14 篇）
- 页面数：42 · 素材数：16 · 统计明细跑 `bash tools/stats.sh`
- 覆盖 domains：data（Redis 已成体系）/ ai / java / infra / frontend / engineering

**认知分布严重不均衡：data 域 Redis 一条线已闭环**（综述 → 持久化 → 复制/哨兵/Cluster → 缓存实战三题 → 底层结构，疑点大部分已补齐），**但 AI 侧 13 页仍是 seed / source_count: 0**。知识库正在变成"Redis 八股库"——下一步必须转向 AI 侧素材（Spring AI 官方文档优先），否则偏离主线。

## 怎么开始用

1. 素材放进 `raw/`（不是 `资料/`——放错了 Agent 会挪并记录）
2. 对 Agent 说「收录」；攒够一批说「体检」（`bash tools/lint.sh` + 语义检查）
3. 读完摘要后，用「提问」去压它；好答案会落盘

详细工作流见 `AGENTS.md`（含 git 提交纪律），操作偏好见 [[conventions]]，学习路线见 [[roadmap]]。

## 知识地图（三层）

```
raw/                 素材层 —— 你写，Agent 只读
  ↓ ingest
wiki/                认知层 —— Agent 写，你读
  sources/           单份素材的摘要（16）
  entities/          具体技术：Redis、Spring AI、LangChain4j…
  concepts/          抽象原理：RAG、分布式锁、缓存一致性…
  analyses/          综合结论：选型、对比
  practices/         能抄走用的：骨架、清单、踩坑
  ↓ 沉淀
AGENTS.md + tools/   规范层 —— 共同演进 + 机械检查
```

## 与其他页面的关系

- [[conventions]] — 收录与写作的操作偏好
- [[roadmap]] — 六阶段学习路线，标注了每阶段该填哪些页面
- [[index]] — 全量页面目录

## 疑点与待验证

- 这套分类法（entities/concepts/analyses/practices）在 16 份素材后仍然够用；`projects/`（实战项目记录）暂不建
- Redis 一条线走完后的固定模式：**系列文成批收录 > 单篇零收**——AI 侧也应按系列收（官方文档、论文合集）
- 用户两次把素材放进 `资料/` 而非 `raw/`——考虑把"扫描全库未收录素材"做成 Agent 的自动行为，而不是要求人改习惯
- 规模到 100+ 页面时 `index.md` 是否还够用，届时需要引入 qmd 之类的本地搜索

## 来源

- 无（本页为总览导航页）
