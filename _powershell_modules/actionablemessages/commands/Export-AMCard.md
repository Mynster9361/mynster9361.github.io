---
layout: page
title: Export-AMCard
permalink: /modules/actionablemessages/commands/Export-AMCard/
---

# Export-AMCard

## SYNOPSIS
Exports an Adaptive Card as JSON.

## SYNTAX

```powershell
Export-AMCard [-Card] <Hashtable> [-Path <String>] [-Compress <SwitchParameter>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
Converts an Adaptive Card object to JSON format for use in Actionable Messages.
The function can output the JSON directly or save it to a file. It provides options
for compressed output (no whitespace) or formatted output (with indentation) for
better readability.

This function does not modify the original card object.

## EXAMPLES

### EXAMPLE 1
```powershell
# Export a card as formatted JSON string
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Hello World")
$json = Export-AMCard -Card $card
```


### EXAMPLE 2
```powershell
# Export a card as compressed JSON string
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
$json = Export-AMCard -Card $card -Compress
```


### EXAMPLE 3
```powershell
# Save a card to a file
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Export-AMCard -Card $card -Path "C:\Cards\mycard.json"
```


### EXAMPLE 4
```powershell
# Using pipeline input
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
$card | Export-AMCard -Path "C:\Cards\mycard.json"
```

## PARAMETERS

### -Compress
Optional switch. When specified, produces compressed JSON with no whitespace.
This is useful for production environments to reduce message size.
When omitted, the JSON will be formatted with indentation for better readability.

```yaml
Type: Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Optional. The file path where the JSON should be saved.
If not specified, the function will return the JSON as a string.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Card
The Adaptive Card object (hashtable) to convert to JSON.

```yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### System.Collections.Hashtable
An Adaptive Card object created using New-AMCard and populated with elements.

## OUTPUTS
### System.String
When no Path is specified, returns the JSON representation of the card as a string.

## NOTES
When exporting cards for production use, consider using the -Compress switch to reduce
the size of the JSON payload, especially for email delivery where size may be a concern.

The function uses a high depth value (100) for JSON conversion to ensure that deeply
nested card structures are properly serialized.

## RELATED LINKS
- [https://docs.microsoft.com/en-us/outlook/actionable-messages/](https://docs.microsoft.com/en-us/outlook/actionable-messages/)
