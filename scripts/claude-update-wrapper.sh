#!/bin/bash
# Wrapper script: Updates Claude Code and auto-patches Vietnamese IME
# Usage: claude-update

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find patch script - check both local dir and installed location
if [[ -f "$SCRIPT_DIR/vietnamese-ime-patch.sh" ]]; then
    PATCH_SCRIPT="$SCRIPT_DIR/vietnamese-ime-patch.sh"
elif [[ -f "$HOME/.claude/scripts/vietnamese-ime-patch.sh" ]]; then
    PATCH_SCRIPT="$HOME/.claude/scripts/vietnamese-ime-patch.sh"
else
    echo "Error: vietnamese-ime-patch.sh not found"
    exit 1
fi

echo "Updating Claude Code..."
npm update -g @anthropic-ai/claude-code

echo ""
echo "Applying Vietnamese IME patch..."
"$PATCH_SCRIPT" patch

echo ""
echo "Done! Claude Code updated and patched."
