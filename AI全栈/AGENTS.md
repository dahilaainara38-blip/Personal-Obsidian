# AGENTS.md — Java + AI 全栈知识库规范

> 本文件是 `LLM Wiki`（Andrej Karpathy）模式在本仓库的实例化。
> **任何在本仓库工作的 LLM Agent，开工前必须先读完本文件。**
> 本规范由人和 Agent 共同演进：发现规则不适用时，直接修改本文件并在 `wiki/log.md` 记一条 `schema` 变更。

---

## 0. 一句话原则

> **原始素材是不可变的真理，wiki 是不断复利的二手认知，本文件是维护 wiki 的操作手册。**
> 人负责选源、提问、判断；Agent 负责摘要、交叉引用、归档、账面工作。

---

## 1. 三层架构与权责

| 层 | 位置 | 谁写 | 谁改 | 内容 |
|---|---|---|---|---|
| 原始素材 | `raw/` | **人** | 人（Agent 只读，永不修改） | 文章、文档、PDF、截图、代码、笔记 |
| 知识库 | `wiki/` | **Agent** | Agent（人只读） | 摘要页、实体页、概念页、分析页、实践页 |
| 规范 | `AGENTS.md` + `wiki/conventions.md` | 人与 Agent 共同 | 双方 | 结构约定、工作流、操作偏好 |

**红线：Agent 永远不写 `raw/`。人也尽量不手写 `wiki/`（想改就开口让 Agent 改）。**

---

## 2. 目录结构

```
AI全栈/
├── AGENTS.md              # 本文件：结构 + 工作流规范
├── raw/                   # 原始素材（不可变）
│   ├── assets/            #   图片与附件（Obsidian 附件目录指向此处）
│   └── *.md / *.pdf / *   #   素材文件
├── wiki/                  # Agent 维护的知识库
    ├── index.md           #   内容索引（每次收录后必须更新）
    ├── log.md             #   操作日志（append-only）
    ├── overview.md        #   总览与当前认知状态
    ├── conventions.md     #   人的操作偏好
    ├── roadmap.md         #   Java+AI 全栈学习路线（领域定制）
    ├── sources/           #   素材摘要页（一个素材一页）
    ├── entities/          #   实体页：具体的框架、工具、产品、组织
    ├── concepts/          #   概念页：抽象的原理、模式、方法论
    ├── analyses/          #   分析页：对比、选型、综合论证
    └── practices/         #   实践页：可复用代码骨架、配置、清单、踩坑
└── tools/                 # 确定性脚本（人建，Agent 可用不可改）
    ├── lint.sh            #   机械检查：死链/孤儿/index 一致/frontmatter/log 格式/seed 老化
    └── stats.sh           #   统计打印（index.md 不再手写统计）
```

### 页面类型判定

| 类型 | 判定标准 | 例子 |
|---|---|---|
| `entity` | 有名字、有版本、会迭代的具体东西 | Spring AI、LangChain4j、pgvector、Milvus、Redis |
| `concept` | 无版本、跨实现通用的抽象 | RAG、Agent、Prompt 工程、事务隔离级别、一致性哈希 |
| `analysis` | 需要跨多个页面综合才能得出的结论 | 框架选型、向量库对比、"我该不该微调" |
| `practice` | 能直接抄走用的东西 | 项目骨架、Dockerfile、调优清单、常见报错 |
| `source` | 一份原始素材的摘要 | 某篇文章/某篇文档的摘要 |

**拿不准是实体还是概念？** 问："它有没有版本号？"有 → 实体；没有 → 概念。

---

## 3. 页面格式规范

### 3.1 Frontmatter（每个 wiki 页面必须有）

```yaml
---
title: Spring AI
type: entity            # source | entity | concept | analysis | practice | overview | index | log | roadmap
domain: ai              # java | ai | data | infra | frontend | engineering
tags: [framework, llm, spring]
status: seed            # seed | growing | stable | stale | contested
confidence: medium      # low | medium | high
source_count: 0         # 支撑本页的素材数量
created: 2026-09-16
updated: 2026-09-16
---
```

字段含义：
- `status`
  - `seed` 初始化骨架，尚无素材支撑。**超 30 天仍 `source_count: 0`（lint.sh 第 6 项会报）：与人确认后要么尽快喂素材，要么降级为 [[roadmap]] 一行待办并删除页面——不许无限期沉淀成"看起来像定论"**
  - `growing` 已有素材但结论未稳
  - `stable` 多源交叉验证，可放心引用
  - `stale` 已知滞后于新信息，待更新
  - `contested` 存在相互矛盾的说法，正文里必须写明矛盾点
- `confidence` 结论可信度。`low` 的页面禁止作为选型依据。

### 3.2 正文骨架

```markdown
# 标题

> 一句话定义（30 字内，说清"它是什么/解决什么问题"）

## 核心要点
（3-7 条，每条一句话，可独立成立）

## 细节
（展开、示例、代码）

## 与其他页面的关系
（显式 [[链接]]，并说明关系：依赖 / 对立 / 替代 / 构成）

## 疑点与待验证
（不确定的地方、需要查证的版本号、想做的实验）

## 来源
- [[sources/xxx]] — 支撑了哪几条结论
```

**"疑点与待验证" 段是强制的。** 写不出疑点说明理解还太浅，宁可写"待验证：xxx 是否支持 xxx"。

### 3.3 命名与链接约定

- **文件名**：英文小写 kebab-case（`spring-ai.md`、`rag.md`、`vector-search.md`）。
  理由：shell / grep / 脚本 / Agent 工具链零编码问题，图视图也清晰。
- **标题**：`title` frontmatter 用中文或官方原名。
- **链接**：使用 Obsidian wiki link，带中文别名 —— `[[spring-ai|Spring AI]]`。
- **禁止**：创建空页面占位。要么写有内容，要么不建。
- **禁止**：中文文件名、空格文件名、大写文件名。

### 3.4 index.md 与统计

- index 只做目录：**链接 + 一句话**（sources 表可加收录日期）。**不加 status / 源数列** —— frontmatter 是唯一事实源，双份维护必然漂移。
- 统计不手写，按需跑 `bash tools/stats.sh`。

---

## 4. 三个核心操作

### 4.1 Ingest — 收录素材

触发：人把新素材放进 `raw/`，说"收录 xxx"或"收录 raw/ 下所有新素材"。

流程：
1. **读**：完整读素材。若是文章，先读文本；若引用了本地图片，再单独查看关键图片。
2. **聊**：先输出 3-5 条关键 takeaway，跟人确认"哪些是你真正关心的"。**不要跳过这步直接写。**
3. **建**：在 `wiki/sources/` 建摘要页，命名 `<素材文件名>.md`，含来源链接、日期、核心论点、可复用的具体结论。
4. **拆**：识别素材中的实体与概念，为每一个：
   - 已有页面 → 更新，追加新信息，更新 `updated` 与 `source_count`
   - 新页面 → 按 3.2 骨架创建
5. **连**：双向补链接。新页面必须至少 2 条出链，且至少被 1 个已有页面入链（避免孤儿页）。
6. **冲突**：若新素材与既有结论矛盾，**不要覆盖**，在两处都标注 `status: contested` 并在正文写明矛盾点与各自来源。
7. **更索引**：更新 `wiki/index.md`，新页面入目录。
8. **记日志**：向 `wiki/log.md` 追加：`## [YYYY-MM-DD] ingest | <素材名> | 新建 N 页 / 更新 M 页`
9. **报**：向人报告改了哪些文件、有哪些新发现、有哪些矛盾。
10. **提交**：`git add -A && git commit -m "ingest | <素材名>" && git push`（推送失败不阻塞，本地 commit 照做）。

一次收录通常联动 5-15 个页面，这是正常的，不要为了少改文件而省略。

### 4.2 Query — 查询

触发：人提问。

流程：
1. 先读 `wiki/index.md` 定位相关页面，再下钻读具体页面，**最后**才考虑读 `raw/`。
2. 作答必须带 `[[页面链接]]` 引用，让人能点进去核对。
3. 若 wiki 里没有答案：明确说"wiki 暂无"，然后从 `raw/` 或联网补齐，并**在回答后询问是否顺手收录进 wiki**。
4. **好答案要落盘**：对比表、选型结论、架构分析、这次想明白的东西 —— 一律写成 `wiki/analyses/` 或 `wiki/practices/` 的新页面，别让它烂在聊天记录里。
5. 记日志：`## [YYYY-MM-DD] query | <问题摘要>`；若本轮有页面落盘，同样 git commit（`query | <问题摘要>`）并 push。

### 4.3 Lint — 健康检查

触发：人说"体检"、"lint"，或每收录 10 份素材后主动建议一次。

流程（双轨制）：

1. **先跑脚本**（机械检查，确定性、零漂移）：`bash tools/lint.sh`
   覆盖：死链 · 孤儿页 · index 与文件系统双向一致 · frontmatter 完整性与取值 · log 条目格式 · seed 老化。
   脚本结果原样转达，不逐条复述。
2. **再做语义检查**（LLM 才做得来的部分）：
   - [ ] `status: contested` 的矛盾是否已解决
   - [ ] `status: stale` 的页面（尤其版本号、API 签名）—— 建议联网核实
   - [ ] 被反复提及但没有独立页面的概念
   - [ ] 缺失的交叉引用（A 提到 B 但没链过去）
   - [ ] 各页"疑点与待验证"里积压最久、价值最高的几条 —— 给出查证优先级
3. 输出：脚本结果 + 语义问题（按严重程度排序）+ 建议的下一步（补哪个源、问哪个问题）。
4. 记日志并 git commit：`lint | 发现 N 个问题`

### 4.4 并发与写入纪律

多个客户端（Claude Code / Claudian / workbuddy）共用本仓库，靠纪律 + git 兜底：

- **同一时刻只进行一次收录。** 开工前先 `git pull --rebase`；若 `wiki/log.md` 最后一条距今不足 10 分钟，先与人确认没有另一个会话正在跑。
- **`log.md` 只允许在文件末尾追加**，禁止整文件重写、禁止修改历史条目。
- **落盘即提交**：每次 ingest / query 落盘 / lint 修复后立即 commit 并 push，不要攒。
- 工作区若有非自己产生的未提交改动：先 `git status` 看清并报告给人，不盲目覆盖。

---

## 5. 领域定制：Java + AI 全栈分类法

`domain` 字段取值与边界：

| domain | 覆盖 | 典型页面 |
|---|---|---|
| `java` | JVM/JDK、语言特性、并发、Spring 生态、ORM、性能调优、测试 | 虚拟线程、Spring Boot 3、JPA |
| `ai` | LLM 原理、Prompt、RAG、Agent、向量检索、微调、评测、MCP/A2A | RAG、Agent、Spring AI |
| `data` | 关系库、缓存、MQ、向量库、数仓 | Redis、pgvector、Kafka |
| `infra` | Docker、K8s、CI/CD、可观测性、云原生 | Dockerfile、Micrometer |
| `frontend` | TS、React/Vue、构建、流式 UI | SSE 流式渲染 |
| `engineering` | 架构模式、DDD、代码质量、工程方法、协作 | 分层架构、DDD |

**跨领域页面以主线 domain 为准，`tags` 里补其他领域。**

### 高频标签表（复用，不要自造）

`framework` `llm` `rag` `agent` `prompt` `embedding` `vector-db` `tool-calling` `mcp`
`spring` `jvm` `concurrency` `orm` `sql` `cache` `mq`
`docker` `k8s` `observability` `devops`
`typescript` `react` `streaming`
`architecture` `ddd` `testing` `performance` `security`
`selection` `best-practice` `pitfall`

---

## 6. 写作风格

- 中文正文，技术名词保留英文原文（Spring AI、RAG、embedding）。
- 结论先行，能列表不写段落。
- 代码必须有实际内容，禁止 `// TODO` 占位。
- 版本号必须写出来，并标注核实日期；不确定的写"待核实"。
- 不写"显而易见""众所周知""需要注意的是"这类填充词。
- 每个主观判断都要说清判断依据，不能只给结论。

---

## 7. 快捷指令

| 人说 | Agent 做 |
|---|---|
| 收录 / ingest | 执行 4.1 |
| 体检 / lint | 执行 4.3 |
| 统计 / stats | 跑 `bash tools/stats.sh` 打印知识库现状 |
| 索引 | 重建 `wiki/index.md` |
| 路线 | 打开/更新 `wiki/roadmap.md` |
| 归档本次讨论 | 把本轮对话的结论落成 wiki 页面 |
