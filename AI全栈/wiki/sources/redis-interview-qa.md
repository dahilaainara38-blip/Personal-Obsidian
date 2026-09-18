---
title: 素材摘要 · Redis 常见面试题（小林coding，机翻稿）
type: source
domain: data
tags: [redis, interview]
status: growing
confidence: low
source_count: 1
created: 2026-09-18
updated: 2026-09-18
---

# 素材摘要 · Redis 常见面试题（小林coding）

> 一句话：40+ 题的八股汇编，**机翻质量差**，只当索引用；增量价值在线程模型、过期键与持久化交互、缓存更新三策略、大 key 治理四处。

- 来源：https://www.xiaolincoding.com/redis/base/redis_interview.html · 收录 2026-09-18
- 原始素材：`raw/redis-interview-qa.md`
- **⚠️ 素材质量警告：机翻稿，存在系统性错译**——"分布式锁"译作"全球锁"、"有序集合"译作"群体集合"、"过期时间"译作"过渡时间"、"缓存"译作"服务器"、"回滚"语境混乱等。**与单篇专题文冲突时一律以单篇为准**（例：本篇称 noeviction"不再提供服务"，单篇明确指出读/删操作仍正常，仅写入报错——后者正确）。

## 增量价值（单篇未覆盖的部分）

1. **线程模型澄清**："单线程"指网络 IO + 命令执行；进程本身有后台线程 BIO（2.6 起：关闭文件、AOF 刷盘；4.0 起：lazy free 异步释放内存——删大 key 用 unlink 的原理）。6.0 起网络 IO 多线程（默认只多线程**写**响应，`io-threads` N 表示共 N 个 IO 线程，建议 4 核设 2-3、8 核设 6），**命令执行仍单线程**。
2. **Redis vs Memcached**：数据类型丰富度、持久化、原生集群、Lua/事务/发布订阅。
3. **过期键与持久化/复制的交互**：RDB 生成时过期的键不写入；主节点载入 RDB 跳过过期键、**从节点全量载入**（反正同步时会清）；AOF 中过期删除追加显式 DEL；从库不做过期扫描，靠主库同步 DEL 命令。
4. **缓存更新三策略**：Cache Aside（应用维护，Redis 场景唯一可用）/ Read-Write Through（缓存组件代理 DB，Redis 不支持）/ Write Back（只写缓存异步刷库，CPU cache/文件系统用，掉电丢数据）。
5. **大 key 定义与治理**：String >10KB 或集合元素 >5000 判为大 key；查找三法（`--bigkeys` 在**从节点**跑、SCAN + `MEMORY USAGE`、RdbTools 离线解析 RDB）；删除：hscan+hdel / ltrim / sscan+srem / zremrangebyrank 分批，或 unlink 异步（4.0+，配合 `lazyfree-lazy-*` 系列配置自动异步）。
6. **事务无回滚**：入队阶段错误 → 全部拒绝；EXEC 后运行时错误 → **正确命令照样执行**（不回滚、不保证原子性）；DISCARD 只是主动放弃。官方理由：编程错误不该在生产出现 + 保持简单高效。
7. 延迟队列：Zset，score 存执行时间戳，轮询 `zrangebyscore` 到期任务。

## 支撑的 wiki 页面

- [[redis]]、[[redis-persistence]]、[[cache-coherence]]、[[distributed-lock]]（以上结论已并入对应页面，引用时以单篇原文优先）
