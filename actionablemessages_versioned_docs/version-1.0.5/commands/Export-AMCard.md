---
title: Export-AMCard
---

# Export-AMCard

## SYNOPSIS
Exports an Adaptive Card as JSON.

## SYNTAX

```
Export-AMCard [-Card] <Hashtable> [-Path <String>] [-Compress] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The \`Export-AMCard\` function converts an Adaptive Card object (hashtable) to JSON format for use in Actionable Messages.
The function can output the JSON directly as a string or save it to a file.
It provides options for compressed output
(no whitespace) or formatted output (with indentation) for better readability.

This function does not modify the original card object.
It is designed to handle deeply nested card structures
and ensures proper serialization of all elements.

Use the \`-Compress\` switch for production environments to reduce the size of the JSON payload, especially when
delivering cards via email where size constraints may apply.

## EXAMPLES

### EXAMPLE 1
```
# Export a card as a formatted JSON string
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Hello World")
$json = Export-AMCard -Card $card
```

### EXAMPLE 2
```
# Export a card as a compressed JSON string
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
$json = Export-AMCard -Card $card -Compress
```

### EXAMPLE 3
```
# Save a card to a file
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Export-AMCard -Card $card -Path "C:\Cards\mycard.json"
```

### EXAMPLE 4
```
# Using pipeline input to export a card
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
$card | Export-AMCard -Path "C:\Cards\mycard.json"
```

## PARAMETERS

### -Card
The Adaptive Card object (hashtable) to convert to JSON.
This should be created using \`New-AMCard\` and populated
with elements using functions like \`Add-AMElement\`.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
(Optional) The file path where the JSON should be saved.
If not specified, the function will return the JSON
as a string.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Compress
(Optional) When specified, produces compressed JSON with no whitespace.
This is useful for production environments
to reduce message size.
When omitted, the JSON will be formatted with indentation for better readability.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Collections.Hashtable
### Accepts an Adaptive Card object created using `New-AMCard` and populated with elements.
## OUTPUTS

### System.String
### - Returns the JSON representation of the card as a string when no `Path` is specified.
### - If `Path` is specified, writes the JSON to the file and does not return a value.
## NOTES
- When exporting cards for production use, consider using the \`-Compress\` switch to reduce the size of the JSON payload.
- The function uses a high depth value (\`100\`) for JSON conversion to ensure that deeply nested card structures
  are properly serialized.
- The JSON output is UTF-8 encoded when saved to a file.

## RELATED LINKS

[https://docs.microsoft.com/en-us/outlook/actionable-messages/](https://docs.microsoft.com/en-us/outlook/actionable-messages/)


