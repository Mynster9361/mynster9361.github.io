<#
.SYNOPSIS
Discovers PowerShell modules published on the PowerShell Gallery profile, regenerates
PlatyPS command-reference docs, and cuts a new Docusaurus version snapshot per module
whenever a new release is detected.

.DESCRIPTION
Reads modules-manifest.json at the repo root, which drives docusaurus.config.ts's
per-module docs plugin instances. This script only ever appends/updates entries in
that JSON file plus each module's commands/ folder and versioned-docs snapshots -
it never touches index.md or any other hand-written content once a module's folder
already exists.

Only ever processes the CURRENT live release per module. For historical releases
published before this automation existed (or missed by a prior failed run), use
Backfill-Docs.ps1 instead.
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path,
    [string]$GalleryProfile = 'https://www.powershellgallery.com/profiles/Mynster',
    [string]$PrBodyPath = (Join-Path ([System.IO.Path]::GetTempPath()) 'psgallery-sync-pr-body.md')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'Common.ps1')

$manifestPath = Join-Path $RepoRoot 'modules-manifest.json'
$bootstrappedModules = @()

# --- main ---

$manifest = Get-Content -Raw -Path $manifestPath | ConvertFrom-Json
$summaryRows = @()

$discoveredNewModule = $false
foreach ($name in (Get-GalleryModuleNames -GalleryProfile $GalleryProfile)) {
    $id = Get-ModuleIdSlug -Name $name
    if (-not ($manifest.modules | Where-Object { $_.id -eq $id })) {
        Write-Host "New module discovered on PSGallery: $name (id: $id)"
        $docsPath = "docs-modules/$id"
        $manifest.modules = @($manifest.modules) + [pscustomobject]@{
            id                   = $id
            psGalleryId          = $name
            displayName          = $name
            docsPath             = $docsPath
            lastVersionedRelease = $null
            firstSeen            = (Get-Date -Format 'yyyy-MM-dd')
        }
        $discoveredNewModule = $true
        if (-not $DryRun) {
            # Docusaurus initializes every registered docs plugin instance - including
            # ones just added to the manifest this run - before running ANY
            # `docs:version:*` command, and errors if an instance's folder doesn't
            # physically exist yet. Create the (empty, for now) folder immediately so a
            # version cut for an unrelated, already-existing module doesn't fail because
            # of a brand-new module that hasn't been scaffolded yet.
            New-Item -ItemType Directory -Force -Path (Join-Path $RepoRoot $docsPath 'commands') | Out-Null
        }
    }
}

if ($discoveredNewModule) {
    # docusaurus.config.ts reads modules-manifest.json fresh from disk each time the
    # CLI spawns, and its plugins array (and thus the `docs:version:<id>` script) only
    # exists for modules already on disk - persist newly-discovered entries now, before
    # any docs:version cut is attempted for them below.
    Save-Manifest -Manifest $manifest -ManifestPath $manifestPath -DryRun:$DryRun
}

foreach ($module in $manifest.modules) {
    Write-Host "--- $($module.displayName) ---"
    $info = Get-GalleryModuleInfo -PsGalleryId $module.psGalleryId
    $liveVersion = $info.Version
    $lastVersion = $module.lastVersionedRelease
    $folderExists = Test-Path (Join-Path $RepoRoot $module.docsPath)

    if (-not $folderExists -or [string]::IsNullOrEmpty($lastVersion)) {
        # Brand new module, or an existing-but-never-versioned folder: generate the
        # live release and leave it as the unversioned "current" bucket - same as
        # every later release does. Nothing to cut yet; there's no OLDER version on
        # disk worth freezing, and explicitly cutting the live version here too would
        # just duplicate it under both a numbered URL and the current one. The
        # "current" bucket gets its real version number as a label via
        # docusaurus.config.ts's per-module `versions.current.label`, driven by
        # lastVersionedRelease below, instead of Docusaurus's default "Next".
        $bootstrapped = New-ModuleScaffold -Module $module -Info $info -RepoRoot $RepoRoot -DryRun:$DryRun
        if ($bootstrapped) { $bootstrappedModules += $module.displayName }
        Invoke-PlatyPSGeneration -Module $module -Version $liveVersion -RepoRoot $RepoRoot -DryRun:$DryRun
        $summaryRows += "| $($module.displayName) | (bootstrap) | $liveVersion |"
        $module.lastVersionedRelease = $liveVersion
        Save-Manifest -Manifest $manifest -ManifestPath $manifestPath -DryRun:$DryRun
        continue
    }

    $cmp = Compare-ModuleVersion -Live $liveVersion -Recorded $lastVersion
    if ($cmp -eq 0) {
        Write-Host "No new release ($liveVersion) - refreshing command docs only."
        Invoke-PlatyPSGeneration -Module $module -Version $liveVersion -RepoRoot $RepoRoot -DryRun:$DryRun
        continue
    }
    if ($cmp -lt 0) {
        Write-Warning "Live PSGallery version ($liveVersion) is older than last recorded ($lastVersion) for $($module.displayName) - skipping, possible flaky API response."
        continue
    }

    # New release: freeze what's CURRENTLY on disk (still the old version) under the
    # old label BEFORE overwriting it with fresh output for the new version.
    Invoke-DocsVersionCut -Id $module.id -Version $lastVersion -RepoRoot $RepoRoot -DryRun:$DryRun
    Invoke-PlatyPSGeneration -Module $module -Version $liveVersion -RepoRoot $RepoRoot -DryRun:$DryRun
    New-ReleaseAnnouncementPost -Module $module -Version $liveVersion -ReleaseNotes $info.ReleaseNotes -RepoRoot $RepoRoot -DryRun:$DryRun
    $summaryRows += "| $($module.displayName) | $lastVersion | $liveVersion |"
    $module.lastVersionedRelease = $liveVersion
    Save-Manifest -Manifest $manifest -ManifestPath $manifestPath -DryRun:$DryRun
}

$body = @('## PowerShell Gallery docs sync', '')
if ($summaryRows.Count -gt 0) {
    $body += '| Module | Previous version | New version |'
    $body += '|---|---|---|'
    $body += $summaryRows
} else {
    $body += 'No module releases detected - command reference docs refreshed in place where needed.'
}
if ($bootstrappedModules.Count -gt 0) {
    $body += ''
    $body += '### New modules - follow-up needed'
    foreach ($m in $bootstrappedModules) {
        $body += "- [ ] Add ""$m"" to docs/modules/index.md"
    }
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PrBodyPath) | Out-Null
Set-Content -Path $PrBodyPath -Value ($body -join "`n") -Encoding utf8

Write-Host 'Done.'
