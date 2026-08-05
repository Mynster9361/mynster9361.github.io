<#
.SYNOPSIS
Shared functions for the PSGallery -> PlatyPS -> Docusaurus docs pipeline. Dot-sourced
by Sync-Docs.ps1 (routine sync of the current release) and Backfill-Docs.ps1 (one-time
catch-up of historical releases not yet represented as Docusaurus versions).

.DESCRIPTION
Every function takes -RepoRoot and (where relevant) -DryRun explicitly rather than
relying on the caller script's variables being in scope, since dot-sourcing into two
different top-level scripts makes ambient-scope lookups fragile.
#>

function Get-ModuleIdSlug {
    param([Parameter(Mandatory)][string]$Name)
    ($Name.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
}

function Get-GalleryModuleNames {
    param([Parameter(Mandatory)][string]$GalleryProfile)
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

function Get-GalleryModuleVersions {
    <# All published versions of a module, ascending. #>
    param([Parameter(Mandatory)][string]$PsGalleryId)
    $results = Find-PSResource -Name $PsGalleryId -Version '*' -Repository PSGallery -ErrorAction Stop
    $results |
        ForEach-Object { $_.Version.ToString() } |
        Sort-Object -Unique -Property { [version](($_ -split '-')[0]) }
}

function Get-CutVersions {
    <# Version labels already snapshotted for a plugin instance, read from its
       <id>_versions.json (empty array if the module has never been versioned). #>
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][string]$RepoRoot)
    $versionsPath = Join-Path $RepoRoot "${Id}_versions.json"
    if (-not (Test-Path $versionsPath)) { return @() }
    @(Get-Content -Raw -Path $versionsPath | ConvertFrom-Json)
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
    param(
        [Parameter(Mandatory)]$Module,
        [Parameter(Mandatory)]$Info,
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )
    $indexPath = Join-Path $RepoRoot $Module.docsPath 'index.md'
    if (Test-Path $indexPath) { return $false } # existing content - never touched by automation
    Write-Host "Bootstrapping new module doc: $($Module.displayName)"
    if ($DryRun) { return $true }
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
    return $true
}

function Invoke-PlatyPSGeneration {
    param(
        [Parameter(Mandatory)]$Module,
        [Parameter(Mandatory)][string]$Version,
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )
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

function Invoke-DocsVersionCut {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Version,
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )
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

function Save-Manifest {
    param(
        [Parameter(Mandatory)]$Manifest,
        [Parameter(Mandatory)][string]$ManifestPath,
        [switch]$DryRun
    )
    if ($DryRun) { return }
    $Manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $ManifestPath -Encoding utf8
}
