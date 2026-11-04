# Prerequisite check: are the runner CLIs installed on this host? (Login can't be
# checked non-interactively; see the hint printed at the end.)
# Windows counterpart of check-cli.sh.

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'lib.ps1')

$status = 0
foreach ($cli in @('claude', 'opencode')) {
    $cmd = Get-Command $cli -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host ("{0,-9} {1}" -f ($cli + ':'), $cmd.Source)
        & $cli --version 2>&1 | ForEach-Object { Write-Host ("           {0}" -f $_) }
    } else {
        color_yellow "$cli`: not found on PATH"
        $status = 1
    }
}

Write-Host ''
if ($status -ne 0) {
    color_yellow 'Install the missing CLI(s):'
    Write-Host '  claude:   npm install -g @anthropic-ai/claude-code   (or the native installer)'
    Write-Host '  opencode: irm https://opencode.ai/install.ps1 | iex'
}

$xdg = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
$agentFile = Join-Path (Join-Path $xdg 'opencode') ("agents\$OPENCODE_AGENT.md")
if (Test-Path -LiteralPath $agentFile) {
    Write-Host "opencode agent: $agentFile"
} else {
    color_yellow "opencode agent '$OPENCODE_AGENT' not installed (run $REPO_ROOT\install.ps1)"
}

Write-Host ''
if (Test-Path -LiteralPath $CONFIG_FILE) {
    Write-Host "config: $CONFIG_FILE"
    Write-Host "  claude    agent: $(default_model claude)"
    Write-Host "  opencode  agent: $(default_model opencode)"
} else {
    color_yellow "config.json not found (expected at $CONFIG_FILE)"
}

Write-Host ''
color_cyan "If a run prints 'Not logged in', run the CLI once interactively and complete login."
exit $status
