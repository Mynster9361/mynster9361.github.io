---
layout: page
title: ConvertFrom-AMJson
permalink: /modules/actionablemessages/commands/ConvertFrom-AMJson/
---

# ConvertFrom-AMJson

## SYNOPSIS
Converts an Adaptive Card JSON to PowerShell commands that would create it

## SYNTAX

```powershell
ConvertFrom-AMJson [-Json] <String> [-OutputPath <String>] [-GenerateId <SwitchParameter>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
Takes an Adaptive Card JSON representation and generates the PowerShell commands
using the ActionableMessages module functions that would recreate the card.

## EXAMPLES

### EXAMPLE 1
```powershell
$json = Get-Content -Path "card.json" -Raw
- -Json $json
```


### EXAMPLE 2
```powershell
$json = Get-Content -Path "card.json" -Raw
ConvertFrom-AMJson -Json $json -OutputPath "cardCommands.ps1"
```

## PARAMETERS

### -GenerateId
If specified, new random IDs will be generated for all elements

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
The JSON string representing an Adaptive Card

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
If specified, the commands will be written to this file path

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
### None

## OUTPUTS
### None

## NOTES
Make sure to review and test the generated code before using it in production
