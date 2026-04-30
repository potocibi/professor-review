#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

$ClaudeDir = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' }
$SkillDir   = Join-Path $ClaudeDir 'skills\professor-review'
$CommandDir = Join-Path $ClaudeDir 'commands'
$AgentDir   = Join-Path $ClaudeDir 'agents'

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Install-File {
    param([string]$Src, [string]$Dest)
    if (Test-Path $Dest) {
        Write-Host "  SKIP  $Dest already exists (delete it first to reinstall)"
        return
    }
    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -Path $Src -Destination $Dest
    Write-Host "  OK    $Dest"
}

Write-Host "Installing professor-review to $ClaudeDir"
Install-File (Join-Path $RepoRoot 'src\skill\SKILL.md')                (Join-Path $SkillDir 'SKILL.md')
Install-File (Join-Path $RepoRoot 'src\command\vibe-review.md')        (Join-Path $CommandDir 'vibe-review.md')
Install-File (Join-Path $RepoRoot 'src\command\vibe-test.md')          (Join-Path $CommandDir 'vibe-test.md')
Install-File (Join-Path $RepoRoot 'src\agent\professor-advisor.md')    (Join-Path $AgentDir 'professor-advisor.md')
Install-File (Join-Path $RepoRoot 'src\agent\professor-reviewer.md')   (Join-Path $AgentDir 'professor-reviewer.md')
Install-File (Join-Path $RepoRoot 'src\agent\professor-security.md')   (Join-Path $AgentDir 'professor-security.md')
Install-File (Join-Path $RepoRoot 'src\agent\professor-fixer.md')      (Join-Path $AgentDir 'professor-fixer.md')

Write-Host ""
Write-Host "Done. Restart Claude Code (or run /reload) to pick up the new skill, command, and agent."
Write-Host "Then try: /vibe-review path/to/your/code"
