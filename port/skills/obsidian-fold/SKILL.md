---
name: obsidian-fold
description: "对知识库操作日志(wiki/log.md)做有界、摘录式、结构幂等的滚动归总(fold)，默认 dry-run 预览，用户明确要求才落一个事务。不改子条目、不做 fold-of-fold、不自动触发。触发词：折叠日志、跑一次 fold、log rollup、归总日志。"
---

# 摘录式日志折叠

对 `wiki/log.md` 的原始条目做增量归总。绝不修改/移动/删除子条目或其页面；不做 fold-of-fold；绝不自动触发。本技能不需要网络。

## 选择有界范围

- 批量指数 k，规模 2^k 条，默认 k=4（16 条）；显式条目范围可覆盖。
- 条目数不足时如实报告缺口并停止，不折叠半批。
- 完整读取所选条目；子页面仅在日志上下文不足时读：目标 0-10，硬上限 15；缺失页面记显式 page_missing。

## 结构 ID（仅由输入决定）

```
fold-k{K}-from-{最早日期}-to-{最晚日期}-n{COUNT}
```

`wiki/folds/{ID}.md` 已存在 → 报告 no-op；替换需显式 force 请求 + 单独审查的 replace 提案。

## 摘录纪律

- 每个子条目在 frontmatter 有唯一 child_key，Child Entries 表恰有一行对应（双射）。
- 每个数字必须可在所选条目中核实；每个结论/主题必须点名来源条目；跨条目主题至少两条来源。
- 宁写 ambiguous in source / source missing，不发明。子页面与日志冲突时两者并陈，以日志为准。
- fold 不新增事实：不升级断言评级、不建来源记录；发现的矛盾留给后续审查。

## 事务（operation_type: fold，三件耦合）

`wiki/folds/{FOLD_ID}.md`（默认 create）+ `wiki/index.md` 的 fold 目录条目 + `wiki/log.md` 顶部新条目。**不更新 hot.md**。记录三个目标的 SHA-256 前置条件。

命令经 WSL 桥（inspect → 预览 ID/子范围/读取预算/变更路径 → 确认 → apply），同一 bundle 幂等；git checkpoint 仅应明确要求执行。
