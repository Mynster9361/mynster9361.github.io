---
layout: page
title: ActionableMessages PowerShell Module
permalink: /modules/actionablemessages/
---
A PowerShell module for creating Microsoft Actionable Messages.
## Installation
```powershell
Install-Module -Name ActionableMessages -Scope CurrentUser
```
## Quick Start
```powershell
$card = New-AMCard -ThemeColor "#0078D7"
Add-AMElement -InputObject $card -Element (New-AMTextBlock -Text "Hello, World!")
$jsonCard = Export-AMCard -Card $card
```
## Command Reference
- Add-AMElement/)
- Export-AMCard/)
- Export-AMCardForEmail/)
- New-AMActionSet/)
- New-AMCard/)
- New-AMChoice/)
- New-AMChoiceSetInput/)
- New-AMColumn/)
- New-AMColumnSet/)
- New-AMContainer/)
- New-AMDateInput/)
- New-AMExecuteAction/)
- New-AMFact/)
- New-AMFactSet/)
- New-AMImage/)
- New-AMImageSet/)
- New-AMNumberInput/)
- New-AMOpenUrlAction/)
- New-AMShowCardAction/)
- New-AMTextBlock/)
- New-AMTextInput/)
- New-AMTimeInput/)
- New-AMToggleInput/)
- New-AMToggleVisibilityAction/)
