# Shared helpers for the parallel-agents skill. Dot-sourced by the other scripts.
# Windows counterpart of scripts/lib.sh: same defaults, config lookup, and runner
# resolution, so the PowerShell runner behaves identically to the bash runner.

# Resolve locations relative to this file. `$PSScriptRoot` is the directory of this
# file even when the skill is linked into ~/.claude/skills / ~/.config/opencode.
$SCRIPT_DIR  = $PSScriptRoot
$SKILL_DIR   = Split-Path -Parent $SCRIPT_DIR
$REPO_ROOT   = Split-Path -Parent (Split-Path -Parent $SKILL_DIR)
$CONFIG_FILE = Join-Path $REPO_ROOT 'config.json'

# Fallback defaults, used only if config.json / JSON parsing are unavailable.
$CLAUDE_DEFAULT_MODEL   = 'claude-sonnet-5-5'
$OPENCODE_DEFAULT_MODEL = 'opencode/deepseek-v4.1-flash-free'

# The file-only agent the OpenCode runner selects (installed by install.ps1).
$OPENCODE_AGENT = 'parallel-agent'

function color_red    { Write-Host ($args -join ' ') -ForegroundColor Red }
function color_yellow { Write-Host ($args -join ' ') -ForegroundColor Yellow }
function color_cyan   { Write-Host ($args -join ' ') -ForegroundColor Cyan }
function color_green  { Write-Host ($args -join ' ') -ForegroundColor Green }

# Print the value at a dotted path in $CONFIG_FILE (e.g. "models.claude.agent").
# Returns $null (and prints nothing) if the file, the path, or JSON parsing fails.
function config_get {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $CONFIG_FILE -PathType Leaf)) { return $null }
    try {
        $data = Get-Content -LiteralPath $CONFIG_FILE -Raw | ConvertFrom-Json
    } catch {
        return $null
    }
    $current = $data
    foreach ($part in ($Path -split '\.')) {
        if ($null -eq $current) { return $null }
        $current = $current.$part
    }
    if ($current -is [string]) { return $current }
    return ($current | ConvertTo-Json -Compress)
}

# Resolve the runner to use: pass a forced value, or leave empty to auto-detect.
function resolve_runner {
    param([string]$Forced)
    if ($Forced) { return $Forced }
    if (Get-Command claude -ErrorAction SilentlyContinue) { return 'claude' }
    if (Get-Command opencode -ErrorAction SilentlyContinue) { return 'opencode' }
    return ''
}

# Default agent (coding) model for a runner, from config with a hardcoded fallback.
function default_model {
    param([string]$Runner)
    $key = if ($Runner -eq 'opencode') { 'models.opencode.agent' } else { 'models.claude.agent' }
    $v = config_get $key
    if ($v) { return $v }
    if ($Runner -eq 'opencode') { return $OPENCODE_DEFAULT_MODEL }
    return $CLAUDE_DEFAULT_MODEL
}

# Resolve the claude executable: PATH first, then the common npm global location.
function resolve_claude {
    $cmd = Get-Command claude -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    if ($env:APPDATA) {
        $npm = Join-Path $env:APPDATA 'npm\claude.cmd'
        if (Test-Path -LiteralPath $npm -PathType Leaf) { return $npm }
    }
    return $null
}

# Resolve the opencode executable.
function resolve_opencode {
    $cmd = Get-Command opencode -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}
