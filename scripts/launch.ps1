param(
    [Parameter(Mandatory)][string]$Repo,     # repo root (absolute)
    [Parameter(Mandatory)][string]$Names,    # comma/space separated; one name per agent; briefs at .agents/briefs/<name>.md
    [string]$Model = 'sonnet'
)

# Split here rather than typing [string[]]: when this script is launched via
# `powershell -File`, PowerShell passes "a,b" as a single string, not an array.
$nameList = $Names -split '[,\s]+' | Where-Object { $_ -ne '' }

# Fan out one Sonnet agent per name, each in its own visible console window, all
# in parallel. Returns immediately (each window is detached), so the Terminal
# panel's 2s auto-cancel never touches the running agents.
#
# For each <name> it expects a brief at .agents/briefs/<name>.md and writes a
# completion marker to .agents/runs/<name>.done and a transcript to
# .agents/runs/<name>.log (all under .agents/, which is gitignored).

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$runner = Join-Path $here 'run-agent.ps1'
$runsDir = Join-Path $Repo '.agents\runs'
New-Item -ItemType Directory -Force -Path $runsDir | Out-Null

foreach ($name in $nameList) {
    $brief = ".agents\briefs\$name.md"
    if (-not (Test-Path -LiteralPath (Join-Path $Repo $brief))) {
        Write-Host "SKIP: no brief at $brief" -ForegroundColor Yellow
        continue
    }
    $marker = ".agents\runs\$name.done"
    $log = Join-Path $runsDir "$name.log"
    $title = "$Model-$name"
    # Spawn each agent as a fully independent, visible console via `cmd /c start`.
    # Start-Process alone (even visible) leaves the child in the caller's console
    # group, so the Terminal panel's 2s Ctrl-C kills it; `start` gives the agent its
    # own new console + process group, detached, so it survives. Paths and the title
    # here are space-free, so no extra quoting is needed; the run is Tee'd to the log
    # regardless, so nothing is lost if a window is closed.
    Start-Process cmd.exe -WindowStyle Hidden -ArgumentList @(
        '/c', 'start', '""', '/D', $Repo, 'powershell.exe',
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $runner,
        '-Repo', $Repo, '-Brief', $brief, '-Marker', $marker, '-Log', $log,
        '-Model', $Model, '-Title', $title
    )
    Write-Host "launched: $title  (brief: $brief)"
}

Write-Host "ALL_LAUNCHED count=$($nameList.Count)"
