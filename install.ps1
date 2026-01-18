# Claude Code Vietnamese IME Fix - Windows Installer
# https://github.com/hangocduong/claude-code-vietnamese-fix

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

$RepoUrl = "https://raw.githubusercontent.com/hangocduong/claude-code-vietnamese-fix/main"
$TargetDir = "$env:USERPROFILE\.claude\scripts"

Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Cyan
Write-Host "|  Claude Code Vietnamese IME Fix              |" -ForegroundColor Cyan
Write-Host "|  Ban va bo go tieng Viet                     |" -ForegroundColor Cyan
Write-Host "+==============================================+" -ForegroundColor Cyan
Write-Host ""

# Check Python
try {
    $null = python --version 2>&1
    Write-Success "Python found"
} catch {
    Write-Err "Python is required but not installed"
    Write-Host "    Download from: https://python.org/downloads"
    exit 1
}

# Check Claude Code
try {
    $claudeVersion = claude --version 2>&1 | Select-Object -First 1
    Write-Success "Claude Code found: $claudeVersion"
} catch {
    Write-Err "Claude Code not found"
    Write-Host "    Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
}

# Create target directory
if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}
Write-Info "Target: $TargetDir"

# Determine script source
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalScripts = Join-Path $ScriptDir "scripts\vietnamese-ime-patch.ps1"

if (Test-Path $LocalScripts) {
    Write-Info "Installing from local repo..."
    Copy-Item "$ScriptDir\scripts\vietnamese-ime-patch.ps1" $TargetDir -Force
    Copy-Item "$ScriptDir\scripts\vietnamese-ime-patch-core.py" $TargetDir -Force
    Copy-Item "$ScriptDir\scripts\claude-update-wrapper.ps1" $TargetDir -Force
} else {
    Write-Info "Downloading scripts from GitHub..."
    Invoke-WebRequest "$RepoUrl/scripts/vietnamese-ime-patch.ps1" -OutFile "$TargetDir\vietnamese-ime-patch.ps1"
    Invoke-WebRequest "$RepoUrl/scripts/vietnamese-ime-patch-core.py" -OutFile "$TargetDir\vietnamese-ime-patch-core.py"
    Invoke-WebRequest "$RepoUrl/scripts/claude-update-wrapper.ps1" -OutFile "$TargetDir\claude-update-wrapper.ps1"
}
Write-Success "Scripts installed"

# Add to PowerShell profile
$ProfilePath = $PROFILE.CurrentUserAllHosts
$ProfileDir = Split-Path -Parent $ProfilePath

if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

if (!(Test-Path $ProfilePath)) {
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
}

$AliasBlock = @"

# Vietnamese IME fix for Claude Code
function claude-vn-patch { & `"$TargetDir\vietnamese-ime-patch.ps1`" @args }
function claude-update { & `"$TargetDir\claude-update-wrapper.ps1`" @args }
"@

$ProfileContent = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue
if ($ProfileContent -notmatch "claude-vn-patch") {
    Add-Content -Path $ProfilePath -Value $AliasBlock
    Write-Success "Functions added to PowerShell profile"
} else {
    Write-Info "Functions already exist in profile"
}

# Apply patch
Write-Host ""
Write-Info "Applying patch..."
& "$TargetDir\vietnamese-ime-patch.ps1" patch

Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host "|  Installation complete!                      |" -ForegroundColor Green
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host ""
Write-Host "Commands (restart PowerShell first):"
Write-Host ""
Write-Host "  claude-vn-patch        Apply/check patch" -ForegroundColor White
Write-Host "  claude-vn-patch status Check status" -ForegroundColor White
Write-Host "  claude-update          Update Claude + auto-patch" -ForegroundColor White
Write-Host ""
Write-Host "Ban co the go tieng Viet trong Claude Code!" -ForegroundColor Cyan
Write-Host ""
