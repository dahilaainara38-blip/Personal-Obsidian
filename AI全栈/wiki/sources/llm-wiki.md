---
title: 素材摘要 · LLM Wiki（Karpathy）
type: source
domain: engineering
tags: [meta, best-practice, architecture]
status: growing
confidence: high
source_count: 1
created: 2026-09-16
updated: 2026-09-16
---

# 素材摘要 · LLM Wiki（Karpathy）

> 一句话：用 LLM 增量维护一个持久 wiki，替代"每次提问重新检索"的 RAG —— 让知识被编译一次并持续复利。

- 来源：https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- 作者：Andrej Karpathy · 发布 2026-04-04 · 收录 2026-09-16
- 原始素材：`raw/llm-wiki.md`

## 关键论点

1. **RAG 的根本缺陷是没有积累。** 每次提问都从零重新发现知识，跨文档综合的能力不会沉淀。NotebookLM / ChatGPT 文件上传 / 多数 RAG 系统都是这个模式。
2. **wiki 是持久、复利的产物。** 交叉引用已在、矛盾已标记、综合判断已反映全部已读素材。关键在于"编译一次 + 持续维护"，而非每次重推。
3. **三层架构**：`raw/`（素材，人写，不可变）/ `wiki/`（知识库，Agent 写）/ schema（CLAUDE.md 或 AGENTS.md，共同演进）。**schema 是让 Agent 从聊天机器人变成有纪律维护者的关键。**
4. **三个操作**：ingest（一份素材联动 10-15 页）、query（好答案落盘成新页面）、lint（矛盾 / 过时 / 孤儿页 / 缺失交叉引用）。
5. **两个导航文件**：`index.md`（内容导向，每次收录更新，中等规模下比向量检索更好用）+ `log.md`（时间序，append-only，固定前缀可 grep）。
6. **角色分工**：人负责选源、提问、判断意义；Agent 负责摘要、交叉引用、归档、账面工作。**"Obsidian 是 IDE，LLM 是程序员，wiki 是代码库。"**
7. **为什么成立**：维护知识库的痛苦在账面工作，而人类放弃 wiki 正是因为维护负担涨得比价值快。LLM 不会厌烦、不会漏更新、能一次改 15 个文件 —— 维护成本归零。
8. 思想源头：Vannevar Bush 的 Memex（1945）。Bush 没解决的问题是"谁来做维护"，LLM 解决了。

## 可复用的具体做法

- 一次收录一份素材并保持介入，别静默批量
- 收录后必须更新 `index.md` 与 `log.md`
- `log.md` 用固定前缀 `## [YYYY-MM-DD] type | title`，可用 `grep "^## " log.md | tail -5` 快速回看
- 查询产出的对比表、分析要落盘成新页面，别烂在聊天记录里
- 定期 lint：矛盾、stale、孤儿页、缺失页面、缺失交叉引用
- 图片下载到本地 `raw/assets/`，LLM 先读文本再看图（它无法一次读完带内联图的 markdown）
- 规模大时再引入 qmd 之类的本地搜索，小 wiki 用 index 就够
- wiki 本质是 git 仓库的 markdown —— 版本历史、分支、协作免费获得

## 对 Java+AI 知识库的直接影响

- 目录结构与三层架构：**已直接采用**，见 `AGENTS.md`
- "schema 是关键配置文件"：本仓库的 `AGENTS.md` 就是这个角色
- 领域定制部分（六 domain 分类法、五类页面判定、实体 vs 概念的"有没有版本号"判据）是原文没给的，属于本知识库自己的演进

## 原文中我尚未采纳的部分

- Marp 幻灯片输出 —— 暂不需要，需要时再加
- Dataview 插件查询 —— 依赖 frontmatter，本仓库已规范 frontmatter，可随时启用
- qmd 本地搜索 —— 页面数过百后再考虑
- Obsidian Web Clipper + 图片本地化 —— 已配置 `raw/assets/` 目录，待实际使用

## 疑点与待验证

- 原文声称 index 在"约 100 份素材、数百页面"规模下够用 —— 这个边界在我的实际使用节奏下是否成立？
- "一次收录触及 10-15 页"的密度，在纯技术类素材（vs 原文设想的人物/情节类）上能否达到？

## 来源

- `raw/llm-wiki.md`
