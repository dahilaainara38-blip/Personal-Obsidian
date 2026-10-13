---
title: Java 集合底层原理
type: concept
domain: java
tags: [jvm, performance, best-practice, pitfall]
status: growing
confidence: high
source_count: 1
created: 2026-10-13
updated: 2026-10-13
---

# Java 集合底层原理

> 解释 ArrayList 为什么适合随机访问、HashMap 为什么平均 O(1)，以及这些结论在扩容、冲突和并发下何时失效。

## 核心要点

- ArrayList 用**连续对象数组**保存元素，随机访问 O(1)，中部插入/删除需要搬移元素，平均 O(n)。
- ArrayList 的“初始容量 10”是逻辑契约；OpenJDK 21 实际延迟到第一次添加元素时才分配容量 10，空列表共享空数组。
- 扩容策略属于实现细节，不属于 API 保证。OpenJDK 21 在容量不足时通常按旧容量的 50% 申请增长，但源码会同时满足本次最小容量。
- HashMap 用**桶数组 + 冲突链**；容量为 2 的幂，通过 `(n - 1) & hash` 定位桶。
- HashMap 默认容量 16、默认负载因子 0.75；容量不足时通常翻倍并迁移节点。
- Java 8+ 的单桶冲突过多时会树化，但只有表容量至少 64 才真正转红黑树；表太小则优先扩容。
- HashMap 的 O(1) 是**期望复杂度**，依赖 hash 分散；恶意或错误的 `hashCode()` 会让性能和安全性一起崩。

## ArrayList 内部结构

### 字段与分配

OpenJDK 21 `ArrayList` 的核心状态：

```java
transient Object[] elementData;
private int size;
protected transient int modCount;
```

- `elementData`：真正存元素的数组。
- `size`：逻辑元素数，不总是等于 `elementData.length`。
- `modCount`：结构修改计数，迭代器用它做 fail-fast 检查。

默认构造器不会立刻 `new Object[10]`，而是指向共享空数组：

```java
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}
```

第一次 `add` 时再分配至少 10 个槽位。这个差别体现在内存占用，不改变“逻辑初始容量为 10”的使用结果。

### 扩容

OpenJDK 21 的增长调用形态是：

```java
int newCapacity = ArraysSupport.newLength(
        oldCapacity,
        minCapacity - oldCapacity, // 本次至少要增加这么多
        oldCapacity >> 1           // 首选至少增长 50%
);
```

含义：

- 正常尾部追加时，常见扩容结果是旧容量的 1.5 倍。
- 如果一次 `addAll` 需要更多空间，就直接满足最小容量，可能超过 1.5 倍。
- 扩容会创建新数组并复制旧元素，单次最坏 O(n)。
- 连续追加 n 个元素的总复制量线性增长，所以 `add` 的摊还复杂度是 O(1)。

API 文档明确说增长细节**未规定**。不要把 1.5 倍写进业务逻辑，也不要假设所有 JDK 厂商、所有版本完全一致。

### 复杂度与操作

| 操作 | 复杂度 | 原因 |
|---|---|---|
| `get(index)` / `set(index, e)` | O(1) | 数组下标直接定位 |
| `add(e)` 尾部追加 | 摊还 O(1) | 偶尔扩容复制，长期摊平 |
| `add(index, e)` | O(n) | index 后的元素整体右移 |
| `remove(index)` | O(n) | index 后的元素整体左移 |
| `contains(e)` / `indexOf(e)` | O(n) | 顺序扫描并调用 equals |
| `iterator()` 遍历 | O(n) | 按数组顺序访问 |

### 预分配与 fail-fast

- 已知数据量时使用 `new ArrayList<>(expectedSize)`，避免多次扩容；也可调用 `ensureCapacity`。
- `trimToSize()` 会收缩到当前 size，适合长期保留且不再新增的列表。
- 迭代器是 fail-fast：迭代中出现结构性修改，下一次相关操作通常抛 `ConcurrentModificationException`。
- fail-fast 是**尽力检测 bug**，不是并发保证；不能靠捕获它维持程序正确性。
- 单线程迭代删除用 `Iterator.remove()`，或直接 `removeIf`。

## HashMap 内部结构

### 桶、哈希与索引

OpenJDK 21 的默认参数：

```java
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // 16
static final float DEFAULT_LOAD_FACTOR = 0.75f;
static final int TREEIFY_THRESHOLD = 8;
static final int UNTREEIFY_THRESHOLD = 6;
static final int MIN_TREEIFY_CAPACITY = 64;
```

核心结构可抽象为：

```text
table: Node<K,V>[]  // 桶数组
index = (table.length - 1) & spreadHash(key)
```

JDK 21 在使用 `key.hashCode()` 前做高低位混合：

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

这样做的原因是桶下标只使用低位；把高 16 位异或进来，能减少低质量 `hashCode()` 的规律性碰撞。`null` key 的 hash 固定为 0。

### put/get 的大致过程

1. 计算扩散后的 hash。
2. 定位桶 `(n - 1) & hash`。
3. 桶为空：直接创建 Node。
4. 桶内比较 hash、引用/equals：
   - key 相同：覆盖 value。
   - key 不同：继续沿链表或树查找/插入。
5. 插入新映射后增加 size；超过 threshold 时扩容。
6. 桶内冲突节点过多时触发树化检查。

`get` 走同样的定位与 key 比较路径，所以正确实现 `equals` 和 `hashCode` 是 HashMap 能工作的前提。

### 扩容

- 默认容量 16、负载因子 0.75，因此默认 threshold 是 12。
- 当映射数量超过 threshold，HashMap 通常把容量翻倍，并重新分配桶。
- 容量始终使用 2 的幂；节点迁移时可以利用旧容量对应的 bit 判断留在原下标还是移动到 `原下标 + oldCapacity`。
- 扩容需要遍历和迁移节点，复杂度与当前元素量相关，不能把一次 `put` 永远视为常数时间。

已知预期条目数时可减少扩容：

```java
Map<String, Integer> map = new HashMap<>(expectedSize * 4 / 3 + 1);
```

JDK 19+ 可直接使用：

```java
Map<String, Integer> map = HashMap.newHashMap(expectedSize);
```

### 冲突链与树化

- 正常冲突在同一个桶里形成链表。
- 单个桶节点过多时，Java 8+ 可能转成红黑树，降低极端冲突下的查找成本。
- 真正树化需要桶内冲突达到阈值，并且 table 容量至少 64；容量不足时通常优先扩容。
- 扩容拆分树桶后节点太少，会退化回链表。
- 官方 API 只保证常规性能特征，不承诺具体阈值与树形算法，这些是 OpenJDK 实现细节。

HashMap 的复杂度：

| 操作 | 一般情况 | 极端情况 |
|---|---|---|
| `get` / `put` / `remove` | 期望 O(1) | hash 集中冲突时退化；Java 8+ 可能由链 O(n) 改善为树 O(log n) |
| `containsKey` | 期望 O(1) | 同上 |
| 遍历 | O(capacity + size) | 容量开得过大时，即使元素很少也慢 |
| 扩容 | O(size) | 大 map 扩容会造成明显延迟与内存峰值 |

## 对使用者的直接结论

- 自定义 key 的 `equals` 与 `hashCode` 必须一致；作为 key 后不要让参与哈希的字段再变化。
- HashMap 不保证迭代顺序；需要插入顺序/访问顺序用 `LinkedHashMap`，需要排序用 `TreeMap`。
- 不要为了“防止冲突”让每个 `hashCode()` 都返回唯一值，它本来就不是唯一 ID；重点是分布均匀。
- 已知规模时预留容量；迭代频繁时不要盲目设置超大初始容量。
- ArrayList 适合随机读和尾部追加；头尾队列操作默认看 `ArrayDeque`，不要因为“链表插入 O(1)”就无脑选 LinkedList。
- 并发场景不要直接共享普通集合；读 `[[java-collections-framework#选型表：先看需求，再看类|集合选型]]` 与 [[java-collections-code-recipes]]。

## 与其他页面的关系

- 上层入口：[[java-collections-framework|Java 集合框架]] — 接口契约与实现类矩阵
- 实践示例：[[java-collections-code-recipes|Java 集合代码与踩坑]] — 完整可运行代码
- 并发对照：[[copy-on-write|写时复制]] — `CopyOnWriteArrayList` 用写放大换无锁读
- 原始素材：[[csdn-java-collections-framework|Java 集合框架入门手册（CSDN）]] — 原文未讲底层，本页为官方补强

## 疑点与待验证

- 本页只核实本机 Temurin OpenJDK 21.0.9；其他 JDK 厂商、Java 17 与未来 LTS 的实现细节可能有差异。
- ArrayList 1.5 倍扩容是 OpenJDK 当前实现，不是 API 契约；跨版本代码不应依赖。
- HashMap 树化阈值、TreeNode 内存开销与攻击面需要结合安全场景单独验证。
- 尚未用 JMH 测 ArrayList、LinkedList、ArrayDeque 和 HashMap 在不同规模下的真实性能差异。

## 来源

- [[csdn-java-collections-framework]] — 触发收录的入门素材（二手稿，不用于底层结论）
- Oracle JDK 21 API：`ArrayList`、`HashMap`
- 本机 Temurin OpenJDK 21.0.9 `src.zip`：
  - `java.base/java/util/ArrayList.java`
  - `java.base/java/util/HashMap.java`
- 核实日期：2026-10-13
