---
layout: page
title: New-AMImage
permalink: /modules/actionablemessages/commands/New-AMImage/
---

# New-AMImage

## SYNOPSIS
Creates an Image element for an Adaptive Card.

## SYNTAX

```powershell
New-AMImage [-Url] <String> [-AltText <String>] [-Size <String>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates an Image element that displays an image within an Adaptive Card.
Images can be used to display logos, photos, icons, diagrams, or any visual content
that enhances the card's appearance and information.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a simple image
$logo = New-AMImage -Url "https://example.com/logo.png" -AltText "Company Logo"
Add-AMElement -Card $card -Element $logo
```


### EXAMPLE 2
```powershell
# Create a large image with alt text
$banner = New-AMImage -Url "https://example.com/banner.jpg" -Size "Large" -AltText "Product Banner"
```


### EXAMPLE 3
```powershell
# Add an image to a container
$icon = New-AMImage -Url "https://example.com/icon.png" -Size "Small" -AltText "Alert Icon"
$container = New-AMContainer -Id "alert-container" -Style "warning"
```

#### Example explanation
```powershell
Add-AMElement -Card $card -Element $container
Add-AMElement -Card $card -Element $icon -ContainerId "alert-container"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Warning: Action required") -ContainerId "alert-container"
```
## PARAMETERS

### -Url
The URL to the image. This must be a valid and accessible URL that points to the image file.
Required parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AltText
Alternative text for the image, which provides a textual description of the image for
accessibility purposes or in cases where the image cannot be displayed.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size
Controls the size of the image.
Valid values: "Auto", "Stretch", "Small", "Medium", "Large"
Default: "Medium"

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMImage.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Image element.

## NOTES
Images should be hosted on publicly accessible servers to ensure they display correctly.
Consider the following best practices:

- Use appropriate image sizes to avoid slow loading times
- Always include descriptive alt text for accessibility
- Consider using smaller images for mobile viewing
- Remember that some email clients may block external images by default

## RELATED LINKS
- [https://adaptivecards.io/explorer/Image.html](https://adaptivecards.io/explorer/Image.html)
