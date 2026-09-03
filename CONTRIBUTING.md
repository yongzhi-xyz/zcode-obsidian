# 贡献指南

感谢关注!欢迎 issue、讨论与 PR(中文请随意)。

## 唯一硬规则

**`upstream/` 逐字节 vendored,永不直接修改。** 一切适配、修复、增强进 `port/`。

上游有 bug?两种正道:在 `port/` 做桥接规避(注明缘由),或去上游 [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) 修复后我们跟随升级。`upstream-manifest.sha256` 是完整性的裁判,任何触碰 `upstream/` 的 PR 会被关闭。

## PR 流程

1. fork → feature 分支(`feat-xxx` / `fix-xxx`)
2. 改动集中在最小范围;脚本遵守既有约定(WSL 侧 bash;Windows 侧 PowerShell 脚本 **ASCII only**,PS 5.1 无 BOM 会按 ANSI 解析)
3. 提交信息一句话说清"改了什么、为什么"(中英皆可)
4. 描述里附验证方式(dry-run 输出/lint 结果等)

## issue

- bug 请附:ZCode 版本、WSL 发行版、`kb.sh doctor` 输出(记得抹掉个人路径)
- 功能建议请说明使用场景,而不是只给方案

## 文档

`docs/USER-GUIDE.zh.md` 是唯一手册真源,库内镜像由维护者随事务同步,不需要贡献者管。
