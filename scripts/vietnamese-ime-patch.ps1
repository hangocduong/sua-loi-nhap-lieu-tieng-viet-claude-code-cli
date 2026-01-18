# Claude Code Vietnamese IME Patch - Entry point (Windows)
# Usage: claude-vn-patch [patch|restore|status]

param(
    [string]$Action = "patch"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "vietnamese-ime-patch-core.py"

if (!(Test-Path $PythonScript)) {
    Write-Host "Error: Core script not found: $PythonScript" -ForegroundColor Red
    exit 1
}

function Find-CliJs {
    # Try to find claude command
    $claudePath = (Get-Command claude -ErrorAction SilentlyContinue).Source
    if ($claudePath) {
        # Check if it's a node script
        $content = Get-Content $claudePath -First 1 -ErrorAction SilentlyContinue
        if ($content -match "node") {
            return $claudePath
        }
    }

    # Common npm global paths on Windows
    $paths = @(
        "$env:APPDATA\npm\node_modules\@anthropic-ai\claude-code\cli.js",
        "$env:LOCALAPPDATA\npm\node_modules\@anthropic-ai\claude-code\cli.js",
        "$env:ProgramFiles\nodejs\node_modules\@anthropic-ai\claude-code\cli.js"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

$CliJs = Find-CliJs
if (!$CliJs) {
    Write-Host "Error: Could not find Claude Code cli.js" -ForegroundColor Red
    Write-Host "Make sure Claude Code is installed via npm:" -ForegroundColor Yellow
    Write-Host "  npm install -g @anthropic-ai/claude-code" -ForegroundColor White
    exit 1
}

python $PythonScript $CliJs $Action
exit $LASTEXITCODE
