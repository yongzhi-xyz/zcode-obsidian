---
name: obsidian-defuddle
description: "规划并（经明确网络同意后）用可选的外部 Defuddle 清洗器把 HTTPS 文章页提取为 Markdown，为后续摄入做准备。清洗、原始抓取、入库是三个独立操作。触发词：defuddle、清洗这个 URL、提取正文、网页转 markdown。"
---

# Defuddle 网页清洗

Defuddle 是可选外部提取器，不是内建能力。清洗、原始抓取、wiki 摄入是三个分离的操作。

## 安全契约

- 远程输入只收 HTTPS URL；拒绝 URL 内凭证、fragment、私有/本地 host、非公网 IP、控制字符、敏感查询参数。
- URL 绝不内插进 shell 字符串——作为单个 argv 元素传递。
- 重定向到不同 host 在该 host 被批准前一律拒绝。
- 明确告知 URL 与请求元数据将离开本机；网络访问需当前请求或单独确认中的明确同意。
- 不安装清洗器、不执行占位 runner、不静默切换其他抓取器。
- 不宣称固定降幅或提取质量——检查实际输出。

## 先规划（无网络调用）

```bash
wsl -d Ubuntu -- python3 ~/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py \
  capture external-plan url "HTTPS_URL"
```

报告规范化的 host、外发、重定向策略、外部依赖、execute: false。再查能力状态：

```bash
wsl -d Ubuntu -- python3 ~/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py \
  contracts --verify --capability defuddle --vault ~/vaults/kb
```

`available` = 未找到可执行文件：到惰性计划为止。`configured` = 发现可执行文件但无行为验证器：展示状态与路径，要求人工审查其来源/版本/确切 argv 后才可执行；**绝不把 configured 改标为 verified**。

不可用或人工审查被拒时的诚实降级：让用户安装/配置外部 runner、接受本地 HTML/Markdown 进 `inbox/`、或保留 URL 待处理。不声称已清洗/抓取/摄入。

## 同意后执行

argv 等价于 `defuddle parse HTTPS_URL --md`。在共享 vault 状态外的临时草稿中捕获有界 stdout；非零退出、空输出、意外二进制、未批准重定向、明显鉴权/错误页 → fail closed。保留标题、链接、代码围栏、表格、引文与原文措辞。

## 可选原始抓取（capture 事务）

用户要求保留清洗结果时：算清洗字节的 SHA-256 → 起草 create-only 的 `.raw/captured/<sha256>.md`（同字节已存在则 no-op，绝不覆盖）→ 一个 `operation_type: capture` 的事务（inspect → 确认 → apply）。

**本技能不建 wiki 页、不更新索引、不评级断言**；要纳入知识库时作为独立操作走 obsidian-ingest。
