---
layout: page
title: New-AMDateInput
permalink: /modules/actionablemessages/commands/New-AMDateInput/
---

# New-AMDateInput

## SYNOPSIS
Creates a Date Input element for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a Date Input element for an Adaptive Card.
.DESCRIPTION
Creates an Input.Date element that allows users to select a date from a calendar interface.
Date inputs are used when you need to collect a specific date from users, such as
for scheduling events, setting deadlines, or specifying birthdates.
.PARAMETER Id
A unique identifier for the input element. This ID will be used when the card is submitted
to identify the selected date value.
.PARAMETER Label
Text label to display above the input field, describing what the date selection is for.
.PARAMETER Value
Optional default date value for the input. The date should be in ISO 8601 format (YYYY-MM-DD).
If not specified, defaults to the current date.
.PARAMETER Placeholder
Optional text to display when no date has been selected.
Default: "Select a date"
.PARAMETER Min
Optional minimum allowed date (inclusive) in ISO 8601 format (YYYY-MM-DD).
Dates before this value will be disabled in the calendar picker.
.PARAMETER Max
Optional maximum allowed date (inclusive) in ISO 8601 format (YYYY-MM-DD).
Dates after this value will be disabled in the calendar picker.
.EXAMPLE
# Create a simple date input with default values
$dueDateInput = New-AMDateInput -Id "dueDate" -Label "Due Date:"
Add-AMElement -Card $card -Element $dueDateInput
.EXAMPLE
# Create a date input with a specific default date
$eventDateInput = New-AMDateInput -Id "eventDate" -Label "Event Date:" -Value "2025-04-15"
.EXAMPLE
# Create a date input with restricted date range
$birthDateInput = New-AMDateInput -Id "birthDate" -Label "Birth Date:" `
-Placeholder "Enter your date of birth" `
-Min "1900-01-01" -Max "2020-12-31"
.INPUTS
None. You cannot pipe input to New-AMDateInput.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the Input.Date element.
.NOTES
Date inputs in Adaptive Cards will render differently depending on the client:
- In most clients, they appear as a text field with a calendar picker
- The format of the displayed date may vary by client or user locale
- The value submitted will always be in ISO 8601 format (YYYY-MM-DD)
.LINK
https://adaptivecards.io/explorer/Input.Date.html
#>
param (
[Parameter(Mandatory = $true)]
[string]$Id,
[Parameter(Mandatory = $true)]
[string]$Label,
[Parameter()]
[string]$Value = $(Get-Date -Format 'yyyy-MM-dd'),
[Parameter()]
[string]$Placeholder = "Select a date",
[Parameter()]
[string]$Min,
[Parameter()]
[string]$Max
)
$dateInput = @{
type = "Input.Date"
id = $Id
label = $Label
value = $Value
placeholder = $Placeholder
}
if ($Min) { $dateInput.min = $Min }
if ($Max) { $dateInput.max = $Max }
return $dateInput

``r

## DESCRIPTION
Creates an Input.Date element that allows users to select a date from a calendar interface.
Date inputs are used when you need to collect a specific date from users, such as
for scheduling events, setting deadlines, or specifying birthdates.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple date input with default values
$dueDateInput = New-AMDateInput -Id "dueDate" -Label "Due Date:"
Add-AMElement -Card $card -Element $dueDateInput
``r

    

### EXAMPLE 2
`powershell
# Create a date input with a specific default date
$eventDateInput = New-AMDateInput -Id "eventDate" -Label "Event Date:" -Value "2025-04-15"
``r

    

### EXAMPLE 3
`powershell
# Create a date input with restricted date range
$birthDateInput = New-AMDateInput -Id "birthDate" -Label "Birth Date:" `
    -Placeholder "Enter your date of birth" `
    -Min "1900-01-01" -Max "2020-12-31"
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
to identify the selected date value.

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
Text label to display above the input field, describing what the date selection is for.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Value
Optional default date value for the input. The date should be in ISO 8601 format (YYYY-MM-DD).
If not specified, defaults to the current date.

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

### -Placeholder
Optional text to display when no date has been selected.
Default: "Select a date"

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Min
Optional minimum allowed date (inclusive) in ISO 8601 format (YYYY-MM-DD).
Dates before this value will be disabled in the calendar picker.

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

### -Max
Optional maximum allowed date (inclusive) in ISO 8601 format (YYYY-MM-DD).
Dates after this value will be disabled in the calendar picker.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMDateInput.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Input.Date element.


## NOTES
Date inputs in Adaptive Cards will render differently depending on the client:
- In most clients, they appear as a text field with a calendar picker
- The format of the displayed date may vary by client or user locale
- The value submitted will always be in ISO 8601 format (YYYY-MM-DD)

## RELATED LINKS
[](https://adaptivecards.io/explorer/Input.Date.html)

