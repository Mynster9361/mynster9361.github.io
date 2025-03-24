---
layout: page
title: New-AMFactSet
permalink: /modules/actionablemessages/commands/New-AMFactSet/
---

# New-AMFactSet

## SYNOPSIS
Creates a FactSet element for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a FactSet element for an Adaptive Card.
.DESCRIPTION
Creates a FactSet element that displays a series of facts (key-value pairs) in a
structured, two-column format. FactSets are ideal for displaying property lists,
specifications, details, or any information that benefits from a label-value layout.
The FactSet element automatically formats the facts in two columns, with titles
in the left column (typically bold) and values in the right column.
.PARAMETER Facts
An array of fact objects created with New-AMFact. Each fact represents a key-value
pair with a Title (key) and Value.
.PARAMETER Id
Optional unique identifier for the FactSet. This can be useful when you need to
reference this element in other parts of the card or target it with actions.
.EXAMPLE
# Create a simple employee information FactSet
$facts = @(
New-AMFact -Title "Employee" -Value "John Doe"
New-AMFact -Title "Department" -Value "Engineering"
New-AMFact -Title "Title" -Value "Senior Developer"
New-AMFact -Title "Start Date" -Value "2020-01-15"
)
$factSet = New-AMFactSet -Facts $facts
Add-AMElement -Card $card -Element $factSet
.EXAMPLE
# Create a product specification FactSet with ID
$specs = @(
New-AMFact -Title "Model" -Value "ThinkPad X1"
New-AMFact -Title "Processor" -Value "Intel Core i7"
New-AMFact -Title "Memory" -Value "16 GB"
New-AMFact -Title "Storage" -Value "512 GB SSD"
)
$specSheet = New-AMFactSet -Facts $specs -Id "product-specs"
# Add the FactSet to a container
$container = New-AMContainer -Id "spec-container" -Style "emphasis"
Add-AMElement -Card $card -Element $container
Add-AMElement -Card $card -Element $specSheet -ContainerId "spec-container"
.INPUTS
None. You cannot pipe input to New-AMFactSet.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the FactSet element.
.NOTES
FactSets are ideal for displaying structured information where clarity and organization
are important. Some best practices:
- Use concise titles that clearly identify the information
- Group related facts together in a single FactSet
- For very long lists, consider using multiple FactSets with headers
- FactSets render differently across different Adaptive Card hosts,
so test your cards in the target environment
.LINK
https://adaptivecards.io/explorer/FactSet.html
#>
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)]
[array]$Facts,
[Parameter()]
[string]$Id
)
$factSet = [ordered]@{
'type' = 'FactSet'
'facts' = $Facts
}
if ($Id) {
$factSet.id = $Id
}
return $factSet

``r

## DESCRIPTION
Creates a FactSet element that displays a series of facts (key-value pairs) in a
structured, two-column format. FactSets are ideal for displaying property lists,
specifications, details, or any information that benefits from a label-value layout.

The FactSet element automatically formats the facts in two columns, with titles
in the left column (typically bold) and values in the right column.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple employee information FactSet
$facts = @(
    New-AMFact -Title "Employee" -Value "John Doe"
    New-AMFact -Title "Department" -Value "Engineering"
    New-AMFact -Title "Title" -Value "Senior Developer"
    New-AMFact -Title "Start Date" -Value "2020-01-15"
)
$factSet = New-AMFactSet -Facts $facts
Add-AMElement -Card $card -Element $factSet
``r

    

### EXAMPLE 2
`powershell
# Create a product specification FactSet with ID
$specs = @(
    New-AMFact -Title "Model" -Value "ThinkPad X1"
    New-AMFact -Title "Processor" -Value "Intel Core i7"
    New-AMFact -Title "Memory" -Value "16 GB"
    New-AMFact -Title "Storage" -Value "512 GB SSD"
)
$specSheet = New-AMFactSet -Facts $specs -Id "product-specs"
``r

# Add the FactSet to a container
$container = New-AMContainer -Id "spec-container" -Style "emphasis"
Add-AMElement -Card $card -Element $container
Add-AMElement -Card $card -Element $specSheet -ContainerId "spec-container"    

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

### -Facts
An array of fact objects created with New-AMFact. Each fact represents a key-value
pair with a Title (key) and Value.

`yaml
Type: Array
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Id
Optional unique identifier for the FactSet. This can be useful when you need to
reference this element in other parts of the card or target it with actions.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMFactSet.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the FactSet element.


## NOTES
FactSets are ideal for displaying structured information where clarity and organization
are important. Some best practices:

- Use concise titles that clearly identify the information
- Group related facts together in a single FactSet
- For very long lists, consider using multiple FactSets with headers
- FactSets render differently across different Adaptive Card hosts,
  so test your cards in the target environment

## RELATED LINKS
[](https://adaptivecards.io/explorer/FactSet.html)

