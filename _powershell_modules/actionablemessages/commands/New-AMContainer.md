---
layout: page
title: New-AMContainer
permalink: /modules/actionablemessages/commands/New-AMContainer/
---

# New-AMContainer

## SYNOPSIS
Creates a Container element for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates a Container element for an Adaptive Card.
.DESCRIPTION
Creates a Container element that can group and style multiple elements together.
Containers are fundamental building blocks for organizing content in Adaptive Cards,
allowing you to apply common styling, visibility settings, and padding to a group
of elements.
Containers can hold any combination of elements including text blocks, images,
other containers, column sets, and more.
.PARAMETER Id
An optional unique identifier for the container. This ID can be used to reference
the container when adding elements to it or when targeting it with visibility
toggle actions.
.PARAMETER Items
An array of elements to place inside the container. These should be created using
other New-AM* functions like New-AMTextBlock, New-AMImage, etc.
.PARAMETER Style
Optional styling to apply to the container.
Valid values:
- "default": Standard container with no special styling
- "emphasis": Container with background color for emphasis
- "good": Container styled to indicate positive or successful content
- "attention": Container styled to draw attention
- "warning": Container styled to indicate warning or caution
.PARAMETER IsVisible
Optional boolean that controls whether the container is initially visible.
When set to $false, the container will be hidden until shown by a toggle action.
.PARAMETER Padding
Optional spacing to apply around the container contents.
Valid values: "None", "Small", "Default", "Large"
Default: "None"
.EXAMPLE
# Create a simple container with text
$container = New-AMContainer -Id "info-section" -Style "emphasis"
Add-AMElement -Card $card -Element $container
# Add elements to the container
$title = New-AMTextBlock -Text "Important Information" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $title -ContainerId "info-section"
$text = New-AMTextBlock -Text "Here are the details you need to know..." -Wrap $true
Add-AMElement -Card $card -Element $text -ContainerId "info-section"
.EXAMPLE
# Create a container with pre-populated items
$items = @(
(New-AMTextBlock -Text "Container Title" -Size "Medium" -Weight "Bolder"),
(New-AMTextBlock -Text "This container has multiple elements" -Wrap $true),
(New-AMImage -Url "https://example.com/image.jpg" -Size "Medium")
)
$container = New-AMContainer -Id "pre-populated" -Items $items -Style "good" -Padding "Default"
Add-AMElement -Card $card -Element $container
.EXAMPLE
# Create a hidden container that can be toggled
$detailsContainer = New-AMContainer -Id "details-section" -IsVisible $false -Style "emphasis" -Padding "Small"
Add-AMElement -Card $card -Element $detailsContainer
# Add content to the hidden container
$detailsText = New-AMTextBlock -Text "These are additional details that are initially hidden." -Wrap $true
Add-AMElement -Card $card -Element $detailsText -ContainerId "details-section"
# Create a button to toggle visibility
$toggleAction = New-AMToggleVisibilityAction -Title "Show/Hide Details" -TargetElements @("details-section")
Add-AMElement -Card $card -Element (New-AMActionSet -Id "actions" -Actions @($toggleAction))
.INPUTS
None. You cannot pipe input to New-AMContainer.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the Container element.
.NOTES
Containers are one of the most versatile elements in Adaptive Cards. They help with:
- Grouping related content together
- Applying consistent styling to multiple elements
- Creating expandable/collapsible sections with toggle visibility
- Organizing card layout into logical sections
To add elements to an existing container, use the Add-AMElement function with
the -ContainerId parameter.
.LINK
https://adaptivecards.io/explorer/Container.html
#>
[CmdletBinding()]
param (
[Parameter()]
[string]$Id,
[Parameter()]
[array]$Items,
[Parameter()]
[ValidateSet("default", "emphasis", "good", "attention", "warning")]
[string]$Style,
[Parameter()]
[bool]$IsVisible,
[Parameter()]
[ValidateSet("None", "Small", "Default", "Large")]
[string]$Padding = "None"  # Default to "None" to match desired output
)
$container = [ordered]@{
'type' = 'Container'
'id' = $Id
'items' = @()
'padding' = $Padding
}
if ($Style) { $container.style = $Style }
if ($PSBoundParameters.ContainsKey('IsVisible')) { $container.isVisible = $IsVisible }
if ($Items -and $Items.Count -gt 0) { $container.items = $Items }
return $container

``r

## DESCRIPTION
Creates a Container element that can group and style multiple elements together.
Containers are fundamental building blocks for organizing content in Adaptive Cards,
allowing you to apply common styling, visibility settings, and padding to a group
of elements.

Containers can hold any combination of elements including text blocks, images,
other containers, column sets, and more.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple container with text
$container = New-AMContainer -Id "info-section" -Style "emphasis"
Add-AMElement -Card $card -Element $container
``r

# Add elements to the container
$title = New-AMTextBlock -Text "Important Information" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $title -ContainerId "info-section"

$text = New-AMTextBlock -Text "Here are the details you need to know..." -Wrap $true
Add-AMElement -Card $card -Element $text -ContainerId "info-section"    

### EXAMPLE 2
`powershell
# Create a container with pre-populated items
$items = @(
    (New-AMTextBlock -Text "Container Title" -Size "Medium" -Weight "Bolder"),
    (New-AMTextBlock -Text "This container has multiple elements" -Wrap $true),
    (New-AMImage -Url "https://example.com/image.jpg" -Size "Medium")
)
``r

$container = New-AMContainer -Id "pre-populated" -Items $items -Style "good" -Padding "Default"
Add-AMElement -Card $card -Element $container    

### EXAMPLE 3
`powershell
# Create a hidden container that can be toggled
$detailsContainer = New-AMContainer -Id "details-section" -IsVisible $false -Style "emphasis" -Padding "Small"
Add-AMElement -Card $card -Element $detailsContainer
``r

# Add content to the hidden container
$detailsText = New-AMTextBlock -Text "These are additional details that are initially hidden." -Wrap $true
Add-AMElement -Card $card -Element $detailsText -ContainerId "details-section"

# Create a button to toggle visibility
$toggleAction = New-AMToggleVisibilityAction -Title "Show/Hide Details" -TargetElements @("details-section")
Add-AMElement -Card $card -Element (New-AMActionSet -Id "actions" -Actions @($toggleAction))    

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
An optional unique identifier for the container. This ID can be used to reference
the container when adding elements to it or when targeting it with visibility
toggle actions.

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

### -Items
An array of elements to place inside the container. These should be created using
other New-AM* functions like New-AMTextBlock, New-AMImage, etc.

`yaml
Type: Array
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Style
Optional styling to apply to the container.
Valid values:
- "default": Standard container with no special styling
- "emphasis": Container with background color for emphasis
- "good": Container styled to indicate positive or successful content
- "attention": Container styled to draw attention
- "warning": Container styled to indicate warning or caution

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

### -IsVisible
Optional boolean that controls whether the container is initially visible.
When set to $false, the container will be hidden until shown by a toggle action.

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

### -Padding
Optional spacing to apply around the container contents.
Valid values: "None", "Small", "Default", "Large"
Default: "None"

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMContainer.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Container element.


## NOTES
Containers are one of the most versatile elements in Adaptive Cards. They help with:
- Grouping related content together
- Applying consistent styling to multiple elements
- Creating expandable/collapsible sections with toggle visibility
- Organizing card layout into logical sections

To add elements to an existing container, use the Add-AMElement function with
the -ContainerId parameter.

## RELATED LINKS
[](https://adaptivecards.io/explorer/Container.html)

