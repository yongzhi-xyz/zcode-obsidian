# zcode-obsidian

> **TL;DR (English):** A local-first AI knowledge base that ports [AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) (v2.1.1) to the ZCode agent host on Windows. Every AI write to your Obsidian vault goes through a reviewable, rollback-safe transaction; ingested material keeps a provenance ledger (every claim traces back to its source); retrieval is local BM25 with CJK n-grams (no data leaves your machine). The vendored upstream engine is kept byte-identical; all adaptation lives in `port/`. Docs are in Chinese: see the [user guide](docs/USER-GUIDE.zh.md).

Zcode 的 Obsidian AI 知识库插件 —— 基于 [AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) v2.1.1 的移植（路线 A：完整保留上游事务引擎，仅适配宿主层）。

## 这是什么

本地优先的 AI 个人知识库：AI 像图书管理员一样维护一个 Obsidian vault——

- **事务写入**：AI 对知识库的每次修改都是可预览、可审批、可回滚的事务（inspect → 哈希审批 → apply），绝不裸写文件
- **溯源台账**：素材摄入生成断言级台账，每条论断可追到原始来源；无支撑断言显式标注 provisional
- **本地检索**：BM25 + CJK n-gram（中文免分词），上下文前缀本地合成（`--no-llm`），**零数据外发**
- **git 存档点**：每笔知识操作可落成精确对应的本地提交，历史可审计

上游为 Claude Code 插件；本项目将其适配到 Zcode，核心引擎（`upstream/`）原样保留，不做任何代码改动。

## 环境要求

- Windows 10/11 + WSL2（Ubuntu 22.04+，WSL 内 Python ≥3.11）
- [ZCode](https://www.z.ai/) 客户端（技能安装到用户级 `~/.zcode/skills/`）
- [Obsidian](https://obsidian.org/)（可视化浏览；vault 必须位于 WSL ext4 内，Windows 原生版打开会因 9p 文件监视器崩溃，请用 WSLg 的 Linux 版）
- vault 必须位于 WSL 文件系统内（ext4）；放 `/mnt/*`（NTFS 挂载）会因权限位缺失触发 `RESULT_DRIFT` 回滚

## 快速开始

```powershell
# 1. 克隆(任意位置;示例放 WSL 内保持路径简单)
wsl -d Ubuntu -- git clone https://github.com/yongzhi-xyz/zcode-obsidian.git ~/repos/zcode-obsidian

# 2. 安装 15 个 Zcode 技能(自动探测 WSL 发行版/用户名,替换技能内路径占位符)
powershell -ExecutionPolicy Bypass -File "\\wsl.localhost\Ubuntu\home\<user>\repos\zcode-obsidian\port\skills\install.ps1"

# 3. 综合诊断
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh doctor
```

然后用上游 CLI 初始化你的 vault（两步:先出计划、复制 `approved_plan_sha256` 再应用）,把 vault 目录在 Obsidian(Linux 版)中打开,重开一个 Zcode 会话即可使用。完整教程见 **[docs/USER-GUIDE.zh.md](docs/USER-GUIDE.zh.md)**。

## 仓库结构

```
├── upstream/                  # vendored 上游 claude-obsidian v2.1.1(逐字节原样,永不直接修改)
│   ├── claude_obsidian/       #   事务引擎核心(Python,纯标准库)
│   ├── scripts/               #   CLI 入口 + 检索栈(contextual-prefix/BM25/rerank)
│   └── skills/                #   15 个技能(工作流规程,宿主无关的 Markdown)
├── upstream-manifest.sha256   # 上游完整性清单(201 文件)
├── port/                      # 移植层(本项目自有代码)
│   ├── wsl/                   #   Windows↔WSL 桥接脚本
│   └── skills/                #   Zcode 技能适配 + 参数化安装器
├── UPSTREAM.md                # 上游版本锚点与更新流程
└── docs/USER-GUIDE.zh.md      # 完整使用与维护手册
```

## 安全与隐私

- 本地优先：引擎只读写你指定的 vault 目录；检索索引为本地派生态；无遥测、无云依赖
- 网络默认关闭：联网操作（URL 抓取、上游 LLM 检索前缀）均为显式 opt-in 且技能规程要求先征得同意
- 详见 [SECURITY.md](SECURITY.md)

## 贡献

欢迎 issue / PR。唯一硬规则:`upstream/` 逐字节 vendored 永不修改,一切适配进 `port/`。见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 免责声明

本工具由 AI 辅助移植,按"现状"提供。它会写你的文件(虽经事务保护)——**重要 vault 请自行做好备份**;对任何数据损失不承担责任。

## 许可与致谢

- 本仓库 port/ 层以 MIT 许可发布；upstream/ 保留原作者 AgriciDaniel 的 MIT 许可（见 upstream/LICENSE）。
- 向上游项目 [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) 及其事务模型设计致敬。
