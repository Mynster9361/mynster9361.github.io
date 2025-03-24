---
layout: page
title: New-AMShowCardAction
permalink: /modules/actionablemessages/commands/New-AMShowCardAction/
---

# New-AMShowCardAction

## SYNOPSIS
Creates a ShowCard Action for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a ShowCard Action for an Adaptive Card.
.DESCRIPTION
Creates an Action.ShowCard element that reveals a nested card when clicked.
This action is useful for progressive disclosure of information - showing additional
details, forms, or content without navigating away from the current view or requiring
another HTTP request.
.PARAMETER Title
The text to display on the action button that will reveal the card.
.PARAMETER Id
Optional unique identifier for the action. If not specified, a new GUID will be
generated automatically. The ID can be useful when referencing this action from
other parts of your card.
.PARAMETER Card
Optional pre-configured card to show when the button is clicked. If not provided,
an empty card will be created with default properties.
.EXAMPLE
# Create a ShowCard action with an empty card
$showAction = New-AMShowCardAction -Title "Show Details"
.EXAMPLE
# Create a ShowCard action with a pre-configured card
$detailCard = New-AMCard -OriginatorId "nested-card"
Add-AMElement -Card $detailCard -Element (New-AMTextBlock -Text "These are additional details" -Wrap $true)
$showAction = New-AMShowCardAction -Title "Show Details" -Card $detailCard
.EXAMPLE
# Create a ShowCard action with a form inside
$feedbackCard = New-AMCard -OriginatorId "feedback-card"
Add-AMElement -Card $feedbackCard -Element (New-AMTextBlock -Text "Please provide your feedback:")
Add-AMElement -Card $feedbackCard -Element (New-AMTextInput -Id "comments" -Placeholder "Type your comments here" -IsMultiline $true)
# Create submit button for the nested card
$submitAction = New-AMSubmitAction -Title "Submit Feedback" -Data @{ action = "feedback" }
$actionSet = New-AMActionSet -Actions @($submitAction)
Add-AMElement -Card $feedbackCard -Element $actionSet
$feedbackAction = New-AMShowCardAction -Title "Provide Feedback" -Id "feedback-form" -Card $feedbackCard
#>
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)]
[string]$Title,
[Parameter()]
[string]$Id = [guid]::NewGuid().ToString(),
[Parameter()]
[hashtable]$Card
)
# Create default empty card if none provided
if (-not $Card) {
# Create a simple card - we use a placeholder originator ID since it's a nested card
$Card = New-AMCard -OriginatorId "show-card" -Version "1.2"
# Remove properties not needed for a show card
$Card.Remove('originator')
$Card.Remove('hideOriginalBody')
$Card.Remove('actions')
# Add padding property specific to show cards
$Card.padding = 'None'
}
$action = [ordered]@{
'type' = 'Action.ShowCard'
'id' = $Id
'title' = $Title
'card' = $Card
}
return $action

``r

## DESCRIPTION
Creates an Action.ShowCard element that reveals a nested card when clicked.
This action is useful for progressive disclosure of information - showing additional
details, forms, or content without navigating away from the current view or requiring
another HTTP request.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a ShowCard action with an empty card
$showAction = New-AMShowCardAction -Title "Show Details"
``r

    

### EXAMPLE 2
`powershell
# Create a ShowCard action with a pre-configured card
$detailCard = New-AMCard -OriginatorId "nested-card"
Add-AMElement -Card $detailCard -Element (New-AMTextBlock -Text "These are additional details" -Wrap $true)
$showAction = New-AMShowCardAction -Title "Show Details" -Card $detailCard
``r

    

### EXAMPLE 3
`powershell
# Create a ShowCard action with a form inside
$feedbackCard = New-AMCard -OriginatorId "feedback-card"
Add-AMElement -Card $feedbackCard -Element (New-AMTextBlock -Text "Please provide your feedback:")
Add-AMElement -Card $feedbackCard -Element (New-AMTextInput -Id "comments" -Placeholder "Type your comments here" -IsMultiline $true)
``r

# Create submit button for the nested card
$submitAction = New-AMSubmitAction -Title "Submit Feedback" -Data @{ action = "feedback" }
$actionSet = New-AMActionSet -Actions @($submitAction)
Add-AMElement -Card $feedbackCard -Element $actionSet

$feedbackAction = New-AMShowCardAction -Title "Provide Feedback" -Id "feedback-form" -Card $feedbackCard    

## PARAMETERS

### -Debug


`yaml
Type: Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -ErrorAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -ErrorVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -InformationAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -InformationVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -OutBuffer


`yaml
Type: Int32
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -OutVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -PipelineVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -ProgressAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Verbose


`yaml
Type: Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -WarningAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -WarningVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Title
The text to display on the action button that will reveal the card.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Id
Optional unique identifier for the action. If not specified, a new GUID will be
generated automatically. The ID can be useful when referencing this action from
other parts of your card.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Card
Optional pre-configured card to show when the button is clicked. If not provided,
an empty card will be created with default properties.

`yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### 


## OUTPUTS
### 


