---
title: Invoke-APlaAudio
---

# Invoke-APlaAudio

## SYNOPSIS
Plays an Andrew Pla audio clip.

## SYNTAX

### ByName (Default)
```
Invoke-APlaAudio [-AudioName] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Random
```
Invoke-APlaAudio [-Random] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Plays the specified .wav audio clip from the module's data directory.
By default uses the built-in .NET SoundPlayer.
Use -Random to play a
randomly selected clip.

## EXAMPLES

### EXAMPLE 1
```
Invoke-APlaAudio -AudioName 'FAFOFTW'
```

Plays the FAFOFTW.wav audio clip using the built-in SoundPlayer.

### EXAMPLE 2
```
Invoke-APlaAudio -Random
```

Plays a randomly selected audio clip.

### EXAMPLE 3
```
Get-APlaAudio | ForEach-Object { Invoke-APlaAudio -AudioName $_ }
```

Plays every available audio clip in sequence.

## PARAMETERS

### -AudioName
The name of the audio clip to play, without the .wav extension.
Use Get-APlaAudio to list available clip names.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Random
Plays a randomly selected audio clip from the available clips.

```yaml
Type: SwitchParameter
Parameter Sets: Random
Aliases:

Required: True
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

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS

