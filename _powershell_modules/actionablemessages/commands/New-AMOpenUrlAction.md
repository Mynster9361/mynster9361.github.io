---
layout: page
title: New-AMOpenUrlAction
permalink: /modules/actionablemessages/commands/New-AMOpenUrlAction/
---

# New-AMOpenUrlAction

## SYNOPSIS
Creates an OpenUrl Action for an Adaptive Card.

## SYNTAX

```powershell
New-AMOpenUrlAction [-Title] <String> [-Url] <String> [-Id <String>] [-Tooltip <String>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-AMOpenUrlAction` function generates an `Action.OpenUrl` element for an Adaptive Card.
This action opens a specified URL in the user's web browser when the button is clicked.
It is commonly used to provide links to external resources, documentation, or related web pages
from within your Adaptive Card.

Unlike other action types, `Action.OpenUrl` does not require any special permissions or registrations,
making it one of the simplest and most versatile actions in Adaptive Cards.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a simple "Learn More" button
$learnMoreAction = New-AMOpenUrlAction -Title "Learn More" -Url "https://example.com"
Add-AMElement -Card $card -Element (New-AMActionSet -Actions @($learnMoreAction))
```


### EXAMPLE 2
```powershell
# Create a button with custom ID and tooltip
$docsButton = New-AMOpenUrlAction -Title "View Documentation" `
    -Url "https://docs.contoso.com/project" `
    -Id "docs-button" `
    -Tooltip "Open the project documentation in a new browser window"
```


### EXAMPLE 3
```powershell
# Creating multiple URL actions in an ActionSet
$actions = @(
    (New-AMOpenUrlAction -Title "Product Page" -Url "https://contoso.com/products"),
    (New-AMOpenUrlAction -Title "Support" -Url "https://contoso.com/support")
)
$actionSet = New-AMActionSet -Id "links" -Actions $actions
```

## PARAMETERS

### -Title
The text to display on the action button.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Url
The URL to open when the button is clicked. This must be a valid URL, including the protocol
(e.g., "https://").

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
(Optional) A unique identifier for the action. If not specified, a new GUID will be generated automatically.
The ID can be useful when you need to reference this action programmatically.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tooltip
(Optional) Tooltip text to display when the user hovers over the button. Use this to provide additional
context about what will happen when the button is clicked.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to `New-AMOpenUrlAction`.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the `Action.OpenUrl` element.

## NOTES
- `Action.OpenUrl` is one of the most commonly used action types in Adaptive Cards.
- Unlike other action types, `Action.OpenUrl` does not require any special permissions
  or registrations since it simply opens a URL in the user's browser.
- In Outlook, the URL will typically open in the user's default web browser.

## RELATED LINKS
- [https://adaptivecards.io/explorer/Action.OpenUrl.html](https://adaptivecards.io/explorer/Action.OpenUrl.html)
