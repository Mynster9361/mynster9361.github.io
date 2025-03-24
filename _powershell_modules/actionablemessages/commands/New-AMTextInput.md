---
layout: page
title: New-AMTextInput
permalink: /modules/actionablemessages/commands/New-AMTextInput/
---

# New-AMTextInput

## SYNOPSIS
Creates a text input field for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a text input field for an Adaptive Card.
.DESCRIPTION
Creates an Input.Text element that allows users to enter text in an Adaptive Card.
Text inputs can be single-line or multi-line and support various configuration options
like placeholders, default values, maximum length, and validation requirements.
This is one of the most common input elements used for collecting free-form text from users.
.PARAMETER Id
A unique identifier for the input element. This ID will be used when the card is submitted
to identify the text entered by the user.
.PARAMETER Label
Optional text label to display above the input field, describing what the input is for.
.PARAMETER Placeholder
Optional text to display when the input field is empty. This text provides a hint to the user
about what they should enter.
.PARAMETER Value
Optional default text to pre-fill in the input field when the card is displayed.
.PARAMETER IsMultiline
When set to $true, creates a text area that allows for multiple lines of text.
When set to $false (default), creates a single-line text input field.
.PARAMETER IsRequired
When set to $true, the field must contain text when submitted.
When set to $false (default), the field is optional.
.PARAMETER MaxLength
Optional maximum number of characters allowed in the input field.
.PARAMETER Separator
When set to $true, adds a visible separator line above the input field.
.EXAMPLE
# Create a simple single-line text input
$nameInput = New-AMTextInput -Id "userName" -Label "Your Name:"
Add-AMElement -Card $card -Element $nameInput
.EXAMPLE
# Create a multiline text input with placeholder
$feedbackInput = New-AMTextInput -Id "feedback" -Label "Your Feedback:" `
-Placeholder "Please share your thoughts..." -IsMultiline $true
.EXAMPLE
# Create a required text input with maximum length
$subjectInput = New-AMTextInput -Id "subject" -Label "Subject:" `
-IsRequired $true -MaxLength 100 -Separator $true
.EXAMPLE
# Create a text input with default value
$emailInput = New-AMTextInput -Id "email" -Label "Email Address:" `
-Value "user@example.com" -Placeholder "name@company.com"
.INPUTS
None. You cannot pipe input to New-AMTextInput.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the Input.Text element.
.NOTES
Text inputs are versatile elements for gathering user feedback. Some best practices:
- Always use clear labels to identify what information is being requested
- Use placeholder text to provide examples or formatting guidance
- For longer text entries, set IsMultiline to $true
- Consider using MaxLength to prevent excessive text entry
- Set IsRequired for fields that must be filled
.LINK
https://adaptivecards.io/explorer/Input.Text.html
#>
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)]
[string]$Id,
[Parameter()]
[string]$Label,
[Parameter()]
[string]$Placeholder = "",
[Parameter()]
[string]$Value = "",
[Parameter()]
[bool]$IsMultiline = $false,
[Parameter()]
[bool]$IsRequired = $false,
[Parameter()]
[int]$MaxLength,
[Parameter()]
[bool]$Separator
)
$input = [ordered]@{
'type' = 'Input.Text'
'id' = $Id
}
if ($Label) { $input.label = $Label }
if ($Placeholder) { $input.placeholder = $Placeholder }
if ($Value) { $input.value = $Value }
if ($PSBoundParameters.ContainsKey('IsMultiline')) { $input.isMultiline = $IsMultiline }
if ($PSBoundParameters.ContainsKey('IsRequired')) { $input.isRequired = $IsRequired }
if ($PSBoundParameters.ContainsKey('MaxLength')) { $input.maxLength = $MaxLength }
if ($PSBoundParameters.ContainsKey('Separator')) { $input.separator = $Separator }
return $input

``r

## DESCRIPTION
Creates an Input.Text element that allows users to enter text in an Adaptive Card.
Text inputs can be single-line or multi-line and support various configuration options
like placeholders, default values, maximum length, and validation requirements.

This is one of the most common input elements used for collecting free-form text from users.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple single-line text input
$nameInput = New-AMTextInput -Id "userName" -Label "Your Name:"
Add-AMElement -Card $card -Element $nameInput
``r

    

### EXAMPLE 2
`powershell
# Create a multiline text input with placeholder
$feedbackInput = New-AMTextInput -Id "feedback" -Label "Your Feedback:" `
    -Placeholder "Please share your thoughts..." -IsMultiline $true
``r

    

### EXAMPLE 3
`powershell
# Create a required text input with maximum length
$subjectInput = New-AMTextInput -Id "subject" -Label "Subject:" `
    -IsRequired $true -MaxLength 100 -Separator $true
``r

    

### EXAMPLE 4
`powershell
# Create a text input with default value
$emailInput = New-AMTextInput -Id "email" -Label "Email Address:" `
    -Value "user@example.com" -Placeholder "name@company.com"
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
to identify the text entered by the user.

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

### -Placeholder
Optional text to display when the input field is empty. This text provides a hint to the user
about what they should enter.

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

### -Value
Optional default text to pre-fill in the input field when the card is displayed.

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

### -IsMultiline
When set to $true, creates a text area that allows for multiple lines of text.
When set to $false (default), creates a single-line text input field.

`yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -IsRequired
When set to $true, the field must contain text when submitted.
When set to $false (default), the field is optional.

`yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -MaxLength
Optional maximum number of characters allowed in the input field.

`yaml
Type: Int32
Parameter Sets: (All)
Aliases: None

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Separator
When set to $true, adds a visible separator line above the input field.

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
### None. You cannot pipe input to New-AMTextInput.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Input.Text element.


## NOTES
Text inputs are versatile elements for gathering user feedback. Some best practices:

- Always use clear labels to identify what information is being requested
- Use placeholder text to provide examples or formatting guidance
- For longer text entries, set IsMultiline to $true
- Consider using MaxLength to prevent excessive text entry
- Set IsRequired for fields that must be filled

## RELATED LINKS
[](https://adaptivecards.io/explorer/Input.Text.html)

