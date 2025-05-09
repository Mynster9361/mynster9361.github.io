---
layout: page
title: ConvertFrom-AMJson
permalink: /modules/actionablemessages/commands/ConvertFrom-AMJson/
---

# ConvertFrom-AMJson

## SYNOPSIS
Converts an Adaptive Card JSON to PowerShell commands using the ActionableMessages module.

## SYNTAX

```powershell
ConvertFrom-AMJson [-Json] <String> [-OutputPath <String>] [-GenerateId <SwitchParameter>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `ConvertFrom-AMJson` function takes an Adaptive Card JSON string and generates equivalent PowerShell
commands that would create the same card using the ActionableMessages module functions.

This function is useful for:
- Converting existing Adaptive Cards to PowerShell code
- Learning by example how to create complex cards
- Migrating from other platforms that export Adaptive Cards as JSON
- Generating reusable scripts from designer-created cards

The generated code follows best practices for the ActionableMessages module and maintains proper nesting
of elements within containers, column sets, and other structures.

If the JSON contains unsupported element types, they will be commented in the output script for manual review.

## EXAMPLES

### EXAMPLE 1
```powershell
# Convert JSON from a file and display the PowerShell commands
$jsonContent = Get-Content -Path ".\myAdaptiveCard.json" -Raw
ConvertFrom-AMJson -Json $jsonContent
```


### EXAMPLE 2
```powershell
# Convert JSON and save the PowerShell commands to a file
$jsonContent = Get-Content -Path ".\designerCard.json" -Raw
ConvertFrom-AMJson -Json $jsonContent -OutputPath ".\createCard.ps1"
```


### EXAMPLE 3
```powershell
# Convert JSON from a web response
$response = Invoke-RestMethod -Uri "https://myapi.example.com/cards/template"
$response.cardJson | ConvertFrom-AMJson
```


### EXAMPLE 4
```powershell
# Convert JSON and generate new IDs for elements
$jsonContent = Get-Content -Path ".\card.json" -Raw
ConvertFrom-AMJson -Json $jsonContent -GenerateId
```

## PARAMETERS

### -GenerateId
(Optional) When specified, generates new IDs for elements that don't have them. This can be useful when
you need to reference elements later in your code.

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

### -Json
The Adaptive Card JSON string to convert to PowerShell commands.
This can be a complete Adaptive Card JSON object with schema, type, version, etc.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### -OutputPath
(Optional) If specified, writes the generated PowerShell script to this file path instead of returning it
as a string.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### System.String
Accepts a JSON string representing an Adaptive Card.

## OUTPUTS
### System.String or None
- Returns the generated PowerShell script as a string if no `OutputPath` is specified.
- If `OutputPath` is specified, writes the script to the file and returns a confirmation message.

## NOTES
- This function supports all standard Adaptive Card elements and actions, including:
  TextBlocks, Images, ImageSets, Containers, ColumnSets, FactSets, Input elements, and various action types.
- Unsupported element types will be commented in the output script for manual review.
- Variable names in the generated script are based on element types and IDs when available.
- The function ensures proper nesting of elements and maintains the structure of the original card.

## RELATED LINKS
- [https://adaptivecards.io/explorer/](https://adaptivecards.io/explorer/)
- Export-AMCard
