---
title: Stop-MsGraphProxy
---

# Stop-MsGraphProxy

## SYNOPSIS
Stops the Dev Proxy process started by Start-MsGraphProxy.

## SYNTAX

```
Stop-MsGraphProxy [[-TimeoutSeconds] <Int32>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
If Dev Proxy is recording, first stops the recording through its
control API.
That triggers its reporting plugins (Graph minimal
permissions, execution summary) to analyze what was recorded; their
results are returned as part of the result object, under Recording.

Then asks Dev Proxy to shut down gracefully through its control API.
If it doesn't stop within -TimeoutSeconds, the process is force-killed
instead, and any Windows system-proxy registration is cleared
manually (a graceful shutdown does this on its own).

## EXAMPLES

### EXAMPLE 1
```
Stop-MsGraphProxy
```

Stops the running Dev Proxy instance and returns any recorded reports.

## PARAMETERS

### -TimeoutSeconds
How long to wait for a graceful shutdown before falling back to killing
the process outright.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
If this switch is enabled, no actions are performed but informational
messages will be displayed that explain what would happen if the command
were to run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
If this switch is enabled, you will be prompted for confirmation before
executing any operations that change state.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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

## NOTES

## RELATED LINKS

[https://mynster-it.dk/docs/modules/msgraphProxy/commands/Stop-MsGraphProxy](https://mynster-it.dk/docs/modules/msgraphProxy/commands/Stop-MsGraphProxy)


