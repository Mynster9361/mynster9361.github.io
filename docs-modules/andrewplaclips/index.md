---
title: andrewplaclips PowerShell Module
sidebar_position: 1
---

# andrewplaclips PowerShell Module

A PowerShell module that lets you play the best sound bites of the one and only **Andrew Pla** straight from your terminal.

## Installation

```powershell
Install-Module -Name andrewplaclips -Scope CurrentUser
```

## Usage

List all available clips:

```powershell
Get-APlaAudio
```

Get the full path to a specific clip:

```powershell
Get-APlaAudio -AudioName 'GG'
```

Play a clip:

```powershell
Invoke-APlaAudio -AudioName 'GG'
```

Play all clips in sequence:

```powershell
Get-APlaAudio | ForEach-Object { Invoke-APlaAudio -AudioName $_ }
```

## Available Clips

| Name          | Command                                     |
| ------------- | ------------------------------------------- |
| bait          | `Invoke-APlaAudio -AudioName bait`          |
| bumpIt        | `Invoke-APlaAudio -AudioName bumpIt`        |
| FAFOFTW       | `Invoke-APlaAudio -AudioName FAFOFTW`       |
| gamers        | `Invoke-APlaAudio -AudioName gamers`        |
| GG            | `Invoke-APlaAudio -AudioName GG`            |
| goofy         | `Invoke-APlaAudio -AudioName goofy`         |
| needCash      | `Invoke-APlaAudio -AudioName needCash`      |
| noclue        | `Invoke-APlaAudio -AudioName noclue`        |
| noclue2       | `Invoke-APlaAudio -AudioName noclue2`       |
| notKidding    | `Invoke-APlaAudio -AudioName notKidding`    |
| stuckHead     | `Invoke-APlaAudio -AudioName stuckHead`     |
| uhh           | `Invoke-APlaAudio -AudioName uhh`           |
| whatDidYouSay | `Invoke-APlaAudio -AudioName whatDidYouSay` |

## Requirements

- PowerShell 7+
- Windows OS (playback uses `System.Media.SoundPlayer`)