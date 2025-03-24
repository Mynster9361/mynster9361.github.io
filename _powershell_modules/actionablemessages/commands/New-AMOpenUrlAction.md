---
layout: page
title: New-AMOpenUrlAction
permalink: /modules/actionablemessages/commands/New-AMOpenUrlAction/
---

---
external help file: ActionableMessages-help.xml
Module Name: ActionableMessages
online version: https://adaptivecards.io/explorer/Action.OpenUrl.html
schema: 2.0.0
---

# New-AMOpenUrlAction

## SYNOPSIS
Creates an OpenUrl Action for an Adaptive Card.

## SYNTAX

```
New-AMOpenUrlAction [-Title] <String> [-Url] <String> [[-Id] <String>] [[-Tooltip] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```powershell

## DESCRIPTION
Creates an Action.OpenUrl element that opens a URL in a web browser when clicked.
This action is commonly used to provide links to external resources, documentation,
or related web pages from within your Adaptive Card.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a simple "Learn More" button
$learnMoreAction = New-AMOpenUrlAction -Title "Learn More" -Url "https://example.com"
Add-AMElement -Card $card -Element (New-AMActionSet -Actions @($learnMoreAction))
```powershell

### EXAMPLE 2
```powershell
# Create a button with custom ID and tooltip
$docsButton = New-AMOpenUrlAction -Title "View Documentation" `
    -Url "https://docs.contoso.com/project" `
    -Id "docs-button" `
    -Tooltip "Open the project documentation in a new browser window"
```powershell

### EXAMPLE 3
```powershell
# Creating multiple URL actions in an ActionSet
$actions = @(
    (New-AMOpenUrlAction -Title "Product Page" -Url "https://contoso.com/products"),
    (New-AMOpenUrlAction -Title "Support" -Url "https://contoso.com/support")
)
$actionSet = New-AMActionSet -Id "links" -Actions $actions
```powershell

## PARAMETERS

### -Title
The title text to display on the action button.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```powershell

### -Url
The URL to open when the button is clicked.
This must be a valid URL including
the protocol (e.g., "https://").

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```powershell

### -Id
Optional unique identifier for the action.
If not specified, a new GUID will be
generated automatically.
The ID can be useful when you need to reference this
action programmatically.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: [guid]::NewGuid().ToString()
Accept pipeline input: False
Accept wildcard characters: False
```powershell

### -Tooltip
Optional tooltip text to display when the user hovers over the button.
Use this to provide additional context about what will happen when clicked.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```powershell

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```powershell

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS

### None. You cannot pipe input to New-AMOpenUrlAction.
## OUTPUTS

### System.Collections.Hashtable
### Returns a hashtable representing the Action.OpenUrl element.
## NOTES
Action.OpenUrl is one of the most commonly used action types in Adaptive Cards.
Unlike other action types, Action.OpenUrl doesn't require any special permissions
or registrations since it simply opens a URL in the user's browser.

In Outlook, the URL will typically open in the user's default web browser.

## RELATED LINKS

[https://adaptivecards.io/explorer/Action.OpenUrl.html](https://adaptivecards.io/explorer/Action.OpenUrl.html)


