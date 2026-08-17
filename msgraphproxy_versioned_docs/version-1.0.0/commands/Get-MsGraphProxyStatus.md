---
title: Get-MsGraphProxyStatus
---

# Get-MsGraphProxyStatus

## SYNOPSIS
Reports whether the Dev Proxy process started by Start-MsGraphProxy is
still running.

## SYNTAX

```
Get-MsGraphProxyStatus [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads the state file written by Start-MsGraphProxy and checks whether
the process it recorded is still alive.
Returns an object with:
	Running    - whether the process is currently alive
	Id         - its process ID
	ConfigFile - the devproxyrc.json it was started with
	ExePath    - path to the Dev Proxy executable
	ApiPort    - its control-API port
	Recording  - whether it's currently recording
	StartedAt  - when it was started
If Start-MsGraphProxy was never called (or Stop-MsGraphProxy already
cleaned up), all of these are $false/$null.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGraphProxyStatus
```

Returns an object describing whether Dev Proxy is currently running.

## PARAMETERS

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

[https://mynster-it.dk/docs/modules/msgraphProxy/commands/Get-MsGraphProxyStatus](https://mynster-it.dk/docs/modules/msgraphProxy/commands/Get-MsGraphProxyStatus)


