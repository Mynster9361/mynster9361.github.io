---
title: Install-MsGraphProxy
---

# Install-MsGraphProxy

## SYNOPSIS
Downloads and installs the self-contained Dev Proxy build this module wraps.

## SYNTAX

```
Install-MsGraphProxy [[-Rid] <String>] [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Downloads the zipped, self-contained Dev Proxy build (bundled with this
module's GraphSchemaMockPlugin and EntraTokenMockPlugin extensions)
from this repository's latest GitHub release, and extracts it into the
module's local binary cache - no separate DOTNET installation needed on
this machine.

If a build for the target RID is already cached, this does nothing
unless -Force is passed.
Start-MsGraphProxy calls this automatically
the first time it needs to, so you normally don't need to call it
yourself.

## EXAMPLES

### EXAMPLE 1
```
Install-MsGraphProxy
```

Downloads and installs the Dev Proxy build matching the current OS.

### EXAMPLE 2
```
Install-MsGraphProxy -Force
```

Re-downloads and reinstalls the Dev Proxy build, replacing whatever is
already cached.

## PARAMETERS

### -Rid
The DOTNET runtime identifier to install a build for.
Defaults to the RID
matching the current operating system.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ($script:MsGraphProxyRid ?? (Get-MsGraphProxyRid))
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Reinstall even if a build for this RID is already cached.

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

## OUTPUTS

## NOTES

## RELATED LINKS

[https://mynster-it.dk/docs/modules/msgraphProxy/commands/Install-MsGraphProxy](https://mynster-it.dk/docs/modules/msgraphProxy/commands/Install-MsGraphProxy)


