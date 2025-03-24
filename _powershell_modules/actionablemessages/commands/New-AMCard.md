---
layout: page
title: New-AMCard
permalink: /modules/actionablemessages/commands/New-AMCard/
---

# New-AMCard

## SYNOPSIS
Creates a new Adaptive Card object.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a new Adaptive Card object.
.DESCRIPTION
Creates a new Adaptive Card hashtable that serves as the foundation for building
an Adaptive Card. This is typically the first function you call when creating
a new card.
The card object created by this function will contain the basic structure needed
for an Adaptive Card, including empty collections for body elements and actions.
.PARAMETER Version
The version of the Adaptive Card schema to use.
Valid values: "1.0", "1.1", "1.2"
Default: "1.2"
Different versions support different card features:
- 1.0: Basic layout and elements
- 1.1: Adds support for additional features like horizontal alignment
- 1.2: Adds support for more advanced features and styling options
.PARAMETER OriginatorId
A unique identifier for the sender of the card. For Outlook Actionable Messages,
this should be the originator ID registered with Microsoft.
This ID is critical for security purposes, as it validates that your organization
is authorized to send Actionable Messages and make HTTP requests to your endpoints.
.PARAMETER HideOriginalBody
Specifies whether to hide the original email body when displaying the card.
When set to $true (default), only the Adaptive Card is displayed in the email.
When set to $false, both the original email text and the card are displayed.
Default: $true
.EXAMPLE
# Create a basic card
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
.EXAMPLE
# Create a card and show the original email body
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2" -HideOriginalBody $false
.EXAMPLE
# Create a complete card with content
$card = New-AMCard -OriginatorId "1234567890"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Expense Approval Required" -Size "Large" -Weight "Bolder")
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Please review the following expense report:" -Wrap $true)
# Add more elements and then export
$json = Export-AMCard -Card $card
.INPUTS
None. You cannot pipe input to New-AMCard.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the Adaptive Card structure.
.NOTES
The OriginatorId is required for Outlook Actionable Messages. You must register
your originator ID with Microsoft before using it in production through the Actionable
Email Developer Dashboard at https://aka.ms/publishactionableemails.
For testing purposes in development environments, any value can be used.
After creating a card, use Add-AMElement along with element creation functions
like New-AMTextBlock and New-AMImage to populate the card with content.
.LINK
https://docs.microsoft.com/en-us/outlook/actionable-messages/
.LINK
https://adaptivecards.io/explorer/
#>
[CmdletBinding()]
param(
[Parameter()]
[ValidateSet("1.0", "1.1", "1.2")]
[string]$Version = "1.2",
[Parameter(Mandatory = $true)]
[string]$OriginatorId,
[Parameter()]
[bool]$HideOriginalBody = $true
)
$card = [ordered]@{
'type' = 'AdaptiveCard'
'version' = $Version
'originator' = $OriginatorId
'hideOriginalBody' = $HideOriginalBody
'$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
'body' = [System.Collections.ArrayList]@()
'actions' = [System.Collections.ArrayList]@()
}
return $card

``r

## DESCRIPTION
Creates a new Adaptive Card hashtable that serves as the foundation for building
an Adaptive Card. This is typically the first function you call when creating
a new card.

The card object created by this function will contain the basic structure needed
for an Adaptive Card, including empty collections for body elements and actions.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a basic card
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
``r

    

### EXAMPLE 2
`powershell
# Create a card and show the original email body
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2" -HideOriginalBody $false
``r

    

### EXAMPLE 3
`powershell
# Create a complete card with content
$card = New-AMCard -OriginatorId "1234567890"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Expense Approval Required" -Size "Large" -Weight "Bolder")
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Please review the following expense report:" -Wrap $true)
``r

# Add more elements and then export
$json = Export-AMCard -Card $card    

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

### -Version
The version of the Adaptive Card schema to use.
Valid values: "1.0", "1.1", "1.2"
Default: "1.2"

Different versions support different card features:
- 1.0: Basic layout and elements
- 1.1: Adds support for additional features like horizontal alignment
- 1.2: Adds support for more advanced features and styling options

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

### -OriginatorId
A unique identifier for the sender of the card. For Outlook Actionable Messages,
this should be the originator ID registered with Microsoft.

This ID is critical for security purposes, as it validates that your organization
is authorized to send Actionable Messages and make HTTP requests to your endpoints.

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

### -HideOriginalBody
Specifies whether to hide the original email body when displaying the card.

When set to $true (default), only the Adaptive Card is displayed in the email.
When set to $false, both the original email text and the card are displayed.

Default: $true

`yaml
Type: Boolean
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
### None. You cannot pipe input to New-AMCard.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Adaptive Card structure.


## NOTES
The OriginatorId is required for Outlook Actionable Messages. You must register
your originator ID with Microsoft before using it in production through the Actionable
Email Developer Dashboard at https://aka.ms/publishactionableemails.

For testing purposes in development environments, any value can be used.

After creating a card, use Add-AMElement along with element creation functions
like New-AMTextBlock and New-AMImage to populate the card with content.

## RELATED LINKS
[](https://docs.microsoft.com/en-us/outlook/actionable-messages/)
[](https://adaptivecards.io/explorer/)

