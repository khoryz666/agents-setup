# Prerequisite check: is the claude CLI installed on this host, and is it logged in?
$ErrorActionPreference = 'Continue'
$claude = Join-Path $env:APPDATA 'npm\claude.cmd'
if (-not (Test-Path -LiteralPath $claude)) {
    Write-Host "MISSING claude CLI. Install it on the host with:" -ForegroundColor Red
    Write-Host "  npm install -g '@anthropic-ai/claude-code'"
    exit 1
}
Write-Host "claude: $claude"
& $claude --version
Write-Host ''
Write-Host "If a run prints 'Not logged in', run 'claude' once interactively and complete /login." -ForegroundColor Yellow
