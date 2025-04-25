---
layout: page
title: New-AMToggleVisibilityAction
permalink: /modules/actionablemessages/commands/New-AMToggleVisibilityAction/
---

# New-AMToggleVisibilityAction

## SYNOPSIS
Creates a ToggleVisibility Action for an Adaptive Card.

## SYNTAX

```powershell
New-AMToggleVisibilityAction [-Title] <String> [-TargetElements] <String[]> [-Id <String>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-AMToggleVisibilityAction` function generates an `Action.ToggleVisibility` element for an Adaptive Card.
This action allows you to toggle the visibility of one or more elements in the card when the button is clicked.
It is commonly used for creating interactive cards with expandable/collapsible sections, "Read more" functionality,
tabbed interfaces, or multi-step forms.

This action is client-side only and does not require server communication, making it ideal for lightweight
interactivity within Adaptive Cards.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a simple toggle action for one element
$toggleAction = New-AMToggleVisibilityAction -Title "Show Details" -TargetElements @("details-section")
```


### EXAMPLE 2
```powershell
# Toggle multiple elements with one button
$toggleAction = New-AMToggleVisibilityAction -Title "Toggle Sections" `
    -TargetElements @("section1", "section2", "section3") `
    -Id "toggle-all-sections"
```


### EXAMPLE 3
```powershell
# Creating a tab-like interface with toggle actions
$tab1Content = New-AMContainer -Id "tab1-content" -Items @(
    (New-AMTextBlock -Text "This is the content of tab 1" -Wrap $true)
)
$tab2Content = New-AMContainer -Id "tab2-content" -Items @(
    (New-AMTextBlock -Text "This is the content of tab 2" -Wrap $true)
) -IsVisible $false
```

#### Example explanation
```powershell
# Add content containers to card
Add-AMElement -Card $card -Element $tab1Content
Add-AMElement -Card $card -Element $tab2Content

# Create toggle actions for tabs
$tab1Action = New-AMToggleVisibilityAction -Title "Tab 1" -TargetElements @("tab1-content", "tab2-content")
$tab2Action = New-AMToggleVisibilityAction -Title "Tab 2" -TargetElements @("tab1-content", "tab2-content")

# Add actions to an ActionSet
$tabActionSet = New-AMActionSet -Actions @($tab1Action, $tab2Action)
Add-AMElement -Card $card -Element $tabActionSet
```
## PARAMETERS

### -Title
The text to display on the action button that will trigger the visibility toggle.

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

### -TargetElements
An array of element IDs to toggle visibility. When the action is triggered, these elements will switch
between visible and hidden states. The elements must have valid IDs defined in the card.

```yaml
Type: String[]
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
The ID can be useful when referencing this action programmatically or from other parts of your card.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to `New-AMToggleVisibilityAction`.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the `Action.ToggleVisibility` element.

## NOTES
- `Action.ToggleVisibility` is extremely useful for creating interactive cards without requiring
  server communication. It works well for:
    - Creating expandable/collapsible sections
    - Implementing "Read more" functionality
    - Building simple wizards or multi-step forms
    - Showing and hiding form fields based on previous selections
    - Creating tab-like interfaces within cards
- Elements referenced in `TargetElements` must have valid IDs defined in the card.

## RELATED LINKS
- [https://adaptivecards.io/explorer/Action.ToggleVisibility.html](https://adaptivecards.io/explorer/Action.ToggleVisibility.html)
