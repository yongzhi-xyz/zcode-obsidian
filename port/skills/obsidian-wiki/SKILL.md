---
name: obsidian-wiki
description: "Obsidian 知识库总编排：vault 状态诊断(doctor)、健康检查入口、按用户意图路由到对应技能。触发词：知识库、vault、wiki、obsidian、初始化知识库、vault 状态。"
---

# Obsidian 知识库编排

本地优先 AI 知识库（基于 claude-obsidian 引擎，WSL 运行）。vault = `~/vaults/kb`（WSL ext4 内）。
产品（引擎与规则）是代码，vault 是数据，二者永不混淆。

## 引擎调用（所有知识库技能共用）

```bash
# Windows shell 中经 WSL 桥调用（kb.sh 已默认选定 vault）
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh <子命令> [参数...]
```

- 常用：`doctor`（诊断）、`lint`（体检）、`transaction inspect/apply`（事务）、`checkpoint`（git 存档点）
- vault 文件读取：Read 工具直接开 `\\wsl.localhost\<distro>\home\<user>\vaults\kb\...`（安装器已替换实际值），或 `wsl -d Ubuntu -- cat ~/vaults/kb/<path>`
- bundle 草稿：用 Write 工具写到 Windows 工作区，引擎侧以 `/mnt/c/<对应路径>` 引用
- 检索栈：`contextual-prefix.py` / `bm25-index.py` / `retrieve.py` 均在 `~/repos/zcode-obsidian/upstream/scripts/`，一律加 `--no-llm`（本地合成前缀，零外发）

## 意图路由（不改写用户意图，不静默扩大范围）

| 用户意图 | 用哪个技能 |
|---|---|
| 摄入材料（文件/粘贴文本/URL） | `obsidian-ingest` |
| 保存本次对话的结论/决策 | `obsidian-save` |
| 基于知识库问答 | `obsidian-query`（严格只读） |
| 知识库体检（死链/孤儿/台账） | `obsidian-lint`（只报不修） |
| 更新检索索引 | 本技能"检索维护"节 |

## 体检与诊断

```bash
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh doctor
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh lint
```

lint 只读：报告死链、孤儿页、frontmatter 缺失、台账违规、过期索引项。修复永远是一个单独审查的事务，绝不自动修。

## 检索维护（大批量写入后建议执行）

```bash
wsl -d Ubuntu -- python3 ~/repos/zcode-obsidian/upstream/scripts/contextual-prefix.py --vault ~/vaults/kb --all --no-llm
wsl -d Ubuntu -- python3 ~/repos/zcode-obsidian/upstream/scripts/bm25-index.py --vault ~/vaults/kb build
wsl -d Ubuntu -- python3 ~/repos/zcode-obsidian/upstream/scripts/retrieve.py --vault ~/vaults/kb "冒烟查询" --top 3 --no-rerank
```

## 变更铁律（所有写入类技能必须遵守）

1. 一切 vault 变更走**一个**事务：构建 `claude-obsidian.transaction.v1` bundle → `transaction inspect` → 展示预览给用户 → 用户确认 → 带 `approval_sha256` apply。
2. 禁止用 Write/Edit 工具直接改 vault 内文件；禁止绕过事务的任何写路径。
3. 笔记结构为 generic 模式：sources/concepts/entities/questions/sessions；标签只做状态粗筛，主题靠 [[双向链接]]。
4. apply 冲突（exit 75）= vault 已被其他操作改变：重读、重建 bundle、重新 inspect，绝不硬闯。
5. 中断恢复：`transaction recover`。
6. 深层规则（耦合写入清单、溯源台账、操作类型权限）见仓库
   `~/repos/zcode-obsidian/upstream/skills/wiki/references/operation-transactions.md` 与 `provenance.md`，做复杂操作前必读对应参考。
