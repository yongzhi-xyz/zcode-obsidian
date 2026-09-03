---
name: obsidian-mode
description: "读取或配置知识库的归档方法论模式(Generic/LYT/PARA/Zettelkasten)，并为计划中的新笔记建议归档路径。不保存内容、不迁移既有笔记。触发词：wiki mode、方法论模式、当前什么模式、切换 PARA、用 LYT、zettelkasten。"
---

# 归档方法论路由

本技能只返回归档建议，不写知识页、不移动笔记。`.vault-meta/mode.json` 缺失按 generic 处理；存在但损坏则 fail closed，先走审查过的 configuration 事务修复，绝不静默降级为 generic。

## 读取与路由（只读）

```bash
MODE=~/repos/zcode-obsidian/upstream/scripts/wiki-mode.py
wsl -d Ubuntu -- python3 $MODE --vault ~/vaults/kb get
wsl -d Ubuntu -- python3 $MODE --vault ~/vaults/kb route concept "概念名"
wsl -d Ubuntu -- python3 $MODE --vault ~/vaults/kb route source "来源标题"
```

helper 校验 vault、限定路径、清洗文件名，只打印建议。调用技能可用用户更具体的项目/MOC/父笔记覆盖建议，但最终写入仍走事务。

| 模式 | 路由 |
|---|---|
| generic（本项目默认） | sources/entities/concepts/questions/sessions 按类型分目录 |
| lyt | mocs/ + notes/（MOC 组织原子笔记） |
| para | projects/areas/resources/archives 按行动性 |
| zettelkasten | 扁平 wiki/<时间戳ID>-<slug>.md |

## 切换模式（configuration 事务，两段式）

模式值限定四选一；保留其他模式设置；`mode set` 是一个配置操作，先 dry-run：

```bash
CORE=~/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py
GEN=$(wsl -d Ubuntu -- date -u +%Y-%m-%dT%H:%M:%SZ)
wsl -d Ubuntu -- python3 $CORE mode set <MODE> --vault ~/vaults/kb --generated-at "$GEN" --operation-id mode-<日期>
# 审查预览后带 approved_plan_sha256 --apply
```

切换只影响未来操作的归档路由：**绝不**批量建目录、移动笔记、重写链接。迁移是独立审查的单独事务。
