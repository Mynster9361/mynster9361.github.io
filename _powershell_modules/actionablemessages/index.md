---
layout: page
title: ActionableMessages PowerShell Module
permalink: /modules/actionablemessages/
---

A PowerShell module for creating Microsoft Actionable Messages.

## Installation

`powershell
Install-Module -Name ActionableMessages -Scope CurrentUser
`

## Quick Start

`powershell
 = New-AMCard -ThemeColor "#0078D7"
Add-AMElement -InputObject  -Element (New-AMTextBlock -Text "Hello, World!")
 = Export-AMCard -Card 
`

## Command Reference

- [`Add-AMElement`](commands/Add-AMElement.html) - [`Export-AMCard`](commands/Export-AMCard.html) - [`Export-AMCardForEmail`](commands/Export-AMCardForEmail.html) - [`New-AMActionSet`](commands/New-AMActionSet.html) - [`New-AMCard`](commands/New-AMCard.html) - [`New-AMChoice`](commands/New-AMChoice.html) - [`New-AMChoiceSetInput`](commands/New-AMChoiceSetInput.html) - [`New-AMColumn`](commands/New-AMColumn.html) - [`New-AMColumnSet`](commands/New-AMColumnSet.html) - [`New-AMContainer`](commands/New-AMContainer.html) - [`New-AMDateInput`](commands/New-AMDateInput.html) - [`New-AMExecuteAction`](commands/New-AMExecuteAction.html) - [`New-AMFact`](commands/New-AMFact.html) - [`New-AMFactSet`](commands/New-AMFactSet.html) - [`New-AMImage`](commands/New-AMImage.html) - [`New-AMImageSet`](commands/New-AMImageSet.html) - [`New-AMNumberInput`](commands/New-AMNumberInput.html) - [`New-AMOpenUrlAction`](commands/New-AMOpenUrlAction.html) - [`New-AMShowCardAction`](commands/New-AMShowCardAction.html) - [`New-AMTextBlock`](commands/New-AMTextBlock.html) - [`New-AMTextInput`](commands/New-AMTextInput.html) - [`New-AMTimeInput`](commands/New-AMTimeInput.html) - [`New-AMToggleInput`](commands/New-AMToggleInput.html) - [`New-AMToggleVisibilityAction`](commands/New-AMToggleVisibilityAction.html)
