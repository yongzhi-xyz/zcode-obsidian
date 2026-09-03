---
name: obsidian-lint
description: "对知识库跑确定性只读体检：死链、孤儿页、frontmatter 缺失、空小节、台账违规、过期索引。只报告不修复；修复是单独审查的事务。触发词：体检、检查知识库、lint、vault 健康度、查死链、查孤儿页。"
---

# 知识库体检（只读）

以可移植 lint 引擎为唯一事实来源；lint 观察状态，不生成报告文件、不建看板、不修文件。

```bash
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh lint
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh lint --format markdown
```

引擎理解 Obsidian 双链与嵌入、Markdown 链接、别名、标题/块片段、代码围栏；报告死链/歧义链接、孤儿页、frontmatter 缺失（含 title）、空小节、过期索引项、来源/断言台账契约违规。**只报告引擎输出中实际存在的检查与计数**，不声称做过语义或文风层面的矛盾分析。

## 解读发现

1. 保留引擎给出的路径、行号、目标、类别、计数。
2. 按影响分组：导航损坏 → 歧义解析 → 元数据质量 → 可维护性。
3. 孤儿页可能是有意的；歧义 basename 需路径限定链接——不从发现本身推断意图。
4. 严格区分"确定性事实"与"建议的修复方式"。
5. Markdown 渲染结果在对话中返回，**不写入 vault**。

## 修复是独立操作（绝不自动修）

用户选定要修的条目后：

1. 重读每个目标并记录现 SHA-256；
2. 只起草选定的变更；删除/合并页面需明确同意；
3. 构建新 operation_id 的修复 bundle（`operation_type: save`，范围限 wiki/）；
4. inspect → 展示确切变更路径 → 单独审查后 apply；
5. 重跑 lint 只读对比相关发现。

git checkpoint 仅在用户明确要求时执行（经 kb.sh checkpoint <OPERATION_ID>）。
