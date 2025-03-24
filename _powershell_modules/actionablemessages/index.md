---
layout: page
title: ActionableMessages PowerShell Module
permalink: /modules/actionablemessages/
---

# ActionableMessages PowerShell Module

A PowerShell module for creating Microsoft Actionable Messages.

## Installation

`powershell
Install-Module -Name ActionableMessages -Scope CurrentUser
``r

## Quick Start

`powershell
$card = New-AMCard -ThemeColor "#0078D7"
Add-AMElement -InputObject $card -Element (New-AMTextBlock -Text "Hello, World!")
$jsonCard = Export-AMCard -Card $card
``r

## Command Reference

- [`Add-AMElement`](commands/Add-AMElement/)
- [`Export-AMCard`](commands/Export-AMCard/)
- [`Export-AMCardForEmail`](commands/Export-AMCardForEmail/)
- [`New-AMActionSet`](commands/New-AMActionSet/)
- [`New-AMCard`](commands/New-AMCard/)
- [`New-AMChoice`](commands/New-AMChoice/)
- [`New-AMChoiceSetInput`](commands/New-AMChoiceSetInput/)
- [`New-AMColumn`](commands/New-AMColumn/)
- [`New-AMColumnSet`](commands/New-AMColumnSet/)
- [`New-AMContainer`](commands/New-AMContainer/)
- [`New-AMDateInput`](commands/New-AMDateInput/)
- [`New-AMExecuteAction`](commands/New-AMExecuteAction/)
- [`New-AMFact`](commands/New-AMFact/)
- [`New-AMFactSet`](commands/New-AMFactSet/)
- [`New-AMImage`](commands/New-AMImage/)
- [`New-AMImageSet`](commands/New-AMImageSet/)
- [`New-AMNumberInput`](commands/New-AMNumberInput/)
- [`New-AMOpenUrlAction`](commands/New-AMOpenUrlAction/)
- [`New-AMShowCardAction`](commands/New-AMShowCardAction/)
- [`New-AMTextBlock`](commands/New-AMTextBlock/)
- [`New-AMTextInput`](commands/New-AMTextInput/)
- [`New-AMTimeInput`](commands/New-AMTimeInput/)
- [`New-AMToggleInput`](commands/New-AMToggleInput/)
- [`New-AMToggleVisibilityAction`](commands/New-AMToggleVisibilityAction/)
