---
title: "【Java 集合框架】最全的 Java 集合框架入门手册"
source: "https://blog.csdn.net/weixin_51367845/article/details/120755870?ops_request_misc=elastic_search_misc&request_id=dc0d383026a9136e7bc90ac5be08923c&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~ElasticSearch~search_v2-2-120755870-null-null.142^v102^pc_search_result_base7&utm_term=Java%E9%9B%86%E5%90%88%E6%A1%86%E6%9E%B6&spm=1018.2226.3001.4187"
author:
  - "[[吞吞吐吐大魔王]]"
published: 2021-10-14
created: 2026-10-13
description: "文章浏览阅读2.1k次，点赞60次，收藏43次。本文详细介绍了Java集合框架，包括Collection、List、Queue、Deque、Set、Map等接口及其实现类，如ArrayList、LinkedList、HashMap等。阐述了Iterable接口、Iterator迭代器以及它们的使用方法，同时提供了实例代码展示Collection和Map的操作。通过对集合框架的理解，有助于更好地管理和操作数据结构。"
tags:
  - "clippings"
---
**前言：** 本文主要介绍了 Java 集合框架，让大家对它有个概念的认识。为后面介绍数据结构以及集合框架中具体的实现 类 来做铺垫。希望大家喜欢！

## 1\. 介绍（含集合框架图）

**什么是 Java 的集合框架呢？**

> Java 集合框架 `Java Collection Framework` ，又被称作容器 `container` ，是定义在 `java.util` 包下的一组 **接口** 和其 **实现类** （使用时需要导包）
> 
> 它主要表现为将多个元素置于一个单元，用于对这些元素进行快速、便捷的存储、检索、管理，即平时我们俗称的增删改查

为了便于理解，个人制作了一个集合框架的图片，并注明了一些注释 ![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/f345dc634bb7b222a5b9ad69796c0e6a.png#pic_center)

> - 配合这个图我们可以看到集合框架其实就是一些接口和具体要实现的类。而这些具体要实现的类就是我们数据结构中要学习的那些链表、队列、数、哈希表等等，不过 Java 底层已经实现了一些数据结构并封装了起来。
> - 并且我们从图中可以看到，Java 集合框架主要包括两种类型的容器，一种是集合（Collection），存储一类元素的集合；另一种是图（Map），存储键/值对映射。而箭头则代表着 **继承** 的关系。

现在相信大家应该明白了，集合框架就是一个用来代表和操纵集合的统一 架构 。它就是由一些接口、实现类、和具体的算法实现的。

## 2\. 各个接口概述

对于上述框架图中的一些接口，我在这简单概述一下，后期会进行深入介绍。

| 接口 | 描述 |
| --- | --- |
| `Collection` 接口 | Collection 是最基本的集合接口，一个 Collection 代表一组 Object，即 Collection 的元素，Java 不提供直接继承自 Collection 的类，只提供继承于的子接口(如 List 和 set )。Collection 接口存储一组不唯一，无序的对象。 |
| `List` 接口 | List 接口是一个有序的 Collection，使用此接口能够精确的控制每个元素插入的位置，能够通过索引（元素在 List 中位置，类似于数组的下标）来访问 List 中的元素，第一个元素的索引为 0，而且允许有相同的元素。List 接口存储一组不唯一，有序（插入顺序）的对象。 |
| `Queue` 接口 | Queue 接口继承自 Collection 接口，是 Java 中定义的一种队列数据结构，元素是有序的（按插入顺序排序），先进先出（FIFO）原则。不支持随机访问数据，新元素插入（offer）到队列的尾部，访问元素（poll）操作会返回队列头部的元素。通常，队列不允许随机访问队列中的元素。 |
| `Deque` 接口 | Deque 接口是 Queue 接口的子接口，创建了双端队列结构，灵活性更强，可以前向或后向迭代，在队头队尾均可插入或删除元素的线性集合。Deque 接口支持容量固定的双端队列，也支持容量不固定的双端队列，一般情况下，双端队列的容量是不固定的。 |
| `Set` 接口 | Set 具有与 Collection 完全一样的接口，只是行为上不同，Set 不保存重复的元素。Set 接口存储一组唯一，无序的对象。 |
| `SortedSet` 接口 | 继承于Set保存有序的集合。 |
| `Map` 接口 | Map 接口存储一组键值对象，提供key（键）到value（值）的映射。 |
| `SortedMap` 接口 | 继承于 Map，使 Key 保持在升序排列。 |

## 3\. 各个实现类概述

对于上述框架图中的一些实现类，我在这简单概述一下，后期会进行深入介绍。

| 类名 | 描述 |
| --- | --- |
| `LinkedList` | 该类实现了 List 接口，允许有 null（空）元素。主要用于创建链表数据结构，该类没有同步方法，如果多个线程同时访问一个 List，则必须自己实现访问同步，解决方法就是在创建 List 时候构造一个同步的 List。 |
| `ArrayList` | 该类也是实现了 List 的接口，实现了可变大小的数组，随机访问和遍历元素时，提供更好的性能。该类也是非同步的，在多线程的情况下不要使用。ArrayList 增长当前长度的50%，插入删除效率低。 |
| `Vector` | 该类和 ArrayList 非常相似，但是该类是同步的，可以用在多线程的情况，该类允许设置默认的增长长度，默认扩容方式为原来的2倍。 |
| `Stack` | 栈是 Vector 的一个子类，它实现了一个标准的后进先出的栈。 |
| `PriorityQueue` | PriorityQueue 是 AbstractQueue 的子类，AbstractQueue 又实现了 Queue 接口，所以 PriorityQueue 具有 Queue 接口的优先队列。优先队列与普通队列不同，普通队列遵循“FIFO”的特性，获取元素时根据元素的插入顺序获取，优先队列获取元素时根据元素的优先级，获取优先级最高的数据。 |
| `TreeSet` | 该类实现了 Set 接口，可以实现排序等功能。 |
| `HashSet` | 该类实现了 Set 接口，不允许出现重复元素，不保证集合中元素的顺序，允许包含值为 null 的元素，但最多只能一个。 |
| `HashMap` | HashMap 是一个散列表，它存储的内容是键值对（key-value）映射。该类实现了Map 接口，根据键的 HashCode 值存储数据，具有很快的访问速度，最多允许一条记录的键为 null，不支持线程同步。 |
| `TreeMap` | 继承了 AbstractMap，并且使用一颗树。 |

## 4\. Iterable

### 4.1 介绍

在集合框架的体系图中，我们还有一点没有介绍到，就是最上面的，被 Collection 继承的 Iterable 接口。这就相当于所有的集合类都实现了 Iterable 接口。那么这个接口能干什么呢？

> Iterable 由英文翻译就是 **可迭代** 的意思。 当我们实现了这个接口时，我们就能称这个类是一个”可数“类，也就是可以使用 Iterator 迭代器

### 4.2 Iterator 和 ListIterator 迭代器

什么是迭代器呢？

> 迭代器是确使用户可在容器对象（container，如链表或数组）上遍历的对象，设计人员使用此接口无需关心容器对象的内存分配的实现细节。
> 
> 一般遍历数组都是采用 for 循环或者 for-each，这两个方法也可以用在集合框架上，但是还有一种方法是采用迭代器的方式遍历集合框架，它是一个对象，实现了 `Iterator` 接口和 `ListIterator` 接口。使用了迭代器，能够通过循环来得到或删除集合的元素。
> 
> `ListIterator` 继承了 `Iterator` ，以允许双向遍历列表和修改元素

### 4.3 迭代器的简单用法

迭代器 it 的两个基本操作是 next、hasNext 和 remove

> - 调用 `it.next()` 会返回迭代器的下一个元素，并且更新迭代器的状态
> - 调用 `it.hasNext()` 用于检测集合中是否还有元素
> - 调用 `it.remove()` 将迭代器返回的元素删除

知道迭代器的基操后，我们从获取迭代器开始学会简单使用它

我们先创建一个集合，并添加几个元素，创建集合的方式下文会介绍。

```java
ArrayList<String> arrayList = new ArrayList<>();
arrayList.add("Jack");
arrayList.add("Tom");
arrayList.add("Helon");
java运行1234
```

**获取一个迭代器：**

```java
Iterator<String> it = arrayList.iterator();
java运行1
```

**输出集合中的第一个元素：**

```java
System.out.println(it.next());
// 结果为：Jack
java运行12
```

**循环集合元素：**

```java
while(it.hasNext()){
    System.out.println(it.next());
}
java运行123
```
运行结果：

变量it未声明，缺少迭代器对象的初始化，且该代码片段缺少类定义、方法定义及必要的导入语句，无法独立编译运行

**删除元素：**

```java
ArrayList<Integer> arrayList = new ArrayList<>();
arrayList.add(1);
arrayList.add(3);
arrayList.add(5);
Iterator<Integer> it = arrayList.iterator();
while(it.hasNext()){
    Integer i = it.next();
    if(i<3){
        it.remove();
    }
}
System.out.println(arrayList);
// 结果为：[3,5]
java运行12345678910111213
```
运行结果：

\[3, 5\]

**注意：**

> Iterator 类位于 java.util 包中，使用前需要导包： `import java.util.Iterator`

## 5\. Collection

### 5.1 介绍

> Collection 是最基本的集合接口，一个 Collection 代表一组 Object，即 Collection 的元素，Java 不提供直接继承自 Collection 的类，只提供继承于的子接口（如 List 和 set )。
> 
> Collection 接口存储一组不唯一，无序的对象。

### 5.2 Collection 接口说明

如果想知道 Collection 接口具体的说明，可以直接百度，也可以点击 [Collection 官方文档](https://docs.oracle.com/javase/8/docs/api/java/util/Collection.html)

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/e23ecf4db82002d1d5f77edb831c1577.jpeg#pic_center)

### 5.3 Collection 常用方法说明

| 方法 | 说明 |
| --- | --- |
| `boolean add(E e)` | 将元素 e 放入集合中 |
| `void clear()` | 删除集合中的所有元素 |
| `boolean isEmpty()` | 判断集合是否没有任何元素，即空集合 |
| `boolean remove(Object e)` | 如果元素 e 出现在集合中，删除其中一个 |
| `int size()` | 返回集合中的元素个数 |
| `Object[] toArray()` | 返回一个装有所有集合中元素的数组 |

### 5.4 Collection 示例

#### 5.4.1 使用 Collection 创建集合

如我们要创建一个元素是字符串类型的顺序表集合，就可以写成：

```java
Collection<String> collection1 = new ArrayList<>();
java运行1
```

如果我们要创建一个元素是整形的栈集合，就可以写成：

```java
Collection<Integer> collection2= new Stack<>();
java运行1
```

**注意：**

> - 一般不直接用 Collection，而是直接实用具体实现类来创建对象，如
> 	```java
> 	ArrayList<String> arrayList = new ArrayList<>();
> 	java运行1
> 	```
> - `<>` 中存放的是要存放内容类型的类类型，即包装类

#### 5.4.2 使用 Collection 内的方法

我们先创建一个集合

```java
Collection<String> collection = new ArrayList<>();
java运行1
```

对它进行增加元素

```java
collection.add("hello");
java运行1
```

返回集合中的元素

```java
System.out.println(collection.size());
java运行1
```

删除集合中的所有元素

```java
collection.clear();
java运行1
```

返回一个装有所有集合元素的 数组

```java
Object[] array = collection.toArray();
java运行1
```

**注意：**

> - Object 类型数组不能转换成其他类类型数组，如
> 	```java
> 	Object[] o = {1,2,3};
> 	Integer[] i = (Integer)o;
> 	java运行12
> 	```
> 	这样写是错误的。这是由于 Java 当中，数组不能整体进行转化。
> - Object 类型的元素可以单个转换成其他类型，如
> 	```java
> 	Object o = 1;
> 	Integer i = (Integet)o;
> 	java运行12
> 	```
> 	运行结果：
> 	编译错误：'Integet' 是拼写错误，应为 'Integer'；此外，基本类型 int 的装箱对象 Integer 不能直接用 (Integer) 强制转换 Object，虽然此处 o 实际是 Integer 类型，但语法错误优先导致编译失败
> 	这个代码是对的

## 6\. Map

### 6.1 介绍

> Map 接口存储一组键值对象，提供key（键）到value（值）的映射。

### 6.2 Map 接口说明

如果想知道 Map 接口具体的说明，可以直接百度，也可以点击 [Map 官方文档](https://docs.oracle.com/javase/8/docs/api/java/util/Map.html)

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/bd3757f050eee9518dcdc3e5c7deb86b.jpeg#pic_center)

### 6.3 Map 常用方法说明

| 方法 | 说明 |
| --- | --- |
| `V get(Object k)` | 根据指定的 k 查找对应的 v |
| `V getOrDefault(Object k, V defaultValue)` | 根据指定的 k 查找对应的 v，没有找到就用默认值代替 |
| `V put(K key, V value)` | 将指定的 k-v 放入 Map |
| `boolean containsKey(Object key)` | 判断是否包含 key |
| `boolean containsValue(Object value)` | 判断是否包含 value |
| `Set<Map.Entry<K, V>> entrySet()` | 将所有的键值对返回 |
| `boolean isEmpty()` | 判断是否为空 |
| `int size()` | 返回键值对的数量 |

### 6.4 Map 示例

#### 6.4.1 使用 Map 创建图

如我们要创建一个键是字符串类型、值也是字符串类型的哈希表集合，就可以写成：

```java
Map<String,String> map1 = new HashMap<>();
java运行1
```

如我们要创建一个键是整形类型、值是字符串类型的哈希表集合，就可以写成：

```java
Map<Integer,String> map2 = new HashMap<>();
java运行1
```

#### 6.4.2 使用 Map 内的方法

我们先创建一个图：

```java
Map<String,String> map = new HashMap<>();
java运行1
```

将指定的 k-v 放入

```java
map.put("点赞","感谢");
map.put("关注","超感谢");
map.put("收藏","十分感谢");
java运行123
```

根据指定的 k 查找对应的 v

```java
String v = map.get("收藏");
java运行1
```

根据指定的 k 查找对应的 v，没有找到就用默认值代替

```java
String v = map.getOrDefault("三连","超级无敌感谢");
java运行1
```

> 如果 map 中没有"三连"这个键，将会用默认值"超级无敌感谢"来代替

将所有的键值对返回

```java
Set<Map.Entry<String, String>> entrySet=map.entrySet();
java运行1
```

> `Set<Map.Entry<K, V>>` 这个类型的意思就在 Set 集合里面每个元素是 `Map.Enrty<K, V>` 类型。
> 
> 我们可以通过 for-each 循环遍历一下 entrySet 集合中的元素
> 
> ```java
> for(Map.Entry<String,String> entry: entrySet){
>     System.out.println("key: "+entry.getKey()+" value: "+entry.getValue());
> }
> java运行123
> ```

**注意：**

> - Map 中存储的数据是无序的，如我们将上述 put 的代码输出 map 结果为 ![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/e955b2013f7ceea857e8bbc63ac868f3.png#pic_center)
> 	但是使用 put 存放元素的时候是有一个规则的，这个将在后面章节介绍
> - Map 中，key 可以重复，但是同一个 key 所对应的值只有一个，为最后你更新这个 key 的值

## 7\. 总结

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/02eee5d6277a114afe02b6c007d1c5ba.jpeg#pic_center)

微信名片