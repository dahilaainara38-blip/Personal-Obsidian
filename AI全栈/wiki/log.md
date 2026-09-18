---
title: 操作日志
type: log
domain: engineering
tags: [meta]
status: stable
confidence: high
source_count: 0
created: 2026-09-16
updated: 2026-09-16
---

# 操作日志

> Append-only。每条以 `## [YYYY-MM-DD] <操作类型> | <对象>` 开头，可用 `grep "^## " wiki/log.md | tail -20` 快速回看。
> 操作类型：`ingest` | `query` | `lint` | `schema` | `init`

---

## [2026-09-16] init | 知识库初始化

依据 Karpathy《LLM Wiki》方法论实例化，主题定为 **Java + AI 全栈**。

- 建立三层结构：`raw/`（素材，人写）、`wiki/`（知识库，Agent 写）、`AGENTS.md`（规范）
- wiki 下设 `sources/ entities/ concepts/ analyses/ practices/`
- 落地规范：frontmatter 字段、五类页面判定标准、kebab-case 命名、ingest/query/lint 三工作流、六 domain 分类法
- 预置 16 个种子页：5 概念、4 实体、1 分析、1 实践、路线图、总览、索引、约定
- 所有种子页标记 `status: seed` / `source_count: 0`，**结论未经验证**
- 待建页面清单已写入 `wiki/index.md`

## [2026-09-16] ingest | LLM Wiki（Karpathy）

首份素材，即本知识库的方法论原文。

- 落地 `raw/llm-wiki.md`（整理摘录版，保留全部关键论点与目录结构）
- 新建 `wiki/sources/llm-wiki.md` 摘要页
- 更新 `wiki/overview.md` 与 `wiki/index.md` 统计
- 明确未采纳项：Marp 幻灯片、Dataview、qmd 搜索（规模到了再说）
- 本知识库自创、原文未给的部分：六 domain 分类法、五类页面判定、"有没有版本号"的实体/概念判据

下一步：收录你选定框架的官方文档（Spring AI 或 LangChain4j 二选一起步），把 `status: seed` 的实体页推进到 `growing`。

## [2026-09-18] schema | 素材位置纠正

用户把素材放入了 `资料/` 而非 `raw/`。已将 `资料/什么是 Redis？.md` 移入 `raw/redis-overview.md` 并按 kebab-case 重命名。

- 约定重申：**所有素材一律进 `raw/`**，`资料/` 不再作为素材入口
- 中文文件名 + 全角问号会破坏 CLI/脚本处理，入库前统一改英文 kebab-case

## [2026-09-18] ingest | Redis 综述（小林coding）

第二份素材，也是第一份**技术主题**素材。原文是机翻稿，语义多处不通，已标注。

- 新建 6 页：`sources/redis-overview.md`、`entities/redis.md`（从待建清单移除）、`concepts/redis-persistence.md`、`concepts/redis-cluster.md`、`concepts/data-sharding.md`、`concepts/copy-on-write.md`
- 更新 3 页：`index.md`、`overview.md`、`roadmap.md`
- 交叉链接：Redis 持久化 → [[copy-on-write]]（跨到 OS/Java 域）；Redis 作为向量库的可能性 → [[rag]]（跨到 AI 域，待验证）
- 本次收录暴露的知识空白（已记入 index 待建清单）：缓存穿透/击穿/雪崩、双写一致性、淘汰策略、一致性哈希、哈希槽为何是 16384

## [2026-09-18] lint | 收录后自检

- 死链：0
- 孤儿页：0
- 新增 `status: growing` 6 页，`seed` 仍为 15 页
- **主要问题：AI 侧 15 个种子页全部 `source_count: 0`**，知识库呈现"data 域有料、ai 域空转"的失衡状态
- 建议下一步：优先收录 Spring AI 或 LangChain4j 官方文档

## [2026-09-18] schema | 接入 git 工作流 + lint 双轨制 + index 瘦身

知识库接入 git 远程（Personal-Obsidian，main），并把账面工作从模型自律改为机械保证：

- 新增 `tools/lint.sh`（死链 / 孤儿页 / index↔文件系统 / frontmatter / log 格式 / seed 老化）与 `tools/stats.sh`（统计打印）。首跑全部通过。
- **lint 改双轨制**（AGENTS.md §4.3）：脚本管机械检查，LLM 只做语义检查（矛盾 / 缺交叉引用 / 查证优先级）
- **ingest 增加第 10 步**：收录完成即 `git add -A && git commit && git push`；query 落盘同样提交
- **新增 §4.4 并发与写入纪律**：同一时刻一次收录、开工前 `git pull --rebase`、log.md 只许末尾追加、落盘即提交
- **seed 生命周期规则**：超 30 天仍无素材 → 与人确认后喂素材或降级删除
- type 枚举补全 `index / log / roadmap`；[[roadmap]] 从 analysis 归为独立导航类型
- **index.md 瘦身**：去掉 status / 源数列与手写统计段，只留链接 + 一句话（frontmatter 是唯一事实源）
