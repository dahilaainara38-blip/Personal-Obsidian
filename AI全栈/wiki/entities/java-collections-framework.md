---
title: Java 集合框架
type: entity
domain: java
tags: [framework, jvm, best-practice, selection]
status: growing
confidence: high
source_count: 1
created: 2026-10-13
updated: 2026-10-13
---

# Java 集合框架（Java Collections Framework, JCF）

> `java.util` 中统一组织、遍历、检索元素的接口与实现体系；选型的关键不是记类名，而是先确认顺序、重复、索引、并发和复杂度契约。

## 核心要点

- **两条顶层线**：`Collection` 管一组元素，`Map` 管 key-value 映射；`Map` 不是 `Collection`。
- **接口表达契约，类表达实现。** `List`、`Set`、`Queue`、`Deque` 规定行为边界；ArrayList、LinkedList、HashSet、TreeSet、HashMap、TreeMap 等决定底层结构与性能。
- **“有序/无序”不能混用。** `List` 有索引和迭代顺序；`LinkedHashSet`/`LinkedHashMap` 有可预测的 encounter order；`HashSet`/`HashMap` 不保证迭代顺序；`TreeSet`/`TreeMap` 按排序顺序。
- **Queue 不等于 FIFO。** `PriorityQueue` 按优先级出队，`Deque` 同时支持两端操作，`BlockingQueue` 还承担阻塞与线程协作。
- **JDK 21 增加 Sequenced Interfaces。** `SequencedCollection`、`SequencedSet`、`SequencedMap` 统一首尾访问、反向视图和 encounter order。
- **并发容器不是“加 synchronized 就完事”。** `Vector`、`Hashtable` 是旧类；高并发读写优先 `ConcurrentHashMap`，读多写少的监听器列表可考虑 [[copy-on-write|CopyOnWriteArrayList]]。

## 细节

### 接口与常用实现

```text
Iterable
└─ Collection
   ├─ List
   │  ├─ ArrayList
   │  ├─ LinkedList
   │  ├─ Vector（legacy）
   │  ├─ Stack（legacy）
   │  └─ CopyOnWriteArrayList
   ├─ Set
   │  ├─ HashSet
   │  ├─ LinkedHashSet
   │  └─ SortedSet → NavigableSet → TreeSet
   └─ Queue
      ├─ PriorityQueue
      ├─ Deque → ArrayDeque / LinkedList
      └─ BlockingQueue → ArrayBlockingQueue / LinkedBlockingQueue

Map（独立于 Collection）
├─ HashMap
├─ LinkedHashMap
├─ Hashtable（legacy）
├─ ConcurrentHashMap
└─ SortedMap → NavigableMap → TreeMap
```

### 接口契约对照

| 接口 | 顺序 | 重复 | 索引/访问 | 典型语义 |
|---|---|---|---|---|
| `List` | 有确定迭代顺序 | 允许 | 支持整数索引 | 列表、按位置访问、可含重复项 |
| `Set` | 取决于实现 | 不允许 | 不靠索引 | 去重；Hash 无序、Linked 有序、Tree 排序 |
| `Queue` | 由实现定义处理顺序 | 允许 | 通常只看队头 | FIFO、优先级或阻塞队列 |
| `Deque` | 两端确定 | 允许 | 队头/队尾 | 双端队列，也可当 LIFO 栈 |
| `Map` | 取决于实现 | key 不允许重复 | 按 key 映射 | 一个 key 最多映射一个 value |
| `SortedSet` / `SortedMap` | 按 Comparator 或自然顺序 | Set 去重 / Map key 唯一 | 范围查询 | 有序集合与有序映射 |

**Null 支持不是接口级保证。** `HashMap`、`ArrayList` 允许 null；`TreeMap`/`TreeSet` 受 comparator 限制；`List.of`、`Set.of`、`Map.of`、`ConcurrentHashMap` 拒绝 null。写通用代码时不要假设所有集合都接受 null。

### 选型表：先看需求，再看类

| 需求 | 首选 | 不该默认用 | 判断依据 |
|---|---|---|---|
| 尾部追加、按索引随机访问 | `ArrayList` | `LinkedList` | 数组连续存储，随机访问 O(1)；中部插入/删除要搬移元素 |
| 两端频繁入队/出队，或当栈 | `ArrayDeque` | `Stack`、一般场景的 `LinkedList` | 双端操作 O(1)，无旧类锁开销；不允许 null |
| 按优先级处理任务 | `PriorityQueue` | `LinkedList` | 堆结构；不是 FIFO，天然排序也不稳定 |
| 只需去重，不在乎顺序 | `HashSet` | `TreeSet` | 期望 O(1) 查找；迭代顺序不保证 |
| 去重且保留插入顺序 | `LinkedHashSet` | `HashSet` | 额外链表维护 encounter order |
| 去重并始终排序 | `TreeSet` | `HashSet` 后手动排序 | 红黑树；范围查询方便，复杂度 O(log n) |
| 普通 key-value 缓存/索引 | `HashMap` | `Hashtable` | 期望 O(1) 读写；非线程安全 |
| 需要插入或访问顺序 | `LinkedHashMap` | `HashMap` | 可做 LRU 骨架，但仍需正确处理并发 |
| key 始终有序，需要范围查询 | `TreeMap` | `HashMap` 后排序 | 红黑树；按 key 排序，复杂度 O(log n) |
| 多线程并发读写 key-value | `ConcurrentHashMap` | `Collections.synchronizedMap(new HashMap<>())` | 分段/桶级并发控制；拒绝 null key/value |
| 读极多、写极少且元素少 | `CopyOnWriteArrayList` | `ArrayList` 加锁 | 读无锁，写复制整个数组；见 [[copy-on-write]] |

### Java 版本里程碑（核实日期：2026-10-13）

| 版本 | 影响 |
|---|---|
| Java 5 | 泛型、增强 for 循环进入集合 API，类型安全成为默认写法 |
| Java 8 | 接口 default/Stream API；HashMap 冲突严重时引入树化桶 |
| Java 9 | `List.of`、`Set.of`、`Map.of` 等不可变工厂方法 |
| Java 10 | `List.copyOf`、`Set.copyOf`、`Map.copyOf` |
| Java 19 | `HashMap.newHashMap(expectedSize)`，按预期条目数预留容量 |
| Java 21 | `SequencedCollection`、`SequencedSet`、`SequencedMap`，统一首尾与反向视图 |

### Java 21 Sequenced Interfaces

JDK 21 之前，`List.get(0)` 和 `Deque.getFirst()` 是两套风格；`LinkedHashSet` 的顺序语义也没有共同接口可表达。JDK 21 用三个接口补齐：

- `List`、`Deque` 继承 `SequencedCollection`。
- `LinkedHashSet`、`SortedSet` 归属 `SequencedSet`。
- `LinkedHashMap`、`SortedMap` 归属 `SequencedMap`。
- 统一提供 `getFirst()`、`getLast()`、`addFirst()`、`addLast()`、`removeFirst()`、`removeLast()`、`reversed()` 等能力，具体可用方法取决于接口。
- `reversed()` 返回的是**活的视图**，不是快照；对原集合或反向视图的修改会互相可见。

如果项目基线是 Java 17，则不能使用这些方法，需要用 `get(0)`、`get(size - 1)`、`descendingIterator()` 等方式兼容。

## 与其他页面的关系

- 底层实现：[[java-collections-internals|Java 集合底层原理]] — 解释 ArrayList 扩容、HashMap 哈希与树化
- 可直接抄用：[[java-collections-code-recipes|Java 集合代码与踩坑]] — 完整可运行程序与反例
- 并发容器：[[copy-on-write|写时复制]] — `CopyOnWriteArrayList` / `CopyOnWriteArraySet` 的取舍
- 学习路线：[[roadmap]] — 属于 Java 底座阶段
- 原始素材：[[csdn-java-collections-framework|Java 集合框架入门手册（CSDN）]] — 二手入门稿，已知有错误

## 疑点与待验证

- 本项目最终基线是 JDK 17 还是 JDK 21？决定能否直接使用 Sequenced Interfaces。
- ArrayList、LinkedList、ArrayDeque 在不同数据规模下的真实吞吐与内存差异，需要 JMH 实测，不能只背大 O。
- `LinkedHashMap` 做 LRU 缓存时的线程安全方案、锁粒度与 Caffeine 的差距，未做实测。
- `Collections.synchronized*` 包装器与 `ConcurrentHashMap`、`CopyOnWriteArrayList` 在复合操作下的一致性边界，需要单独整理并发实践页。

## 来源

- [[csdn-java-collections-framework]] — 接口与实现类地图（二手稿，仅作入口）
- Oracle JDK 21 API：`Collection`、`List`、`Map`、`ArrayList`、`HashMap`
- Oracle JDK 21 Collections Framework Guide：Creating Sequenced Collections, Sets, and Maps
- 本机 Temurin OpenJDK 21.0.9 源码：`java.base/java/util/ArrayList.java`、`HashMap.java`（核实日期：2026-10-13）
