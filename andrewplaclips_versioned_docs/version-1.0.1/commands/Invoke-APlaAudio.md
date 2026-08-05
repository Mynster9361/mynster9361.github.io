---
title: Invoke-APlaAudio
---

# Invoke-APlaAudio

## SYNOPSIS
Plays an Andrew Pla audio clip.

## SYNTAX

```
Invoke-APlaAudio [-AudioName] <String> [-UseVlc] [[-VlcPath] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Plays the specified .wav audio clip from the module's data directory.
By default uses the built-in .NET SoundPlayer.
Use -UseVlc to play
via VLC Media Player instead (requires VLC to be installed).

## EXAMPLES

### EXAMPLE 1
```
Invoke-APlaAudio -AudioName 'FAFOFTW'
```

Plays the FAFOFTW.wav audio clip using the built-in SoundPlayer.

### EXAMPLE 2
```
Invoke-APlaAudio -AudioName 'GG' -UseVlc
```

Plays GG.wav using VLC Media Player.

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
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseVlc
Play the audio using VLC Media Player instead of the built-in SoundPlayer.
VLC must be installed.
The standard installation path is checked automatically.
You can override the path with -VlcPath.

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

### -VlcPath
Full path to vlc.exe.
Only used when -UseVlc is specified.
Defaults to the standard VLC installation path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: C:\Program Files\VideoLAN\VLC\vlc.exe
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

