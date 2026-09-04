@echo off
rem zcode-obsidian Windows 桥接:经 WSL 调用上游核心 CLI
rem 注意: 含空格参数请加引号;复杂操作建议直接进 WSL
wsl -d Ubuntu -- bash -c "CLAUDE_OBSIDIAN_VAULT=$HOME/vaults/kb python3 $HOME/repos/zcode-obsidian/upstream/scripts/claude-obsidian.py %*"
