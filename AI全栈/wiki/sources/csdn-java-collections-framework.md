---
title: 素材摘要 · Java 集合框架入门手册（CSDN）
type: source
domain: java
tags: [framework, best-practice, pitfall]
status: growing
confidence: low
source_count: 1
created: 2026-10-13
updated: 2026-10-13
---

# 素材摘要 · Java 集合框架入门手册（CSDN）

> 一篇 2021 年的 Java 集合入门导读：可用于建立「接口 → 实现类」地图，但存在多处概念错误，不能作为选型或底层原理依据。

- 来源：https://blog.csdn.net/weixin_51367845/article/details/120755870
- 作者：吞吞吐吐大魔王 · 发布 2021-10-14 · 收录 2026-10-13
- 原始素材：`raw/【Java 集合框架】最全的 Java 集合框架入门手册.md`
- 素材性质：CSDN 二手入门稿；API 链接指向 Java 8；图片为远程链接，未本地化

## 关键论点

1. **集合框架本质是接口、实现类与算法的统一架构。** `Collection` 管一组元素，`Map` 管键值映射；两者不是同一条继承链。
2. **掌握实现类，不能只会接口。** 同一接口下，数组、链表、哈希表、树、堆会带来完全不同的顺序、复杂度、内存开销与并发语义。
3. **迭代器负责遍历与安全删除。** `hasNext()` / `next()` / `remove()` 是基本协议，但文章没有交代 fail-fast 的真实边界。
4. **常用 API 足够跑通入门示例。** `add`、`remove`、`size`、`toArray`、`get`、`getOrDefault`、`put`、`entrySet` 是高频入口。
5. **文章没有进入源码层。** ArrayList 扩容、HashMap 哈希扰动/扩容/树化、并发容器选型均未展开，需要由 JDK 21 官方文档与本机 OpenJDK 源码补足。

## 可复用的具体结论

- 用 `Iterator.remove()` 删除正在遍历的元素；不要用集合自身的 `remove()` 破坏迭代状态。
- Map 遍历键值对优先用 `entrySet()`，不要通过 `keySet()` 再逐个 `get()`。
- `Map.put()` 对已存在的 key 会覆盖旧值；Map 的 key 始终唯一。
- `Collection.toArray(T[])` 可以保留目标数组的运行时类型；用 `String[]::new` 或 `new String[0]`，不要硬转 `Object[]`。

## 原文错误与修正

| 原文表述 | 问题 | 修正 |
|---|---|---|
| Collection 存储“无序、不唯一”的对象 | 把接口契约说死；重复与顺序语义由子接口和实现决定 | `List` 有索引顺序且允许重复；`Set` 不允许重复；Collection 根接口本身不规定这两点 |
| Queue 一定按插入顺序 FIFO | `Queue` 只定义“处理顺序”，不保证 FIFO | `PriorityQueue` 按优先级出队；`Deque` 支持队头/队尾，也可当栈 |
| Set、Map 都是无序 | “无序”容易被理解成随机；HashMap/HashSet 只是不保证迭代顺序 | `LinkedHashSet` 保留插入顺序；`TreeSet` 排序；`LinkedHashMap` 可保留插入或访问顺序；`TreeMap` 按 key 排序 |
| Map 中 key 可以重复 | 概念错误 | key 唯一；重复 `put` 只覆盖 value，不产生第二个映射 |
| `Object[]` 能整体转 `Integer[]` | 代码与解释都错误 | 数组有运行时组件类型；可使用 `collection.toArray(new Integer[0])` 或 `toArray(Integer[]::new)` |
| Vector/Stack 因同步所以是好选择 | 旧类，粗粒度同步；Stack 继承 Vector | 新代码默认 `ArrayList` / `ArrayDeque`；并发场景按需求选 `ConcurrentHashMap`、`CopyOnWriteArrayList` 或阻塞队列 |
| 代码块可直接运行 | 混入 `java运行1` 等抓取噪声，缺少 import 与方法上下文 | 只能作为片段参考；可运行版本见 [[java-collections-code-recipes]] |

## 与本知识库的关系

- 入口页：[[java-collections-framework|Java 集合框架]] — 文章只给了名字，实体页补全接口边界、实现矩阵与 JDK 版本差异
- 原理页：[[java-collections-internals|Java 集合底层原理]] — 补 ArrayList 扩容与 HashMap 哈希表机制
- 实践页：[[java-collections-code-recipes|Java 集合代码与踩坑]] — 把文章的错误示例替换为可编译、可运行的完整程序

## 本次收录动作

- 新建：本摘要、[[java-collections-framework]]、[[java-collections-internals]]、[[java-collections-code-recipes]]
- 更新：[[copy-on-write]] 的 Java 集合关联、[[roadmap]]、[[index]]、[[log]]
- 原文中的错误只在 wiki 修正，不改写 `raw/` 原文

## 疑点与待验证

- 文章发布已接近 5 年，Java 8 到 JDK 21 的 API 与实现差异很大；本页不把原文当作时效性来源。
- 文章引用的集合框架图与运行截图都是远程图片，未进入 `raw/assets/`；后续如需引用图示，应重新绘制或以官方结构为准。
- 文章未覆盖并发集合、序列化、不可变集合、Comparator、泛型 PECS；这些已拆分到实体页或待后续单独收录。

## 来源

- `raw/【Java 集合框架】最全的 Java 集合框架入门手册.md`
- Oracle JDK 21 API：`Collection`、`List`、`Map`、`ArrayList`、`HashMap`
- Oracle JDK 21 Collections Framework Guide：Creating Sequenced Collections, Sets, and Maps
- 本机 Temurin OpenJDK 21.0.9 `src.zip`：`java.base/java/util/ArrayList.java`、`HashMap.java`
