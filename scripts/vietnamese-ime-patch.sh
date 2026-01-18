#!/bin/bash
# Claude Code Vietnamese IME Patch - Entry point
# Usage: claude-vn-patch [patch|restore|status]
# Requires: vietnamese-ime-patch-core.py

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/vietnamese-ime-patch-core.py"

if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "Error: Core script not found: $PYTHON_SCRIPT"
    exit 1
fi

# Find cli.js
find_cli_js() {
    local claude_path
    if command -v claude &>/dev/null; then
        claude_path=$(which claude)
        [[ -L "$claude_path" ]] && claude_path=$(readlink -f "$claude_path" 2>/dev/null || echo "")
        [[ -f "$claude_path" ]] && head -1 "$claude_path" | grep -q "node" && echo "$claude_path" && return 0
    fi

    for path in "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
                "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
                "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        [[ -f "$path" ]] && echo "$path" && return 0
    done
    return 1
}

CLI_JS=$(find_cli_js)
if [[ -z "$CLI_JS" ]]; then
    echo "Error: Could not find Claude Code cli.js"
    exit 1
fi

ACTION="${1:-patch}"
python3 "$PYTHON_SCRIPT" "$CLI_JS" "$ACTION"
