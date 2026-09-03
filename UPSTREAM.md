# 上游版本锚点

| 项 | 值 |
|---|---|
| 上游项目 | https://github.com/AgriciDaniel/claude-obsidian |
| vendored 版本 | **v2.1.1**（plugin.json 与 CHANGELOG 一致） |
| 获取方式 | GitHub ZIP 下载解压（无 .git 历史） |
| vendored 位置 | `upstream/`（排除 `__pycache__`/`*.pyc` 运行时产物） |
| 完整性 | `upstream-manifest.sha256`（201 文件逐一 SHA-256，vendored 时生成） |
| 运行时来源 | 仓库 `upstream/` 即运行副本（单一真源，无独立部署副本） |

## 铁律

1. **永不直接修改 `upstream/` 内任何文件。** 所有适配放进 `port/`。
2. 上游更新 = 下载新版 ZIP → 与 `upstream/` diff → 整体替换 → 重新生成 manifest → 提交。
3. `upstream/` 同时是运行副本（kb.sh 直接调用它）；替换后跑 `port/wsl/kb.sh lint` 验证与现有 vault 兼容。
4. 发现上游 bug 优先向上游提 issue/PR（用单独的 fork），不在本仓库内分叉修复。

## 关注上游更新

- Releases 订阅：https://github.com/AgriciDaniel/claude-obsidian/releases.atom
- 重点关注接口面：`scripts/claude-obsidian.py` 的 CLI 子命令签名、`config/*.json` 的 schema、`skills/**/SKILL.md` 的规程变化。
