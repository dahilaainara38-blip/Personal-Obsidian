# raw/ — 原始素材层

> **这是你的地盘。往这里丢东西，Agent 只读，永不修改。**

## 放什么

- 文章剪藏（Obsidian Web Clipper 导出的 markdown）
- 官方文档导出、论文 PDF
- 截图、架构图 → 放 `assets/`
- 你自己的代码片段、踩坑记录、会议笔记

## 命名

- 英文小写 kebab-case：`spring-ai-reference.md`、`rag-survey.pdf`
- 日期前缀可选：`2026-09-16-xxx.md`

## 收录流程

放进来之后，对 Agent 说：

```
收录 raw/ 里的 <文件名>
```

Agent 会：读素材 → 给 takeaway 跟你讨论 → 在 `wiki/sources/` 建摘要页 → 更新相关实体/概念页 → 更新 `index.md` 和 `log.md`。

## 注意

- 二手解读类素材请在前置 metadata 里标注 `type: secondary`，Agent 会在 wiki 里标出来
- 带图片的 markdown，建议先用 Obsidian 的「下载当前文件的附件」把图片落到 `assets/`
