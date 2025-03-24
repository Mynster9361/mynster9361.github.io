---
layout: page
title: New-AMChoiceSetInput
permalink: /modules/actionablemessages/commands/New-AMChoiceSetInput/
---

# New-AMChoiceSetInput

## SYNOPSIS
Creates a ChoiceSetInput element for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a ChoiceSetInput element for an Adaptive Card.
.DESCRIPTION
Creates a ChoiceSetInput element that allows users to select from a list of options.
This element can be rendered as a dropdown list, radio button group, or checkbox list
depending on the Style and IsMultiSelect parameters.
ChoiceSetInputs are useful for collecting structured input from users, such as
selecting preferences, categories, options, or making decisions from predefined choices.
.PARAMETER Id
A unique identifier for the input element. This ID will be used when the card is submitted
to identify the selected value(s).
.PARAMETER Label
Optional text label to display above the input field, describing what the input is for.
.PARAMETER Choices
An array of choice objects created using the New-AMChoice function. Each choice should
have a title (displayed text) and value (data submitted when selected).
.PARAMETER IsMultiSelect
Determines whether multiple choices can be selected.
When set to $true, the input allows multiple selections (checkboxes).
When set to $false (default), only a single option can be selected (dropdown or radio buttons).
.PARAMETER Style
Controls how the choices are displayed:
- "compact": Renders as a dropdown list (default)
- "expanded": Renders as a set of radio buttons or checkboxes
- "filtered": Renders as a dropdown with filtering capability (for long lists)
.PARAMETER Value
Optional default selected value(s). For single-select, this should match the value of one choice.
For multi-select, this should be a comma-separated list of values.
.PARAMETER Placeholder
Optional text to display when no selection has been made. Only applicable for dropdown style.
.PARAMETER IsVisible
Controls whether the input is initially visible or hidden.
.EXAMPLE
# Create a simple dropdown list
$colorChoices = @(
New-AMChoice -Title "Red" -Value "red"
New-AMChoice -Title "Green" -Value "green"
New-AMChoice -Title "Blue" -Value "blue"
)
$colorDropdown = New-AMChoiceSetInput -Id "color" -Label "Select a color:" -Choices $colorChoices
Add-AMElement -Card $card -Element $colorDropdown
.EXAMPLE
# Create a radio button group with a default selection
$priorityChoices = @(
New-AMChoice -Title "High" -Value "high"
New-AMChoice -Title "Medium" -Value "medium"
New-AMChoice -Title "Low" -Value "low"
)
$priorityInput = New-AMChoiceSetInput -Id "priority" -Label "Priority level:" `
-Choices $priorityChoices -Style "expanded" -Value "medium"
.EXAMPLE
# Create a multi-select checkbox list
$toppingsChoices = @(
New-AMChoice -Title "Cheese" -Value "cheese"
New-AMChoice -Title "Pepperoni" -Value "pepperoni"
New-AMChoice -Title "Mushrooms" -Value "mushrooms"
New-AMChoice -Title "Onions" -Value "onions"
New-AMChoice -Title "Peppers" -Value "peppers"
)
$toppingsInput = New-AMChoiceSetInput -Id "toppings" -Label "Select toppings:" `
-Choices $toppingsChoices -IsMultiSelect $true -Style "expanded"
.INPUTS
None. You cannot pipe input to New-AMChoiceSetInput.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the ChoiceSetInput element.
.NOTES
The ChoiceSetInput is one of the most versatile input elements in Adaptive Cards.
Style recommendations:
- Use "compact" (dropdown) when you have many options or limited space
- Use "expanded" (radio/checkbox) when you have fewer options (2-5) and want them all visible
- Use "filtered" when you have a long list that users might need to search through
Remember that the value submitted will be the "value" property of the choice, not the "title"
that is displayed to the user.
.LINK
https://adaptivecards.io/explorer/Input.ChoiceSet.html
#>
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)]
[string]$Id,
[Parameter()]
[string]$Label,
[Parameter(Mandatory = $true)]
[array]$Choices,
[Parameter()]
[bool]$IsMultiSelect = $false,
[Parameter()]
[ValidateSet("compact", "expanded", "filtered")]
[string]$Style = "compact",
[Parameter()]
[string]$Value,
[Parameter()]
[string]$Placeholder,
[Parameter()]
[bool]$IsVisible
)
$choiceSet = [ordered]@{
'type' = 'Input.ChoiceSet'
'id' = $Id
'choices' = $Choices
'style' = $Style
'isMultiSelect' = $IsMultiSelect
}
if ($Label) { $choiceSet.label = $Label }
if ($Value) { $choiceSet.value = $Value }
if ($Placeholder) { $choiceSet.placeholder = $Placeholder }
if ($PSBoundParameters.ContainsKey('IsVisible')) { $choiceSet.isVisible = $IsVisible }
return $choiceSet

``r

## DESCRIPTION
Creates a ChoiceSetInput element that allows users to select from a list of options.
This element can be rendered as a dropdown list, radio button group, or checkbox list
depending on the Style and IsMultiSelect parameters.

ChoiceSetInputs are useful for collecting structured input from users, such as
selecting preferences, categories, options, or making decisions from predefined choices.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple dropdown list
$colorChoices = @(
    New-AMChoice -Title "Red" -Value "red"
    New-AMChoice -Title "Green" -Value "green"
    New-AMChoice -Title "Blue" -Value "blue"
)
$colorDropdown = New-AMChoiceSetInput -Id "color" -Label "Select a color:" -Choices $colorChoices
Add-AMElement -Card $card -Element $colorDropdown
``r

    

### EXAMPLE 2
`powershell
# Create a radio button group with a default selection
$priorityChoices = @(
    New-AMChoice -Title "High" -Value "high"
    New-AMChoice -Title "Medium" -Value "medium"
    New-AMChoice -Title "Low" -Value "low"
)
$priorityInput = New-AMChoiceSetInput -Id "priority" -Label "Priority level:" `
    -Choices $priorityChoices -Style "expanded" -Value "medium"
``r

    

### EXAMPLE 3
`powershell
# Create a multi-select checkbox list
$toppingsChoices = @(
    New-AMChoice -Title "Cheese" -Value "cheese"
    New-AMChoice -Title "Pepperoni" -Value "pepperoni"
    New-AMChoice -Title "Mushrooms" -Value "mushrooms"
    New-AMChoice -Title "Onions" -Value "onions"
    New-AMChoice -Title "Peppers" -Value "peppers"
)
$toppingsInput = New-AMChoiceSetInput -Id "toppings" -Label "Select toppings:" `
    -Choices $toppingsChoices -IsMultiSelect $true -Style "expanded"
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
A unique identifier for the input element. This ID will be used when the card is submitted
to identify the selected value(s).

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

### -Label
Optional text label to display above the input field, describing what the input is for.

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

### -Choices
An array of choice objects created using the New-AMChoice function. Each choice should
have a title (displayed text) and value (data submitted when selected).

`yaml
Type: Array
Parameter Sets: (All)
Aliases: None

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -IsMultiSelect
Determines whether multiple choices can be selected.
When set to $true, the input allows multiple selections (checkboxes).
When set to $false (default), only a single option can be selected (dropdown or radio buttons).

`yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Style
Controls how the choices are displayed:
- "compact": Renders as a dropdown list (default)
- "expanded": Renders as a set of radio buttons or checkboxes
- "filtered": Renders as a dropdown with filtering capability (for long lists)

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Value
Optional default selected value(s). For single-select, this should match the value of one choice.
For multi-select, this should be a comma-separated list of values.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Placeholder
Optional text to display when no selection has been made. Only applicable for dropdown style.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -IsVisible
Controls whether the input is initially visible or hidden.

`yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMChoiceSetInput.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the ChoiceSetInput element.


## NOTES
The ChoiceSetInput is one of the most versatile input elements in Adaptive Cards.

Style recommendations:
- Use "compact" (dropdown) when you have many options or limited space
- Use "expanded" (radio/checkbox) when you have fewer options (2-5) and want them all visible
- Use "filtered" when you have a long list that users might need to search through

Remember that the value submitted will be the "value" property of the choice, not the "title"
that is displayed to the user.

## RELATED LINKS
[](https://adaptivecards.io/explorer/Input.ChoiceSet.html)

