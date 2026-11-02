param(
    [Parameter(Mandatory)][string]$Repo,    # repo root (absolute)
    [Parameter(Mandatory)][string]$Brief,   # brief path, relative to repo
    [Parameter(Mandatory)][string]$Marker,  # completion marker path, relative to repo
    [Parameter(Mandatory)][string]$Log,     # log file path (absolute)
    [string]$Model = 'sonnet',
    [string]$Title = 'Sonnet agent'
)

# One Sonnet implementation agent. Launched DETACHED in its own visible console
# window (see launch.ps1) so the app Terminal panel's 2s auto-cancel can't kill it.
# The agent may only read and write files; a reviewer runs tests and commits.

$ErrorActionPreference = 'Continue'
$host.UI.RawUI.WindowTitle = $Title
$claude = Join-Path $env:APPDATA 'npm\claude.cmd'
$markerAbs = Join-Path $Repo $Marker

Remove-Item -LiteralPath $markerAbs -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $Log -ErrorAction SilentlyContinue
Set-Location -LiteralPath $Repo

$prompt = "Read the file $Brief in this repository and implement everything it " +
    "specifies, following it exactly. Only read and write files; do not run any " +
    "shell, artisan, composer, npm, git, or test commands, and do not commit. " +
    "Mirror the existing modules and conventions already in this repo. " +
    "When finished, print DONE on its own line."

Write-Host "=== $Title  ::  $Brief (model: $Model) ===" -ForegroundColor Cyan
Write-Host ''

& $claude -p $prompt --model $Model --permission-mode acceptEdits --disallowedTools Bash --output-format stream-json --verbose 2>&1 |
    Tee-Object -FilePath $Log

$code = $LASTEXITCODE
"RUN_DONE exit=$code at $(Get-Date -Format o)" | Out-File -LiteralPath $markerAbs -Encoding utf8
Write-Host ''
Write-Host "=== DONE: $Title (exit=$code). Files written; reviewer will test + commit. ===" -ForegroundColor Green
