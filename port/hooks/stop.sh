#!/bin/bash
# zcode-obsidian Stop hook 包装:调用上游引擎的会话收尾状态检查(悬空事务/未完成操作提醒)。
# 干净状态引擎无输出;有任何输出即原样透传给用户。任何失败静默,绝不阻塞会话结束。
set +e
export CLAUDE_OBSIDIAN_VAULT="${CLAUDE_OBSIDIAN_VAULT:-$HOME/vaults/kb}"
python3 "$HOME/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py" hook stop 2>/dev/null
exit 0
