---
name: obsidian-markdown
description: "解释、起草、校验 Obsidian 风味 Markdown 语法：属性、双链、嵌入、callout、标签、高亮、块引用、数学、Mermaid。用户明确要求 Obsidian 笔记格式或语法帮助时用，不用于一般 Markdown。触发词：Obsidian 语法、wikilink 怎么写、callout、frontmatter 属性。"
---

# Obsidian 风味 Markdown

本技能是语法参考与校验器。语法问题只读回答；用户要求写入 vault 时按事务契约起草完整笔记（`operation_type: markdown`，范围限 `wiki/`），inspect → 确认 → apply，**绝不直写**。

## 属性（frontmatter）

扁平 YAML、日期 `YYYY-MM-DD`、YAML 内双链加引号；不嵌套对象；用块列表不用内联数组；纯数字 tag 值加引号（`- "2026"`）保持字符串；不改与本次编辑无关的既有属性。

```yaml
---
type: concept
title: "Contextual Retrieval"
created: 2026-09-03
status: developing
tags:
  - retrieval
  - ai/knowledge
aliases:
  - 上下文检索
related:
  - "[[LLM Wiki 模式]]"
---
```

## 双链与嵌入

```markdown
[[笔记名]]  [[笔记名|显示文本]]  [[笔记名#标题]]  [[笔记名#^块id]]  [[文件夹/笔记名]]
本段可被块引用。 ^evidence-block
![[笔记名#小结]]  ![[图.png|480]]  ![[论文.pdf#page=3]]
```

目标文件名精确匹配；basename 歧义时用 vault 相对路径。外部 URL 用标准 Markdown 链接，vault 内笔记用双链。**描述性文字不要套双链**（死链来源，lint 会报）。

## Callout 与其他

```markdown
> [!note]/[!warning]/[!question] 标题
> [!warning] 评审要求
> 该断言存在矛盾证据。
```

`-` 收起 `+` 展开；常见类型：note/abstract/info/todo/tip/success/question/warning/failure/danger/bug/example/quote；自定义 callout 类型保留不重写。

`#tag #嵌套/tag`、`==高亮==`、`%%隐藏注释%%`、行内 `$...$` 与块级 `$$...$$`、mermaid 代码块均有效；避免 HTML。

## 起草校验清单

YAML 边界可解析且类型一致；本地可验证的链接/标题/块引用逐一核实（**绝不为凑完整编造目标**）；证据措辞与推断分开并保留定位符；代码围栏与 callout 引用配平；变更后跑 `obsidian-lint` 报告剩余发现而不静默修复。源引用页同时遵循溯源规则；apply 后报告 operation_id 与变更路径。
