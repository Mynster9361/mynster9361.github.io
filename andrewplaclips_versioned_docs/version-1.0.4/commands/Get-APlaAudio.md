---
title: Get-APlaAudio
---

# Get-APlaAudio

## SYNOPSIS
Retrieves available Andrew Pla audio clips from the module's data directory.

## SYNTAX

```
Get-APlaAudio [[-AudioName] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the full path to a specific audio file when -AudioName is provided,
or lists the base names of all available .wav files in the module's data folder.

## EXAMPLES

### EXAMPLE 1
```
Get-APlaAudio
```

Returns the base names of all available audio clips.

### EXAMPLE 2
```
Get-APlaAudio -AudioName 'FAFOFTW'
```

Returns the full path to FAFOFTW.wav.

## PARAMETERS

### -AudioName
The name of the audio clip (without the .wav extension) to retrieve the full path for.
If omitted, all available clip names are returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS

