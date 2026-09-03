#!/usr/bin/env bash
# zcode-obsidian WSL 桥接:任意位置调用上游核心 CLI,默认选定知识库 vault
# 用法: kb.sh <子命令> [参数...]
#   kb.sh doctor
#   kb.sh lint
#   kb.sh transaction inspect /tmp/bundle.json --vault ~/vaults/kb
set -e
export CLAUDE_OBSIDIAN_VAULT="${CLAUDE_OBSIDIAN_VAULT:-$HOME/vaults/kb}"
CORE="$HOME/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py"
exec python3 "$CORE" "$@"
