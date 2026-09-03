---
name: obsidian-cli
description: "检测并用官方 Obsidian 命令行接口做只读 vault 访问（读笔记/搜索/反向链接）；一切变更仍走事务核心。本机知识库运行在 WSL 内的 Linux 版 Obsidian 上。触发词：Obsidian CLI、obsidian read、obsidian search、传输层、transport、backlinks 查询。"
---

# Obsidian CLI 只读通道

只用本技能做传输层检测与只读读取/搜索。官方可执行文件为 `obsidian`；二进制存在不等于可用。

**本机环境说明**：知识库 vault 在 WSL ext4 内，可视化用 Linux 版 Obsidian（WSLg 窗口）。CLI 探测在 WSL 内执行。

## 检测

```bash
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh doctor   # 综合诊断
# 官方 CLI 探针(Linux 版 Obsidian 运行中时):
wsl -d Ubuntu -- obsidian --help
```

信任 `usable` 状态而非"存在"或退出码：应用没开、命令行访问被禁、返回错误都意味着不可用。文件系统直读是可移植兜底（`Read` 工具开 `\\wsl.localhost\<distro>\home\<user>\vaults\kb\...`，安装器已替换实际值，或 `wsl cat`）。

## 读取与搜索

CLI 可用时，在 vault 目录内运行以正确解析工作区：

```bash
wsl -d Ubuntu -- bash -c "cd ~/vaults/kb && obsidian read path=wiki/index.md"
wsl -d Ubuntu -- bash -c "cd ~/vaults/kb && obsidian search query=关键词"
```

拒绝绝对笔记参数、路径穿越、symlink、解析到 vault 外的路径。

## 变更边界

**绝不**使用 CLI 的 create/write/append/property-set/move/rename/delete；也不用文件系统直写替代。一切知识或配置变更必须表达为经 WSL 桥的审查事务。传输层选择不改变变更语义：CLI 是可选读面，不是锁管理器、事务引擎或 git checkpoint 机制。
