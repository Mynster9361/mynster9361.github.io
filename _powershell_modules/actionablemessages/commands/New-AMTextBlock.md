---
layout: page
title: New-AMTextBlock
permalink: /modules/actionablemessages/commands/New-AMTextBlock/
---

# New-AMTextBlock

## SYNOPSIS
Creates a TextBlock element for an Adaptive Card.

## SYNTAX

`powershell
New-AMTextBlock [-Text <String>] [-Size <String>] [-Weight <String>] [-Color <String>] [-Wrap <String>] [<CommonParameters>]
``r

## DESCRIPTION
Creates a TextBlock element that displays formatted text within an Adaptive Card.
TextBlocks are the primary way to display text content and can be styled with
different sizes, weights, and colors. They can also support simple markdown formatting.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple text block
$text = New-AMTextBlock -Text "Hello World!"
Add-AMElement -Card $card -Element $text
``r

    

### EXAMPLE 2
`powershell
# Create a heading with larger text and bold weight
$heading = New-AMTextBlock -Text "Important Notification" -Size "Large" -Weight "Bolder" -Color "Accent"
``r

    

### EXAMPLE 3
`powershell
# Create text with markdown formatting
$markdownText = New-AMTextBlock -Text "Please **review** the [documentation](https://docs.example.com) before continuing."
``r

    

## PARAMETERS

### -Text
The text to display in the TextBlock. This can include simple markdown formatting
such as **bold**, *italic*, and [links](https://example.com).

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

### -Size
Controls the size of the text.
Valid values: "Small", "Default", "Medium", "Large", "ExtraLarge"
Default: "Medium"

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

### -Weight
Controls the font weight (boldness) of the text.
Valid values: "Lighter", "Default", "Bolder"
Default: "Default"

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

### -Color
Sets the color of the text.
Valid values: "Default", "Dark", "Light", "Accent", "Good", "Warning", "Attention"
Default: "Default"

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

### -Wrap
Specifies whether the text should wrap to multiple lines when it doesn't fit on a single line.
When set to $false, text that doesn't fit will be truncated.
Default: $true

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
### None. You cannot pipe input to New-AMTextBlock.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the TextBlock element.

## NOTES
TextBlocks are the most common element in Adaptive Cards. Some best practices:

- Use different sizes and weights to create visual hierarchy
- Set Wrap to $true for longer text to ensure readability
- Use markdown sparingly for emphasis, but avoid complex formatting
- Consider using different colors to highlight important information

## RELATED LINKS
* [](https://adaptivecards.io/explorer/TextBlock.html)

