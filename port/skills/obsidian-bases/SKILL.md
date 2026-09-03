---
name: obsidian-bases
description: "解释、起草、校验 Obsidian Bases .base 文件：filters、formulas、properties、summaries 与 table/cards/list 视图。触发词：Bases、数据库视图、动态表格、阅读清单、任务追踪、.base 文件。"
---

# Obsidian Bases

`.base` 文件是 YAML。本技能作设计参考与校验器；设计/语法问题只读回答；用户要求编辑 `.base` 时走一个经 WSL 桥的审查事务（限 `wiki/` 下），**绝不直写**。

## 工作流

1. 检视代表性笔记属性与既有 `.base`。
2. 定义能选中目标笔记的最小 filter。
3. 只为必须计算的值加 formula。
4. 选视图与列序；不假设用户 Obsidian 版本支持某视图或选项。
5. 校验 YAML、表达式引号、属性名、formula 引用、null 处理。
6. 变更前预览完整文件与预期结果集。
7. 应用后请用户在 Obsidian 中渲染确认应用层行为（本地无法验证的部分如实说明）。

## 紧凑 schema

```yaml
filters:
  and:
    - file.inFolder("wiki")
    - 'status != "archived"'
formulas:
  age_days: '((now() - file.ctime) / 86400000).round(0)'
properties:
  status:
    displayName: "状态"
views:
  - type: table
    name: "知识页"
    order: [file.name, type, status, updated, formula.age_days]
```

全局 filters 作用于所有视图，视图可再定义自己的 filters；递归 filter 对象每层恰用 and/or/not 之一。文件元数据用 `file.name/path/folder/ext/ctime/mtime/tags`，计算属性 `formula.<name>`，公式先定义后引用。

## 公式与 YAML 规则

- 含运算符/冒号/嵌套引号的表达式加引号。
- 可空属性用 `if()` 守卫。
- 日期相减得毫秒数，除以 86400000 再取整才是天数。
- **不要**把 Dataview 专有的 `from`/`where` 搬进 Base。
- 不发明所选笔记没有的属性（列会空）。

嵌入：`![[看板.base]]` 或 `![[看板.base#视图名]]`。视图常见 table/cards/list。应用后报告 operation_id、变更路径、已做校验与仍需渲染确认的项。不 commit git。
