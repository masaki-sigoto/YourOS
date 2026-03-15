#!/bin/bash
# block-ai-write.sh — PreToolUse hook for Claude Code
# Blocks Write/Edit operations targeting AI-blocked/ or Private/ paths.
#
# Input: JSON on stdin with { tool_name, tool_input } from Claude Code hook system
# Output: JSON with hookSpecificOutput structure per Claude Code protocol

# Read the hook input from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
inp = data.get('tool_input', {})
print(inp.get('file_path', ''))
" 2>/dev/null)

# Check if the path targets blocked directories
if echo "$FILE_PATH" | grep -qE '(^|/)AI-blocked(/|$)|(^|/)Private(/|$)'; then
  cat <<'DENY'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Writing to AI-blocked/ or Private/ is prohibited by YourOS security policy."
  }
}
DENY
  exit 0
fi

# Allow all other paths
exit 0
