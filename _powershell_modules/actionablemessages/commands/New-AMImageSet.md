---
layout: page
title: New-AMImageSet
permalink: /modules/actionablemessages/commands/New-AMImageSet/
---

# New-AMImageSet

## SYNOPSIS
Creates an ImageSet element for an Adaptive Card.

## SYNTAX

`powershell
New-AMImageSet [-Images] <String[]> [-AltText <String>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
``r

## DESCRIPTION
Creates an ImageSet element that displays a collection of images in a grid layout.
ImageSets are useful when you need to show multiple related images together, such as
product galleries, photo collections, or thumbnails.

The images are automatically arranged in a grid based on available space, and all
images within the set share the same size.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple image set with three images
$imageUrls = @(
    "https://example.com/product1.jpg",
    "https://example.com/product2.jpg",
    "https://example.com/product3.jpg"
)
``r

$productGallery = New-AMImageSet -Images $imageUrls -AltText "Product Photos"
Add-AMElement -Card $card -Element $productGallery    

### EXAMPLE 2
`powershell
# Create an image set from local files
$baseUrl = "https://storage.contoso.com/images/"
$fileNames = @("photo1.jpg", "photo2.jpg", "photo3.jpg", "photo4.jpg")
$imageUrls = $fileNames | ForEach-Object { $baseUrl + $_ }
``r

$photoGallery = New-AMImageSet -Images $imageUrls -AltText "Vacation Photos"    

## PARAMETERS

### -Images
An array of image URLs to include in the ImageSet. Each URL must point to a valid
and accessible image file.

`yaml
Type: String[]
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -AltText
Alternative text for the image set, providing a textual description for
accessibility purposes. This alt text will be applied to all images in the set.
Default: "Image Set"

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
### None. You cannot pipe input to New-AMImageSet.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the ImageSet element.

## NOTES
ImageSets are designed to display collections of similarly-sized images.
For best results:

- Use images of similar dimensions and aspect ratios
- Keep the number of images reasonable (4-8 is typically optimal)
- Remember that images will be resized to fit the layout
- Ensure all image URLs are publicly accessible

## RELATED LINKS
* [](https://adaptivecards.io/explorer/ImageSet.html)

