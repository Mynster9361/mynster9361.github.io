<#
.SYNOPSIS
One-time catch-up: cuts a Docusaurus version snapshot for every PSGallery release of
each module that isn't already represented in <id>_versions.json.

.DESCRIPTION
Sync-Docs.ps1 only ever handles the CURRENT live release per module. This script fills
in the history PSGallery already has - every published version that predates this
automation, or was otherwise missed - in ascending order, so old command references
become browsable via the version dropdown just like a normal release-by-release cut
would have produced them.

Only processes modules whose docs folder already exists (i.e. already bootstrapped by
Sync-Docs.ps1 at least once) - a module with no folder yet has no plugin instance for
Docusaurus to version against.

Does not touch modules-manifest.json: the manifest's lastVersionedRelease already
correctly points at the newest release (set by the routine sync), and backfilling older
history doesn't change what "current" is - it only adds snapshots underneath it.
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path,
    [string[]]$ModuleId,
    [string]$PrBodyPath = (Join-Path ([System.IO.Path]::GetTempPath()) 'psgallery-backfill-pr-body.md')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'Common.ps1')

$manifestPath = Join-Path $RepoRoot 'modules-manifest.json'
$manifest = Get-Content -Raw -Path $manifestPath | ConvertFrom-Json

$targets = $manifest.modules
if ($ModuleId) {
    $targets = $targets | Where-Object { $_.id -in $ModuleId }
    if (-not $targets) {
        throw "No manifest entries matched -ModuleId $($ModuleId -join ', ')"
    }
}

$summaryRows = @()

foreach ($module in $targets) {
    Write-Host "=== $($module.displayName) ==="

    if (-not (Test-Path (Join-Path $RepoRoot $module.docsPath))) {
        Write-Warning "Skipping $($module.displayName): docs folder doesn't exist yet - run Sync-Docs.ps1 first to bootstrap it."
        continue
    }

    $allVersions = Get-GalleryModuleVersions -PsGalleryId $module.psGalleryId
    $cutVersions = Get-CutVersions -Id $module.id -RepoRoot $RepoRoot
    $currentRelease = $module.lastVersionedRelease

    # Skip anything already cut, and skip the current release itself - that's the
    # working copy's live content already, not history to backfill.
    $missing = @($allVersions | Where-Object { $_ -notin $cutVersions -and $_ -ne $currentRelease })

    if ($missing.Count -eq 0) {
        Write-Host 'No missing historical versions.'
        continue
    }
    Write-Host "Missing versions to backfill (oldest to newest): $($missing -join ', ')"

    foreach ($version in $missing) {
        Invoke-PlatyPSGeneration -Module $module -Version $version -RepoRoot $RepoRoot -DryRun:$DryRun
        Invoke-DocsVersionCut -Id $module.id -Version $version -RepoRoot $RepoRoot -DryRun:$DryRun
    }
    $summaryRows += "| $($module.displayName) | $($missing -join ', ') |"

    if ($currentRelease) {
        # The loop above left the working copy sitting at the newest *historical*
        # version it just cut, not the actual current release - restore it. The
        # current release itself is already correctly recorded/cut by the routine
        # sync and does not need cutting again here.
        Write-Host "Restoring working copy to current release $currentRelease"
        Invoke-PlatyPSGeneration -Module $module -Version $currentRelease -RepoRoot $RepoRoot -DryRun:$DryRun
    }
}

$body = @('## PowerShell Gallery docs backfill', '')
if ($summaryRows.Count -gt 0) {
    $body += '| Module | Versions backfilled |'
    $body += '|---|---|'
    $body += $summaryRows
} else {
    $body += 'No missing historical versions found - nothing to backfill.'
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PrBodyPath) | Out-Null
Set-Content -Path $PrBodyPath -Value ($body -join "`n") -Encoding utf8

Write-Host 'Done.'
