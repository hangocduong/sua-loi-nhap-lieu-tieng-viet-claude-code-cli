# Claude Code Vietnamese IME Fix

Fix Vietnamese input (OpenKey, EVKey, Unikey, PHTV) for Claude Code terminal.

## Problem

Vietnamese IMEs use "backspace-then-replace" technique to transform characters (`a` → `á`). Claude Code processes the backspace (DEL char 0x7F) but fails to display replacement characters, causing text loss.

## Solution

This patch intercepts the DEL character handling and re-inserts the remaining characters properly.

## Tested Versions

- Claude Code v2.1.12 (January 2026)
- macOS (Homebrew/npm install)

## Quick Install

```bash
# Clone or download this repo
git clone https://github.com/hangocduong/claude-code-vietnamese-fix.git
cd claude-code-vietnamese-fix

# Run installer
./install.sh
```

## Manual Install

```bash
# Copy scripts to ~/.claude/scripts/
mkdir -p ~/.claude/scripts
cp scripts/*.sh scripts/*.py ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh ~/.claude/scripts/*.py

# Add aliases to shell config
echo 'alias claude-vn-patch="$HOME/.claude/scripts/vietnamese-ime-patch.sh"' >> ~/.zshrc
echo 'alias claude-update="$HOME/.claude/scripts/claude-update-wrapper.sh"' >> ~/.zshrc
source ~/.zshrc

# Apply patch
claude-vn-patch
```

## Usage

| Command | Description |
|---------|-------------|
| `claude-vn-patch` | Apply patch (default) |
| `claude-vn-patch status` | Check if patch is applied |
| `claude-vn-patch restore` | Restore original cli.js |
| `claude-update` | Update Claude + auto-patch |

## After Claude Updates

Run one of:
```bash
claude-vn-patch      # Just patch
claude-update        # Update + patch
```

## How It Works

### The Bug

```
User types: "xin chào" using Vietnamese IME
IME sends: x → xi → xin → xin<DEL>c → xin ch → xin ch<DEL>à → xin chà<DEL>o → xin chào
Claude processes: <DEL> removes char, but remaining chars are lost
Result: "xin c" instead of "xin chào"
```

### The Fix

1. **Detect** DEL character handling block in minified cli.js
2. **Extract** variable names dynamically (they change between versions)
3. **Inject** code that:
   - Filters out DEL chars from input
   - Re-inserts remaining characters properly
   - Updates text/offset state

### Dynamic Variable Extraction

The script uses regex to find patterns like:
```javascript
// Original (minified)
if(l.includes("\x7f")){
  let $A=(l.match(/\x7f/g)||[]).length,CA=S;
  for(let _A=0;_A<$A;_A++)CA=CA.backspace();
  if(!S.equals(CA)){if(S.text!==CA.text)Q(CA.text);T(CA.offset)}
  // ... PATCH INSERTED HERE ...
  ct1(),lt1();return
}
```

Extracts: `input=l, state=CA, cur_state=S, text_fn=Q, offset_fn=T`

### Injected Code

```javascript
let _vn=l.replace(/\x7f/g,"");
if(_vn.length>0){
  for(const _c of _vn)CA=CA.insert(_c);
  if(!S.equals(CA)){
    if(S.text!==CA.text)Q(CA.text);
    T(CA.offset)
  }
}
```

## Project Structure

```
claude-code-vietnamese-fix/
├── README.md
├── install.sh                           # One-click installer
├── scripts/
│   ├── vietnamese-ime-patch.sh          # Entry point (bash)
│   ├── vietnamese-ime-patch-core.py     # Core logic (python)
│   └── claude-update-wrapper.sh         # Update + patch wrapper
└── docs/
    └── technical-details.md             # Deep dive into the fix
```

## Requirements

- Python 3.6+
- Claude Code installed via npm (`npm install -g @anthropic-ai/claude-code`)
- macOS or Linux

## Troubleshooting

### "Could not find Claude Code cli.js"

Claude Code not installed or installed as binary (not npm). Install via:
```bash
npm install -g @anthropic-ai/claude-code
```

### "Could not extract variables"

Claude Code version may have changed significantly. Open an issue with:
```bash
claude --version
```

### "Patch already applied"

The fix is already active. Check with:
```bash
claude-vn-patch status
```

## Credits

- Original fix concept: [manhit96/claude-code-vietnamese-fix](https://github.com/manhit96/claude-code-vietnamese-fix)
- Dynamic extraction & v2.1.12 support: This project

## License

MIT
