---
layout: page
title: Add-AMElement
permalink: /modules/actionablemessages/commands/Add-AMElement/
---

# Add-AMElement

## SYNOPSIS
Adds an element to an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Adds an element to an Adaptive Card.
.DESCRIPTION
Adds an element directly to the card body or to a specific container within the card.
This function modifies the card in-place; there is no need to reassign the result.
The function handles adding elements to:
- The main card body
- Inside a container (by specifying ContainerId)
- Inside a specific column in a ColumnSet (future functionality)
.PARAMETER Card
The Adaptive Card hashtable to add the element to.
.PARAMETER Element
The element to add to the card. This should be a hashtable created by one of the
New-AM* functions such as New-AMTextBlock, New-AMImage, New-AMContainer, etc.
.PARAMETER ContainerId
Optional. The ID of a container to add the element to. If specified, the element
will be added to the container's items collection rather than directly to the card body.
.PARAMETER ColumnId
Optional. The ID of a column within a container to add the element to. Only applicable
when ContainerId is also specified.
.EXAMPLE
# Add a text block directly to card body
$title = New-AMTextBlock -Text "Hello World" -Size "Large" -Weight "Bolder"
Add-AMElement -Card $card -Element $title
.EXAMPLE
# Add a text block to a container
$text = New-AMTextBlock -Text "This text is inside a container" -Wrap $true
Add-AMElement -Card $card -Element $text -ContainerId "details-container"
.EXAMPLE
# Create a container and add multiple elements to it
$container = New-AMContainer -Id "info-section" -Style "emphasis"
Add-AMElement -Card $card -Element $container
# Now add elements to the container
$header = New-AMTextBlock -Text "Important Information" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $header -ContainerId "info-section"
$content = New-AMTextBlock -Text "Here are the details you requested..." -Wrap $true
Add-AMElement -Card $card -Element $content -ContainerId "info-section"
$factSet = New-AMFactSet -Facts @(
(New-AMFact -Title "Status" -Value "Active"),
(New-AMFact -Title "Priority" -Value "High")
)
Add-AMElement -Card $card -Element $factSet -ContainerId "info-section"
.INPUTS
System.Collections.Hashtable
.OUTPUTS
None
.NOTES
This function modifies the card directly. It uses ArrayList operations to ensure
changes are reflected in the original card variable.
When adding elements to containers, make sure the container exists and has the
correct ID, otherwise an error will be thrown.
The function automatically creates the body array if it doesn't exist, but it
expects containers to already be present when referencing them by ID.
.LINK
https://adaptivecards.io/explorer/
#>
[CmdletBinding()]
param(
[Parameter(Mandatory = $true, Position = 0)]
[hashtable]$Card,
[Parameter(Mandatory = $true, Position = 1)]
[hashtable]$Element,
[Parameter()]
[string]$ContainerId,
[Parameter()]
[string]$ColumnId
)
# Ensure body array exists using direct hashtable access
if (-not $Card.ContainsKey('body')) {
$Card['body'] = [System.Collections.ArrayList]@()
}
if ($ContainerId) {
# Find the container by ID
$containerFound = $false
for ($i = 0; $i -lt $Card['body'].Count; $i++) {
if ($Card['body'][$i].id -eq $ContainerId) {
# Container found
$containerFound = $true
# Ensure container has items array
if (-not $Card['body'][$i].ContainsKey('items')) {
$Card['body'][$i]['items'] = [System.Collections.ArrayList]@()
}
# Add element to container's items
if ($Card['body'][$i]['items'] -is [System.Collections.ArrayList]) {
[void]$Card['body'][$i]['items'].Add($Element)
} else {
# Convert to ArrayList if not already
$newItems = [System.Collections.ArrayList]@()
if ($Card['body'][$i]['items']) {
foreach ($item in $Card['body'][$i]['items']) {
[void]$newItems.Add($item)
}
}
[void]$newItems.Add($Element)
$Card['body'][$i]['items'] = $newItems
}
break
}
}
if (-not $containerFound) {
throw "Container with ID '$ContainerId' not found"
}
} else {
# Add directly to card body using ArrayList method
if ($Card['body'] -is [System.Collections.ArrayList]) {
[void]$Card['body'].Add($Element)
} else {
# Convert to ArrayList if not already
$newBody = [System.Collections.ArrayList]@()
if ($Card['body']) {
foreach ($item in $Card['body']) {
[void]$newBody.Add($item)
}
}
[void]$newBody.Add($Element)
$Card['body'] = $newBody
}
}
# No return value - the card is modified directly

``r

## DESCRIPTION
Adds an element directly to the card body or to a specific container within the card.
This function modifies the card in-place; there is no need to reassign the result.

The function handles adding elements to:
- The main card body
- Inside a container (by specifying ContainerId)
- Inside a specific column in a ColumnSet (future functionality)

## EXAMPLES

### EXAMPLE 1
`powershell
# Add a text block directly to card body
$title = New-AMTextBlock -Text "Hello World" -Size "Large" -Weight "Bolder"
Add-AMElement -Card $card -Element $title
``r

    

### EXAMPLE 2
`powershell
# Add a text block to a container
$text = New-AMTextBlock -Text "This text is inside a container" -Wrap $true
Add-AMElement -Card $card -Element $text -ContainerId "details-container"
``r

    

### EXAMPLE 3
`powershell
# Create a container and add multiple elements to it
$container = New-AMContainer -Id "info-section" -Style "emphasis"
Add-AMElement -Card $card -Element $container
``r

# Now add elements to the container
$header = New-AMTextBlock -Text "Important Information" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $header -ContainerId "info-section"

$content = New-AMTextBlock -Text "Here are the details you requested..." -Wrap $true
Add-AMElement -Card $card -Element $content -ContainerId "info-section"

$factSet = New-AMFactSet -Facts @(
    (New-AMFact -Title "Status" -Value "Active"),
    (New-AMFact -Title "Priority" -Value "High")
)
Add-AMElement -Card $card -Element $factSet -ContainerId "info-section"    

## PARAMETERS

### -ColumnId
Optional. The ID of a column within a container to add the element to. Only applicable
when ContainerId is also specified.

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

### -ContainerId
Optional. The ID of a container to add the element to. If specified, the element
will be added to the container's items collection rather than directly to the card body.

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

### -Card
The Adaptive Card hashtable to add the element to.

`yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Element
The element to add to the card. This should be a hashtable created by one of the
New-AM* functions such as New-AMTextBlock, New-AMImage, New-AMContainer, etc.

`yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### System.Collections.Hashtable


## OUTPUTS
### None


## NOTES
This function modifies the card directly. It uses ArrayList operations to ensure
changes are reflected in the original card variable.

When adding elements to containers, make sure the container exists and has the
correct ID, otherwise an error will be thrown.

The function automatically creates the body array if it doesn't exist, but it
expects containers to already be present when referencing them by ID.

## RELATED LINKS
[](https://adaptivecards.io/explorer/)

