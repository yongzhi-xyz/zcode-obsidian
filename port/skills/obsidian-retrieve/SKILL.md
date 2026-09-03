---
name: obsidian-retrieve
description: "构建与查询知识库的本地上下文 BM25 检索索引，可选 Ollama 余弦重排。派生缓存都在 .vault-meta 下，远程外发需明确同意，重排不可用时确定性降级。触发词：建索引、更新索引、检索索引、retrieval、BM25、混合检索、chunk 搜索。"
---

# 检索索引维护

本技能从 `wiki/` 派生检索数据到 `.vault-meta/`，绝不改规范笔记。本项目固定 `--no-llm`（本地合成前缀，零外发）；Ollama 重排默认仅 localhost。

## 管线

1. `contextual-prefix.py` 按段落切块 + 页面级语境前缀（Anthropic Contextual Retrieval 的本地实现）
2. `bm25-index.py` 建纯标准库 BM25 索引（CJK 1/2/3-gram，中文免分词）
3. `retrieve.py` 查询：BM25 候选 → 逐候哈希校验新鲜度 → 可选重排 → 按页去重 → 返回路径与片段

## 构建与查询

```bash
S=~/repos/zcode-obsidian/upstream/scripts
wsl -d Ubuntu -- python3 $S/contextual-prefix.py --vault ~/vaults/kb --all --no-llm
wsl -d Ubuntu -- python3 $S/bm25-index.py --vault ~/vaults/kb build
wsl -d Ubuntu -- python3 $S/retrieve.py --vault ~/vaults/kb "查询词" --top 5 --no-rerank --explain
# 诊断:
wsl -d Ubuntu -- python3 $S/bm25-index.py --vault ~/vaults/kb stats
```

## 完整性规则

- chunk 与页面路径必须相对且解析后仍在 `.vault-meta/chunks/` 与 `wiki/` 内。
- 拒绝绝对路径、symlink 逃逸、缺页、哈希不匹配、陈旧索引/chunk 对。
- 空索引是诚实的无结果态；索引缺失/损坏 exit 10，给出重建命令，调用方降级为目录导航+文本搜索，**不伪造匹配**。
- prefix/BM25 构建与其他写者共享全库变更锁；忙则 fail closed，不发布半套索引。
- 增量：chunk 与页面哈希未变的记录跳过；整页删除时清除 surplus 记录；改 chunk 集前先失效 BM25 索引。
- 大批量写入后建议跑一次本技能（知识内容不变时索引是可丢弃派生态）。
