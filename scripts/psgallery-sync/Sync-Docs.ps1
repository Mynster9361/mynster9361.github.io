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

$manifestPath = Join-Path $RepoRoot 'modules-manifest.json'
$script:BootstrappedModules = @()

function Get-ModuleIdSlug {
    param([Parameter(Mandatory)][string]$Name)
    ($Name.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
}

function Get-GalleryModuleNames {
    Write-Host "Discovering modules from $GalleryProfile"
    $response = Invoke-WebRequest -Uri $GalleryProfile -UseBasicParsing
    $names = [regex]::Matches($response.Content, 'href="/packages/([^"/]+)/?"') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
    if (-not $names -or $names.Count -eq 0) {
        throw "No modules discovered on $GalleryProfile - refusing to proceed (PSGallery page layout may have changed)."
    }
    Write-Host "Discovered modules: $($names -join ', ')"
    return $names
}

function Get-GalleryModuleInfo {
    param([Parameter(Mandatory)][string]$PsGalleryId)
    $result = Find-PSResource -Name $PsGalleryId -Repository PSGallery -ErrorAction Stop
    if ($result -is [array]) { $result = $result[0] }
    [pscustomobject]@{
        Version     = $result.Version.ToString()
        Description = $result.Description
    }
}

function Compare-ModuleVersion {
    param([Parameter(Mandatory)][string]$Live, [Parameter(Mandatory)][string]$Recorded)
    # Strip any prerelease suffix (e.g. "1.2.0-beta1") - [version] throws on those.
    $liveClean = ($Live -split '-')[0]
    $recordedClean = ($Recorded -split '-')[0]
    try {
        return ([version]$liveClean).CompareTo([version]$recordedClean)
    } catch {
        return [string]::Compare($Live, $Recorded, [System.StringComparison]::OrdinalIgnoreCase)
    }
}

function New-ModuleScaffold {
    param([Parameter(Mandatory)]$Module, [Parameter(Mandatory)]$Info)
    $indexPath = Join-Path $RepoRoot $Module.docsPath 'index.md'
    if (Test-Path $indexPath) { return } # existing content - never touched by automation
    Write-Host "Bootstrapping new module doc: $($Module.displayName)"
    if ($DryRun) { return }
    New-Item -ItemType Directory -Force -Path (Join-Path $RepoRoot $Module.docsPath 'commands') | Out-Null
    $content = @"
---
title: $($Module.displayName) PowerShell Module
---

# $($Module.displayName) PowerShell Module

$($Info.Description)

## Installation

``````powershell
Install-Module -Name $($Module.psGalleryId) -Scope CurrentUser
``````

*(Auto-generated placeholder from PowerShell Gallery metadata. Replace freely - this file is never touched by automation again once it exists.)*
"@
    Set-Content -Path $indexPath -Value $content -Encoding utf8
    $script:BootstrappedModules += $Module.displayName
}

function Invoke-PlatyPSGeneration {
    param([Parameter(Mandatory)]$Module, [Parameter(Mandatory)][string]$Version)
    Write-Host "Generating command docs for $($Module.psGalleryId) $Version"
    if ($DryRun) { return }

    Install-Module -Name $Module.psGalleryId -RequiredVersion $Version -Force -SkipPublisherCheck -Scope CurrentUser -AllowClobber
    Import-Module -Name $Module.psGalleryId -RequiredVersion $Version -Force

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "platyps-$($Module.id)-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    # The site's existing command pages use minimal `title`-only frontmatter, not
    # PlatyPS's default metadata block - try -NoMetadata first, fall back to
    # generate-then-strip if the installed platyPS version doesn't support it.
    $usedNoMetadata = $true
    try {
        New-MarkdownHelp -Module $Module.psGalleryId -OutputFolder $tempDir -Force -NoMetadata -ErrorAction Stop | Out-Null
    } catch {
        Write-Warning "New-MarkdownHelp -NoMetadata failed ($($_.Exception.Message)); falling back to default metadata + strip."
        $usedNoMetadata = $false
        Get-ChildItem -Path $tempDir -Filter '*.md' -ErrorAction SilentlyContinue | Remove-Item -Force
        New-MarkdownHelp -Module $Module.psGalleryId -OutputFolder $tempDir -Force | Out-Null
    }

    $commandsDir = Join-Path $RepoRoot $Module.docsPath 'commands'
    New-Item -ItemType Directory -Force -Path $commandsDir | Out-Null
    Get-ChildItem -Path $commandsDir -Filter '*.md' -ErrorAction SilentlyContinue | Remove-Item -Force

    $commandNames = @()
    Get-ChildItem -Path $tempDir -Filter '*.md' | ForEach-Object {
        $commandName = $_.BaseName
        $commandNames += $commandName
        $body = Get-Content -Raw -Path $_.FullName
        if (-not $usedNoMetadata) {
            # Strip whatever frontmatter platyPS emitted between the first two '---' lines.
            $body = $body -replace '(?s)^---.*?---\r?\n', ''
        }
        $frontmatter = "---`ntitle: $commandName`n---`n`n"
        Set-Content -Path (Join-Path $commandsDir "$commandName.md") -Value ($frontmatter + $body.TrimStart()) -Encoding utf8
    }
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    $indexLines = @('---', "title: $($Module.displayName) Commands", '---', '', "# $($Module.displayName) Commands", '')
    $indexLines += ($commandNames | Sort-Object | ForEach-Object {
        "* [``$_``](/docs/modules/$($Module.id)/commands/$_)"
    })
    Set-Content -Path (Join-Path $commandsDir 'index.md') -Value ($indexLines -join "`n") -Encoding utf8

    Remove-Module -Name $Module.psGalleryId -Force -ErrorAction SilentlyContinue
}

function Save-Manifest {
    param([Parameter(Mandatory)]$Manifest)
    if ($DryRun) { return }
    $Manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding utf8
}

function Invoke-DocsVersionCut {
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][string]$Version)
    Write-Host "Cutting Docusaurus version '$Version' for plugin '$Id'"
    if ($DryRun) { return }
    Push-Location $RepoRoot
    try {
        & npm run docusaurus -- "docs:version:$Id" $Version
        if ($LASTEXITCODE -ne 0) {
            throw "docs:version:$Id $Version failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
}

# --- main ---

$manifest = Get-Content -Raw -Path $manifestPath | ConvertFrom-Json
$summaryRows = @()

$discoveredNewModule = $false
foreach ($name in (Get-GalleryModuleNames)) {
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
    Save-Manifest -Manifest $manifest
}

foreach ($module in $manifest.modules) {
    Write-Host "--- $($module.displayName) ---"
    $info = Get-GalleryModuleInfo -PsGalleryId $module.psGalleryId
    $liveVersion = $info.Version
    $lastVersion = $module.lastVersionedRelease
    $folderExists = Test-Path (Join-Path $RepoRoot $module.docsPath)

    if (-not $folderExists -or [string]::IsNullOrEmpty($lastVersion)) {
        # Brand new module, or an existing-but-never-versioned folder (this is
        # LeastPrivilegedMSGraph's state as of this writing): generate first, then
        # cut - there's nothing on disk yet worth freezing under the old label.
        New-ModuleScaffold -Module $module -Info $info
        Invoke-PlatyPSGeneration -Module $module -Version $liveVersion
        Invoke-DocsVersionCut -Id $module.id -Version $liveVersion
        $summaryRows += "| $($module.displayName) | (bootstrap) | $liveVersion |"
        $module.lastVersionedRelease = $liveVersion
        continue
    }

    $cmp = Compare-ModuleVersion -Live $liveVersion -Recorded $lastVersion
    if ($cmp -eq 0) {
        Write-Host "No new release ($liveVersion) - refreshing command docs only."
        Invoke-PlatyPSGeneration -Module $module -Version $liveVersion
        continue
    }
    if ($cmp -lt 0) {
        Write-Warning "Live PSGallery version ($liveVersion) is older than last recorded ($lastVersion) for $($module.displayName) - skipping, possible flaky API response."
        continue
    }

    # New release: freeze what's CURRENTLY on disk (still the old version) under the
    # old label BEFORE overwriting it with fresh output for the new version.
    Invoke-DocsVersionCut -Id $module.id -Version $lastVersion
    Invoke-PlatyPSGeneration -Module $module -Version $liveVersion
    $summaryRows += "| $($module.displayName) | $lastVersion | $liveVersion |"
    $module.lastVersionedRelease = $liveVersion
}

Save-Manifest -Manifest $manifest

$body = @('## PowerShell Gallery docs sync', '')
if ($summaryRows.Count -gt 0) {
    $body += '| Module | Previous version | New version |'
    $body += '|---|---|---|'
    $body += $summaryRows
} else {
    $body += 'No module releases detected - command reference docs refreshed in place where needed.'
}
if ($script:BootstrappedModules.Count -gt 0) {
    $body += ''
    $body += '### New modules - follow-up needed'
    foreach ($m in $script:BootstrappedModules) {
        $body += "- [ ] Add ""$m"" to docs/modules/index.md"
    }
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PrBodyPath) | Out-Null
Set-Content -Path $PrBodyPath -Value ($body -join "`n") -Encoding utf8

Write-Host 'Done.'
