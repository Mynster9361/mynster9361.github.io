---
layout: page
title: New-AMShowCardAction
permalink: /modules/actionablemessages/commands/New-AMShowCardAction/
---

# New-AMShowCardAction

## SYNOPSIS
Creates a ShowCard Action for an Adaptive Card.

## SYNTAX

```powershell
New-AMShowCardAction [-Title] <String> [-Id <String>] [-Card <Hashtable>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates an Action.ShowCard element that reveals a nested card when clicked.
This action is useful for progressive disclosure of information - showing additional
details, forms, or content without navigating away from the current view or requiring
another HTTP request.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a ShowCard action with an empty card
$showAction = New-AMShowCardAction -Title "Show Details"
```


### EXAMPLE 2
```powershell
# Create a ShowCard action with a pre-configured card
$detailCard = New-AMCard -OriginatorId "nested-card"
Add-AMElement -Card $detailCard -Element (New-AMTextBlock -Text "These are additional details" -Wrap $true)
$showAction = New-AMShowCardAction -Title "Show Details" -Card $detailCard
```


### EXAMPLE 3
```powershell
# Create a ShowCard action with a form inside
$feedbackCard = New-AMCard -OriginatorId "feedback-card"
Add-AMElement -Card $feedbackCard -Element (New-AMTextBlock -Text "Please provide your feedback:")
Add-AMElement -Card $feedbackCard -Element (New-AMTextInput -Id "comments" -Placeholder "Type your comments here" -IsMultiline $true)
```

#### Example explanation
```powershell
# Create submit button for the nested card
$submitAction = New-AMSubmitAction -Title "Submit Feedback" -Data @{ action = "feedback" }
$actionSet = New-AMActionSet -Actions @($submitAction)
Add-AMElement -Card $feedbackCard -Element $actionSet

$feedbackAction = New-AMShowCardAction -Title "Provide Feedback" -Id "feedback-form" -Card $feedbackCard
```
## PARAMETERS

### -Title
The text to display on the action button that will reveal the card.

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

### -Id
Optional unique identifier for the action. If not specified, a new GUID will be
generated automatically. The ID can be useful when referencing this action from
other parts of your card.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Card
Optional pre-configured card to show when the button is clicked. If not provided,
an empty card will be created with default properties.

```yaml
Type: Collections.Hashtable
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
### None

## OUTPUTS
### None
