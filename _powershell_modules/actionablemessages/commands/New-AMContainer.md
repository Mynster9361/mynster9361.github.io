---
layout: page
title: New-AMContainer
permalink: /modules/actionablemessages/commands/New-AMContainer/
---

# New-AMContainer

## SYNOPSIS
Creates a Container element for an Adaptive Card.

## SYNTAX

```powershell
New-AMContainer [-Id <String>] [-Items <Array>] [-Style <String>] [-IsVisible <Boolean>] [-Padding <String>] [-CustomPadding <Hashtable>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-AMContainer` function creates a Container element that can group and style multiple elements together.
Containers are fundamental building blocks for organizing content in Adaptive Cards, allowing you to apply
common styling, visibility settings, and padding to a group of elements.

Containers can hold any combination of elements, including text blocks, images, other containers, column sets, and more.
They are essential for creating structured and visually appealing Adaptive Cards.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a simple container with text
$container = New-AMContainer -Id "info-section" -Style "emphasis"
Add-AMElement -Card $card -Element $container
```

#### Example explanation
```powershell
# Add elements to the container
$title = New-AMTextBlock -Text "Important Information" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $title -ContainerId "info-section"

$text = New-AMTextBlock -Text "Here are the details you need to know..." -Wrap $true
Add-AMElement -Card $card -Element $text -ContainerId "info-section"
```

### EXAMPLE 2
```powershell
# Create a container with pre-populated items
$items = @(
    (New-AMTextBlock -Text "Container Title" -Size "Medium" -Weight "Bolder"),
    (New-AMTextBlock -Text "This container has multiple elements" -Wrap $true),
    (New-AMImage -Url "https://example.com/image.jpg" -Size "Medium")
)
```

#### Example explanation
```powershell
$container = New-AMContainer -Id "pre-populated" -Items $items -Style "good" -Padding "Default"
Add-AMElement -Card $card -Element $container
```

### EXAMPLE 3
```powershell
# Create a hidden container that can be toggled
$detailsContainer = New-AMContainer -Id "details-section" -IsVisible $false -Style "emphasis" -Padding "Small"
Add-AMElement -Card $card -Element $detailsContainer
```

#### Example explanation
```powershell
# Add content to the hidden container
$detailsText = New-AMTextBlock -Text "These are additional details that are initially hidden." -Wrap $true
Add-AMElement -Card $card -Element $detailsText -ContainerId "details-section"

# Create a button to toggle visibility
$toggleAction = New-AMToggleVisibilityAction -Title "Show/Hide Details" -TargetElements @("details-section")
Add-AMElement -Card $card -Element (New-AMActionSet -Id "actions" -Actions @($toggleAction))
```

### EXAMPLE 4
```powershell
# Create a container with custom padding on different sides
$customPadding = @{
    top = "None"
    bottom = "Large"
    left = "Small"
    right = "Small"
}
```

#### Example explanation
```powershell
$container = New-AMContainer -Id "custom-padding" -Padding "Custom" -CustomPadding $customPadding
Add-AMElement -Card $card -Element $container
```
## PARAMETERS

### -Id
(Optional) A unique identifier for the container. This ID can be used to reference the container when adding
elements to it or when targeting it with visibility toggle actions.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Items
(Optional) An array of elements to place inside the container. These should be created using other `New-AM*`
functions like `New-AMTextBlock`, `New-AMImage`, etc.

```yaml
Type: Array
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Style
(Optional) Styling to apply to the container.
Valid values:
- "default": Standard container with no special styling
- "emphasis": Container with background color for emphasis
- "good": Container styled to indicate positive or successful content
- "attention": Container styled to draw attention
- "warning": Container styled to indicate warning or caution

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsVisible
(Optional) Boolean that controls whether the container is initially visible.
When set to `$false`, the container will be hidden until shown by a toggle action.
Default: `$true`

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Padding
(Optional) Spacing to apply around the container contents.
Valid values: "None", "Small", "Default", "Medium", "Large", "ExtraLarge", "Custom"
Default: "None"

When set to "Custom", the `CustomPadding` parameter is used instead.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomPadding
(Optional) A hashtable that specifies different padding values for each side of the container.
Only used when `Padding` is set to "Custom".

The hashtable can include these keys: `top`, `bottom`, `left`, `right`.
Each value must be one of: "None", "Small", "Default", "Medium", "Large", "ExtraLarge".

Example: `@{top="None"; bottom="Default"; left="Default"; right="Default"}`

```yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to `New-AMContainer`.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Container element.

## NOTES
- Containers are one of the most versatile elements in Adaptive Cards. They help with:
  - Grouping related content together
  - Applying consistent styling to multiple elements
  - Creating expandable/collapsible sections with toggle visibility
  - Organizing card layout into logical sections
- To add elements to an existing container, use the `Add-AMElement` function with the `-ContainerId` parameter.

## RELATED LINKS
- [https://adaptivecards.io/explorer/Container.html](https://adaptivecards.io/explorer/Container.html)
