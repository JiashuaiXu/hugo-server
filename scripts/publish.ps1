<# 
.SYNOPSIS
  一键发布：提交并推送 obsidian-notes 内容仓库，然后更新 hugo-server 中的 content 子模块引用并推送。

.DESCRIPTION
  适用于本地写完文章后，不想手动重复执行：
    - obsidian-notes: git add/commit/push
    - hugo-server:   拉取 content 子模块最新 -> 更新子模块引用 -> commit/push

  默认假设目录结构：
    blog/
      hugo-server/        (本仓库，脚本所在)
      obsidian-notes/     (内容仓库，hugo-server 的 content submodule 的源仓库)

  也支持只在 hugo-server/ 下运行（会自动推断 sibling 的 obsidian-notes 路径）。

.PARAMETER Message
  提交信息（同时用于 obsidian-notes 提交；hugo-server 的提交会自动追加子模块信息）。

.PARAMETER ObsidianNotesPath
  obsidian-notes 仓库路径（默认：hugo-server 的同级目录 ../obsidian-notes）。

.PARAMETER HugoServerPath
  hugo-server 仓库路径（默认：脚本所在目录的上级，即仓库根）。

.PARAMETER ContentSubmodulePath
  hugo-server 内 content 子模块路径（默认：jesse-blog/content）。

.PARAMETER SkipObsidianPush
  仅更新 hugo-server 子模块引用，不提交/推送 obsidian-notes。

.PARAMETER SkipHugoServerPush
  仅提交到本地，不 push（用于你想先本地验证再推送的场景）。

.EXAMPLE
  pwsh -File .\scripts\publish.ps1 -Message "Add: 新文章"

.EXAMPLE
  pwsh -File .\scripts\publish.ps1 -Message "Update: 修复错别字" -SkipHugoServerPush
#>

[CmdletBinding()]
param(
  [string]$Message = "",
  [string]$ObsidianNotesPath = "",
  [string]$HugoServerPath = "",
  [string]$ContentSubmodulePath = "jesse-blog/content",
  [switch]$SkipObsidianPush,
  [switch]$SkipHugoServerPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step([string]$Text) {
  Write-Host ""
  Write-Host "==> $Text" -ForegroundColor Cyan
}

function Exec([string]$Cmd) {
  Write-Host "  $Cmd" -ForegroundColor DarkGray
  & pwsh -NoProfile -Command $Cmd
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed (exit $LASTEXITCODE): $Cmd"
  }
}

function Ensure-SafeDirectory([string]$RepoPath) {
  # 避免 Windows/权限导致的 “detected dubious ownership”
  $p = (Resolve-Path $RepoPath).Path.Replace("\", "/")
  $existing = (& git config --global --get-all safe.directory 2>$null) -as [string[]]
  if ($null -eq $existing -or ($existing -notcontains $p)) {
    Exec "git config --global --add safe.directory '$p'"
  }
}

function Get-RepoRootFromScript() {
  # 脚本位于 hugo-server/scripts/publish.ps1
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if ([string]::IsNullOrWhiteSpace($HugoServerPath)) {
  $HugoServerPath = Get-RepoRootFromScript
}
if ([string]::IsNullOrWhiteSpace($ObsidianNotesPath)) {
  $ObsidianNotesPath = (Resolve-Path (Join-Path $HugoServerPath "..\\obsidian-notes")).Path
}

$contentPath = (Resolve-Path (Join-Path $HugoServerPath $ContentSubmodulePath)).Path

if ([string]::IsNullOrWhiteSpace($Message)) {
  $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  $Message = "chore: publish ($now)"
}

Write-Step "环境检查"
Write-Host "  hugo-server:    $HugoServerPath"
Write-Host "  obsidian-notes: $ObsidianNotesPath"
Write-Host "  content:        $contentPath"

Ensure-SafeDirectory $HugoServerPath
Ensure-SafeDirectory $ObsidianNotesPath
Ensure-SafeDirectory $contentPath

Write-Step "1) 提交并推送 obsidian-notes（内容仓库）"
if (-not $SkipObsidianPush) {
  Push-Location $ObsidianNotesPath
  try {
    Exec "git status --porcelain"
    $dirty = (& git status --porcelain) -ne $null -and ((& git status --porcelain).Length -gt 0)
    if ($dirty) {
      Exec "git add -A"
      Exec ("git commit -m " + ('"' + $Message.Replace('"','\"') + '"'))
    } else {
      Write-Host "  工作区干净，无需提交" -ForegroundColor Yellow
    }
    Exec "git push origin main"
  } finally {
    Pop-Location
  }
} else {
  Write-Host "  已跳过 obsidian-notes push" -ForegroundColor Yellow
}

Write-Step "2) 更新 hugo-server 的 content 子模块到最新（origin/main）"
Push-Location $contentPath
try {
  Exec "git fetch origin"
  $local = (& git rev-parse HEAD).Trim()
  $remote = (& git rev-parse origin/main).Trim()
  if ($local -ne $remote) {
    Exec "git pull origin main"
  } else {
    Write-Host "  content 子模块已是最新 commit" -ForegroundColor Yellow
  }
  $contentSha = (& git rev-parse HEAD).Trim()
} finally {
  Pop-Location
}

Write-Step "3) 更新 hugo-server 主仓库的子模块引用并推送"
Push-Location $HugoServerPath
try {
  $dirtySubmodule = (& git status --porcelain $ContentSubmodulePath) -ne $null -and ((& git status --porcelain $ContentSubmodulePath).Length -gt 0)
  if ($dirtySubmodule) {
    Exec ("git add " + $ContentSubmodulePath)
    $hsMsg = "chore: update content submodule -> $contentSha"
    Exec ("git commit -m " + ('"' + $hsMsg.Replace('"','\"') + '"'))
    if (-not $SkipHugoServerPush) {
      Exec "git push origin main"
    } else {
      Write-Host "  已跳过 hugo-server push（仅本地提交）" -ForegroundColor Yellow
    }
  } else {
    Write-Host "  hugo-server 子模块引用未变化，无需提交" -ForegroundColor Yellow
  }
} finally {
  Pop-Location
}

Write-Host ""
Write-Host "完成 ✅（等待 GitHub Actions 构建部署）" -ForegroundColor Green


