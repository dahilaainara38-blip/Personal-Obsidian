---
title: Java 集合代码与踩坑
type: practice
domain: java
tags: [best-practice, pitfall, performance, concurrency]
status: growing
confidence: high
source_count: 1
created: 2026-10-13
updated: 2026-10-13
---

# Java 集合代码与踩坑

> 面向 JDK 17/21 的集合实践清单：代码可编译运行，重点覆盖遍历删除、Map 归并、不可变集合、并发复合操作与可变 key。

## 核心要点

- 遍历时删除元素，必须走 `Iterator.remove()` 或 `removeIf()`；不要在增强 for 中直接删集合。
- `Arrays.asList()` 是固定大小视图，`List.of()` 是不可变集合，两者都不是“普通 ArrayList”。
- Map 的累加/初始化优先 `merge`、`compute` 或 `computeIfAbsent`；`containsKey` 后再写入不是原子操作。
- ArrayList 的 `toArray()` 优先传目标类型数组或数组构造器，不要硬转 `Object[]`。
- `Collections.synchronizedList()` 只同步单次方法调用；遍历时仍要手动 `synchronized`。
- 对象作为 HashMap key 后，不要让参与 `equals/hashCode` 的字段发生变化。

## 可直接运行的完整程序

保存为 `JcfRecipes.java`，使用 JDK 17 或 JDK 21 编译运行：

```java
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

public class JcfRecipes {
    public static void main(String[] args) {
        iteratorRemoval();
        arrayConversion();
        mapMerge();
        immutableVsFixed();
        concurrentCompoundUpdate();
        mutableKeyTrap();
    }

    static void iteratorRemoval() {
        List<String> names = new ArrayList<>(List.of("Jack", "Tom", "Helen"));
        Iterator<String> iterator = names.iterator();
        while (iterator.hasNext()) {
            if ("Tom".equals(iterator.next())) {
                iterator.remove();
            }
        }
        System.out.println("iterator: " + names);
    }

    static void arrayConversion() {
        List<String> names = List.of("Jack", "Tom");
        String[] array = names.toArray(String[]::new);
        System.out.println("array: " + Arrays.toString(array));
    }

    static void mapMerge() {
        Map<String, Integer> counts = new HashMap<>();
        for (String word : List.of("a", "b", "a")) {
            counts.merge(word, 1, Integer::sum);
        }
        counts.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .forEach(entry -> System.out.println("map: " + entry.getKey() + "=" + entry.getValue()));
        System.out.println("default: " + counts.getOrDefault("missing", 0));
    }

    static void immutableVsFixed() {
        List<String> fixed = Arrays.asList("a", "b");
        fixed.set(0, "A"); // 允许替换；fixed.add("c") 会抛 UnsupportedOperationException
        List<String> immutable = List.of("a", "b");
        System.out.println("fixed: " + fixed + ", immutable: " + immutable);
    }

    static void concurrentCompoundUpdate() {
        ConcurrentHashMap<String, Integer> counts = new ConcurrentHashMap<>();
        counts.merge("request", 1, Integer::sum);
        counts.merge("request", 1, Integer::sum);
        System.out.println("concurrent: " + counts.get("request"));
    }

    static void mutableKeyTrap() {
        Map<MutableKey, String> map = new HashMap<>();
        MutableKey key = new MutableKey("before");
        map.put(key, "value");
        key.value = "after";
        System.out.println("mutable key after mutation: " + map.get(key));
    }

    static final class MutableKey {
        String value;

        MutableKey(String value) {
            this.value = value;
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof MutableKey that && Objects.equals(value, that.value);
        }

        @Override
        public int hashCode() {
            return Objects.hash(value);
        }
    }
}
```

编译运行：

```bash
javac -encoding UTF-8 JcfRecipes.java
java JcfRecipes
```

预期输出：

```text
iterator: [Jack, Helen]
array: [Jack, Tom]
map: a=2
map: b=1
default: 0
fixed: [A, b], immutable: [a, b]
concurrent: 2
mutable key after mutation: null
```

## 遍历中删除

错误写法：

```java
for (String name : names) {
    if ("Tom".equals(name)) {
        names.remove(name); // 下一次迭代通常抛 ConcurrentModificationException
    }
}
```

正确写法一：

```java
Iterator<String> iterator = names.iterator();
while (iterator.hasNext()) {
    if ("Tom".equals(iterator.next())) {
        iterator.remove();
    }
}
```

正确写法二：

```java
names.removeIf("Tom"::equals);
```

`fail-fast` 用于快速暴露 bug，不是线程安全机制；并发修改仍应换成对应并发容器或外部同步。

## Map 的安全写法

### 计数：优先 merge

```java
Map<String, Integer> counts = new HashMap<>();
counts.merge("request", 1, Integer::sum);
```

即使 `"request"` 不存在，`merge` 也会写入初始值 1；存在时执行 `oldValue + 1`。

### 按需创建集合

```java
Map<String, List<String>> groups = new HashMap<>();
groups.computeIfAbsent("java", ignored -> new ArrayList<>()).add("ArrayList");
```

### 并发安全不等于复合操作安全

```java
ConcurrentHashMap<String, Integer> counts = new ConcurrentHashMap<>();

// 错误：检查与写入不是原子复合操作
if (!counts.containsKey("request")) {
    counts.put("request", 1);
} else {
    counts.put("request", counts.get("request") + 1);
}

// 正确：由容器的原子方法完成归并
counts.merge("request", 1, Integer::sum);
```

其他可从原子语义中受益的方法包括 `compute`、`computeIfAbsent`、`putIfAbsent`。

## ArrayList 与数组转换

不推荐依赖数组整体强转：

```java
List<String> names = List.of("Jack", "Tom");
Object[] objects = names.toArray();
// String[] wrong = (String[]) objects; // 运行时 ClassCastException
```

推荐写法：

```java
String[] array1 = names.toArray(String[]::new); // Java 11+
String[] array2 = names.toArray(new String[0]); // Java 8 兼容
```

`toArray(T[])` 会根据传入数组的运行时类型创建结果；空数组只是类型模板，不是容量限制。

## 不可变集合与固定大小集合

| 写法 | 能否 set | 能否 add/remove | 能否含 null | 是否反映原数组变化 |
|---|---|---|---|---|
| `Arrays.asList(array)` | 可以 | 不可以 | 可以 | 是，底层是固定大小视图 |
| `List.of(...)` | 不可以 | 不可以 | 不可以 | 否，不可变集合 |
| `new ArrayList<>(List.of(...))` | 可以 | 可以 | 取决于源，结果可变 | 否，独立副本 |
| `List.copyOf(source)` | 不可以 | 不可以 | 不可以 | 否，不可变副本 |

需要可变副本时明确复制：

```java
List<String> mutable = new ArrayList<>(List.of("a", "b"));
```

## 同步包装器的边界

`Collections.synchronizedList()` 会让单个方法调用持锁，但迭代器遍历不是一次方法调用：

```java
List<String> list = Collections.synchronizedList(new ArrayList<>());
list.add("a");
list.add("b");

synchronized (list) {
    for (String value : list) {
        System.out.println(value);
    }
}
```

更简单的并发选型：

- 读极多、写极少、元素少：`CopyOnWriteArrayList`，见 [[copy-on-write]]。
- 并发 key-value：`ConcurrentHashMap`。
- 生产者消费者：`ArrayBlockingQueue`、`LinkedBlockingQueue` 等阻塞队列。
- 普通 ArrayList/HashMap：只用于单线程，或由外部锁完整保护。

## Null 支持速查

| 集合 | null key | null value/element | 备注 |
|---|---|---|---|
| `ArrayList` | 不适用 | 允许 | 非线程安全 |
| `ArrayDeque` | 不适用 | 不允许 | 适合栈/队列 |
| `HashSet` | 不适用 | 允许一个 null | 迭代顺序不保证 |
| `HashMap` | 允许一个 | 允许多个 | 非线程安全 |
| `ConcurrentHashMap` | 不允许 | 不允许 | 并发容器 |
| `List.of` / `Set.of` / `Map.of` | 不允许 | 不允许 | 不可变工厂 |
| `TreeSet` / `TreeMap` | 受 comparator 影响 | value 取决于实现 | 自然排序通常不能处理 null key |

## 容量与顺序

- 已知元素数量的 ArrayList：`new ArrayList<>(expectedSize)`。
- 已知映射数量的 HashMap：JDK 19+ 用 `HashMap.newHashMap(expectedSize)`；更早版本按预期 size 和 0.75 负载因子预留。
- `HashMap`/`HashSet` 不保证迭代顺序，扩容后顺序也可能变化。
- 需要插入顺序：`LinkedHashSet` / `LinkedHashMap`。
- 需要按 key 排序：`TreeSet` / `TreeMap`。
- 遍历 Map 键值对用 `entrySet()`，不要 `keySet()` 后再逐个查询。

## 与其他页面的关系

- 选型与接口契约：[[java-collections-framework|Java 集合框架]]
- 扩容与哈希表原理：[[java-collections-internals|Java 集合底层原理]]
- 并发读多写少：[[copy-on-write|写时复制]]
- 原始素材：[[csdn-java-collections-framework|Java 集合框架入门手册（CSDN）]] — 原示例有错误，本页为可运行替换版

## 疑点与待验证

- 示例在本机 Temurin OpenJDK 21.0.9 编译运行通过；未在 Java 17、其他厂商 JDK 上逐一回归。
- `List.of` 的空值与不可变行为在 Java 9+ 稳定，但早期 Java 8 项目必须换成 `Collections.unmodifiableList` 等兼容写法。
- `LinkedHashMap` 手写 LRU 与 Caffeine 的性能、命中率和并发差异未实测。
- 阻塞队列的拒绝策略、公平锁和吞吐量需要按生产者消费者压力单独验证。

## 来源

- [[csdn-java-collections-framework]] — 触发收录的入门素材
- Oracle JDK 21 API：`Collection`、`List`、`Map`、`ArrayList`、`HashMap`
- 本机 Temurin OpenJDK 21.0.9 `src.zip`
- 可运行程序核实日期：2026-10-13
