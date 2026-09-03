#!/bin/bash
# zcode-obsidian SessionStart hook 包装:
# 以显式同意(CLAUDE_OBSIDIAN_SESSION_CONTEXT=1)调用上游引擎的热上下文输出,
# 包成 Zcode hook JSON(additionalContext)注入会话;任何失败静默退出,绝不阻塞会话。
set +e
export CLAUDE_OBSIDIAN_VAULT="${CLAUDE_OBSIDIAN_VAULT:-$HOME/vaults/kb}"
TXT=$(CLAUDE_OBSIDIAN_SESSION_CONTEXT=1 python3 \
  "$HOME/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py" hook session-start 2>/dev/null)
if [ -n "$TXT" ]; then
  CTX="$TXT" python3 - <<'PYEOF'
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ["CTX"],
    }
}, ensure_ascii=False))
PYEOF
fi
exit 0
