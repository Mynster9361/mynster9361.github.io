---
layout: page
title: New-AMActionSet
permalink: /modules/actionablemessages/commands/New-AMActionSet/
---

# New-AMActionSet

## SYNOPSIS
Creates an ActionSet element for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates an ActionSet element for an Adaptive Card.
.DESCRIPTION
Creates an ActionSet element that can contain multiple actions (buttons) and be added to a card's body.
ActionSets group related actions together and allow you to place action buttons throughout your card,
not just at the bottom.
.PARAMETER Id
Optional unique identifier for the ActionSet. Useful when you need to reference or manipulate
the ActionSet programmatically or with visibility toggles.
.PARAMETER Actions
An array of action objects to include in the ActionSet. These should be created using functions like
New-AMOpenUrlAction, New-AMSubmitAction, New-AMExecuteAction, New-AMShowCardAction, or New-AMToggleVisibilityAction.
.PARAMETER Padding
Optional padding value to apply around the ActionSet.
Valid values include: "None", "Small", "Default", "Large"
.EXAMPLE
# Create a simple ActionSet with two actions
$openUrlAction = New-AMOpenUrlAction -Title "Visit Website" -Url "https://example.com"
$executeAction = New-AMExecuteAction -Title "Approve" -Verb "POST" -Url "https://api.example.com/approve" -Body '{"id": "12345"}'
$actionSet = New-AMActionSet -Id "main-actions" -Actions @($openUrlAction, $submitAction)
Add-AMElement -Card $card -Element $actionSet
.EXAMPLE
# Create an ActionSet with no padding containing an execute action
$executeAction = New-AMExecuteAction -Title "Approve" -Verb "POST" -Url "https://api.example.com/approve"
$actionSet = New-AMActionSet -Id "approval-actions" -Actions @($executeAction) -Padding "None"
Add-AMElement -Card $card -Element $actionSet -ContainerId "container1"
.INPUTS
None. You cannot pipe input to New-AMActionSet.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the ActionSet element.
.NOTES
ActionSets provide a way to group multiple actions together and place them anywhere within your card's body,
not just at the bottom of the card. This gives you greater flexibility in designing your card's layout.
For Outlook Actionable Messages, action buttons placed in ActionSets render better than those
in the card's top-level actions property.
.LINK
https://adaptivecards.io/explorer/ActionSet.html
#>
[CmdletBinding()]
param (
[Parameter()]
[string]$Id,
[Parameter(Mandatory = $true)]
[array]$Actions,
[Parameter()]
[string]$Padding
)
# Create the ActionSet object
$actionSet = [ordered]@{
'type' = 'ActionSet'
'actions' = $Actions  # Directly assign the array
'id' = $Id
}
# Add optional padding
if ($Padding) {
$actionSet.padding = $Padding
}
return $actionSet

``r

## DESCRIPTION
Creates an ActionSet element that can contain multiple actions (buttons) and be added to a card's body.
ActionSets group related actions together and allow you to place action buttons throughout your card,
not just at the bottom.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple ActionSet with two actions
$openUrlAction = New-AMOpenUrlAction -Title "Visit Website" -Url "https://example.com"
$executeAction = New-AMExecuteAction -Title "Approve" -Verb "POST" -Url "https://api.example.com/approve" -Body '{"id": "12345"}'
``r

$actionSet = New-AMActionSet -Id "main-actions" -Actions @($openUrlAction, $submitAction)
Add-AMElement -Card $card -Element $actionSet    

### EXAMPLE 2
`powershell
# Create an ActionSet with no padding containing an execute action
$executeAction = New-AMExecuteAction -Title "Approve" -Verb "POST" -Url "https://api.example.com/approve"
$actionSet = New-AMActionSet -Id "approval-actions" -Actions @($executeAction) -Padding "None"
Add-AMElement -Card $card -Element $actionSet -ContainerId "container1"
``r

    

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

### -Id
Optional unique identifier for the ActionSet. Useful when you need to reference or manipulate
the ActionSet programmatically or with visibility toggles.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Actions
An array of action objects to include in the ActionSet. These should be created using functions like
New-AMOpenUrlAction, New-AMSubmitAction, New-AMExecuteAction, New-AMShowCardAction, or New-AMToggleVisibilityAction.

`yaml
Type: Array
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Padding
Optional padding value to apply around the ActionSet.
Valid values include: "None", "Small", "Default", "Large"

`yaml
Type: String
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
### None. You cannot pipe input to New-AMActionSet.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the ActionSet element.


## NOTES
ActionSets provide a way to group multiple actions together and place them anywhere within your card's body,
not just at the bottom of the card. This gives you greater flexibility in designing your card's layout.

For Outlook Actionable Messages, action buttons placed in ActionSets render better than those
in the card's top-level actions property.

## RELATED LINKS
[](https://adaptivecards.io/explorer/ActionSet.html)

