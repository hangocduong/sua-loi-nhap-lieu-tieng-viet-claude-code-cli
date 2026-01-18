#!/bin/bash
# Claude Code Vietnamese IME Fix - Installer
# https://github.com/hangocduong/claude-code-vietnamese-fix

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/scripts"

echo "========================================"
echo "Claude Code Vietnamese IME Fix Installer"
echo "========================================"
echo ""

# Check Python
if ! command -v python3 &>/dev/null; then
    log_error "Python 3 is required but not installed"
    exit 1
fi
log_success "Python 3 found"

# Check Claude Code
if ! command -v claude &>/dev/null; then
    log_error "Claude Code not found. Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi
CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1)
log_success "Claude Code found: $CLAUDE_VERSION"

# Create target directory
mkdir -p "$TARGET_DIR"
log_info "Target directory: $TARGET_DIR"

# Copy scripts
log_info "Copying scripts..."
cp "$SCRIPT_DIR/scripts/vietnamese-ime-patch.sh" "$TARGET_DIR/"
cp "$SCRIPT_DIR/scripts/vietnamese-ime-patch-core.py" "$TARGET_DIR/"
cp "$SCRIPT_DIR/scripts/claude-update-wrapper.sh" "$TARGET_DIR/"

# Make executable
chmod +x "$TARGET_DIR/vietnamese-ime-patch.sh"
chmod +x "$TARGET_DIR/vietnamese-ime-patch-core.py"
chmod +x "$TARGET_DIR/claude-update-wrapper.sh"
log_success "Scripts installed"

# Detect shell config
SHELL_CONFIG=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_CONFIG="$HOME/.bash_profile"
fi

# Add aliases
if [[ -n "$SHELL_CONFIG" ]]; then
    ALIAS_LINE1='alias claude-vn-patch="$HOME/.claude/scripts/vietnamese-ime-patch.sh"'
    ALIAS_LINE2='alias claude-update="$HOME/.claude/scripts/claude-update-wrapper.sh"'

    if ! grep -q "claude-vn-patch" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Vietnamese IME fix for Claude Code" >> "$SHELL_CONFIG"
        echo "$ALIAS_LINE1" >> "$SHELL_CONFIG"
        echo "$ALIAS_LINE2" >> "$SHELL_CONFIG"
        log_success "Aliases added to $SHELL_CONFIG"
    else
        log_info "Aliases already exist in $SHELL_CONFIG"
    fi
else
    log_warn "Could not detect shell config. Add aliases manually:"
    echo '  alias claude-vn-patch="$HOME/.claude/scripts/vietnamese-ime-patch.sh"'
    echo '  alias claude-update="$HOME/.claude/scripts/claude-update-wrapper.sh"'
fi

# Apply patch
echo ""
log_info "Applying patch..."
"$TARGET_DIR/vietnamese-ime-patch.sh" patch

echo ""
echo "========================================"
log_success "Installation complete!"
echo "========================================"
echo ""
echo "Commands available (after restarting terminal or running 'source $SHELL_CONFIG'):"
echo "  claude-vn-patch        - Apply/check patch"
echo "  claude-vn-patch status - Check patch status"
echo "  claude-update          - Update Claude + auto-patch"
echo ""
echo "You can now type Vietnamese in Claude Code!"
