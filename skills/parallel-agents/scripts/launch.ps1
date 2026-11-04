param(
    [string]$Repo,     # repo root (absolute path)
    [string]$Names,    # comma/space separated; one name per agent; briefs at .agents/briefs/<name>.md
    [string]$Model,    # agent (coding) model override
    [string]$Runner,   # claude|opencode (auto-detect if empty)
    [switch]$Tmux,     # open one visible console window per agent instead of hidden detached
    [switch]$DryRun    # print the command that would launch each agent, without running it
)

# Fan out N implementation agents in parallel, one detached process each. Returns
# immediately; each agent is immune to terminal close / Ctrl-C. For each <name> it
# expects a brief at .agents/briefs/<name>.md and writes a completion marker to
# .agents/runs/<name>.done and a transcript to .agents/runs/<name>.log (all under
# .agents/, which is gitignored).
# Windows counterpart of launch.sh.

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')
$runnerScript = Join-Path $PSScriptRoot 'run-agent.ps1'

if (-not $Repo)  { Write-Host 'launch: -Repo is required (absolute path to repo root)' -ForegroundColor Red; exit 2 }
if (-not $Names) { Write-Host 'launch: -Names is required (comma/space separated)' -ForegroundColor Red; exit 2 }
if (-not (Test-Path -LiteralPath $Repo -PathType Container)) {
    Write-Host "launch: -Repo is not a directory: $Repo" -ForegroundColor Red
    exit 2
}
$Repo = (Resolve-Path -LiteralPath $Repo).Path

$runner = resolve_runner $Runner
if ($runner -notin @('claude', 'opencode')) {
    Write-Host "launch: no runner found; install 'claude' or 'opencode'" -ForegroundColor Red
    exit 2
}
if (-not $Model) { $Model = default_model $runner }

$runsDir = Join-Path $Repo '.agents\runs'
New-Item -ItemType Directory -Force -Path $runsDir | Out-Null

# Split names on commas/semicolons/whitespace (one brief per name).
$nameList = $Names -split '[,\s;]+' | Where-Object { $_ -ne '' }

$count = 0
foreach ($name in $nameList) {
    # Reject empty names and anything outside letters/digits/._- (no leading dot).
    if ($name -notmatch '^[A-Za-z0-9_-][A-Za-z0-9._-]*$') {
        color_yellow "SKIP: invalid name '$name' (use letters, digits, . _ -)"
        continue
    }
    $brief = ".agents\briefs\$name.md"
    if (-not (Test-Path -LiteralPath (Join-Path $Repo $brief))) {
        color_yellow "SKIP: no brief at $brief"
        continue
    }
    $marker = ".agents\runs\$name.done"
    $log    = Join-Path $runsDir "$name.log"
    $title  = "$Model-$name"

    if ($DryRun) {
        $cmdline = @(
            'powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $runnerScript,
            '-Repo', $Repo, '-Brief', $brief, '-Marker', $marker, '-Log', $log,
            '-Model', $Model, '-Runner', $runner, '-Title', $title
        ) -join ' '
        Write-Host "[dry-run] $title`: $cmdline"
        $count++
        continue
    }

    if ($Tmux) {
        # One visible console window per agent, detached via `cmd /c start`. The empty
        # title ('""') keeps `start` from swallowing the next quoted argument, and the
        # new console + process group makes the agent immune to the Terminal panel's
        # 2s Ctrl-C. Paths/title here are space-free, so no extra quoting is needed;
        # the run is Tee'd to the log regardless, so nothing is lost if a window closes.
        Start-Process cmd.exe -WindowStyle Hidden -ArgumentList @(
            '/c', 'start', '""', '/D', $Repo, 'powershell.exe',
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $runnerScript,
            '-Repo', $Repo, '-Brief', $brief, '-Marker', $marker, '-Log', $log,
            '-Model', $Model, '-Runner', $runner, '-Title', $title
        )
    } else {
        # Hidden, fully detached process: survives the parent terminal's Ctrl-C /
        # close. The transcript is still Tee'd to the log by run-agent.ps1.
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $runnerScript,
            '-Repo', $Repo, '-Brief', $brief, '-Marker', $marker, '-Log', $log,
            '-Model', $Model, '-Runner', $runner, '-Title', $title
        )
    }
    Write-Host "launched: $title  (brief: $brief)"
    $count++
}

Write-Host "ALL_LAUNCHED count=$count"
