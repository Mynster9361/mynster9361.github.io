---
layout: page
title: New-AMCard
permalink: /modules/actionablemessages/commands/New-AMCard/
---

# New-AMCard

## SYNOPSIS
Creates a new Adaptive Card object.

## SYNTAX

```powershell
New-AMCard [-Version <String>] [-OriginatorId] <String> [-HideOriginalBody <Boolean>] [-Padding <String>] [-BackgroundImage <String>] [-RTL <Boolean>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-AMCard` function creates a new Adaptive Card hashtable that serves as the foundation for building
an Adaptive Card. This is typically the first function you call when creating a new card.

The card object created by this function will contain the basic structure needed for an Adaptive Card,
including empty collections for body elements and actions.

You can customize the card's schema version, originator ID, padding, background image, and right-to-left (RTL) rendering.
The `OriginatorId` parameter is required for sending Actionable Messages via Outlook and must be registered
with Microsoft for production use.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a basic card
$card = New-AMCard -OriginatorId "1234567890" -Version "1.0"
```


### EXAMPLE 2
```powershell
# Create a card with a background image
$card = New-AMCard -OriginatorId "1234567890" -Version "1.0" -BackgroundImage "https://example.com/image.jpg"
```


### EXAMPLE 3
```powershell
# Create a card with right-to-left support
$card = New-AMCard -OriginatorId "1234567890" -Version "1.0" -RTL $true
```


### EXAMPLE 4
```powershell
# Create a card with custom padding
$card = New-AMCard -OriginatorId "1234567890" -Version "1.0" -Padding "Large"
```

## PARAMETERS

### -Version
The version of the Adaptive Card schema to use.
Valid values: "1.0", "1.1", "1.2", "1.3", "1.4", "1.5"
Default: "1.0"

Different versions support different card features:
- 1.0: Basic layout and elements
- 1.1: Adds support for additional features like horizontal alignment
- 1.2: Adds support for more advanced features and styling options
- 1.3+: Adds support for the latest Adaptive Card features

For Outlook Actionable Messages, always use version "1.0".

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

### -OriginatorId
A unique identifier for the sender of the card. For Outlook Actionable Messages,
this should be the originator ID registered with Microsoft.

This ID is critical for security purposes, as it validates that your organization
is authorized to send Actionable Messages and make HTTP requests to your endpoints.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HideOriginalBody
Specifies whether to hide the original email body when displaying the card.

When set to `$true` (default), only the Adaptive Card is displayed in the email.
When set to `$false`, both the original email text and the card are displayed.

Default: `$true`

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Padding
Specifies the padding setting for the card.
Valid values: "None", "Default", "Small", "Medium", "Large", "ExtraLarge"
Default: "Default"

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackgroundImage
URL to an image that will be used as the background for the card.

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

### -RTL
When set to `$true`, renders the card in right-to-left mode.
Default: `$false`

```yaml
Type: Boolean
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
### None. You cannot pipe input to `New-AMCard`.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Adaptive Card structure.

## NOTES
- The `OriginatorId` is required for Outlook Actionable Messages. You must register
  your originator ID with Microsoft before using it in production through the Actionable
  Email Developer Dashboard at https://aka.ms/publishactionableemails.
- For testing purposes in development environments, any value can be used.
- After creating a card, use `Add-AMElement` along with element creation functions
  like `New-AMTextBlock` and `New-AMImage` to populate the card with content.

## RELATED LINKS
- [https://docs.microsoft.com/en-us/outlook/actionable-messages/
https://adaptivecards.io/explorer/](https://docs.microsoft.com/en-us/outlook/actionable-messages/
https://adaptivecards.io/explorer/)
- https://docs.microsoft.com/en-us/outlook/actionable-messages/
https://adaptivecards.io/explorer/
