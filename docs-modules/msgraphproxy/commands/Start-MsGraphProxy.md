---
title: Start-MsGraphProxy
---

# Start-MsGraphProxy

## SYNOPSIS
Starts the self-contained Dev Proxy build in its own process.

## SYNTAX

```
Start-MsGraphProxy [[-ConfigFile] <String>] [[-ApiPort] <Int32>] [-NoRecord] [-Force] [-CI]
 [[-EntraIDLicense] <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Launches the cached Dev Proxy executable against a devproxyrc.json
configuration, and tracks the resulting process so Stop-MsGraphProxy
and Get-MsGraphProxyStatus can find it again later, even from a
different PowerShell session.
If Dev Proxy hasn't been installed yet
for this OS, it's installed automatically first (see
Install-MsGraphProxy).

Recording starts automatically with the proxy, so Stop-MsGraphProxy
can stop it again and return the resulting reports (such as minimal
Graph permissions) as an object.
Pass -NoRecord to opt out.

While running, Dev Proxy intercepts and mocks calls to the hosts
listed in its "urlsToWatch" configuration (Microsoft Graph and the
Entra ID token endpoint, by default), tunnelling everything else
through untouched.

## EXAMPLES

### EXAMPLE 1
```
Start-MsGraphProxy
```

Starts Dev Proxy using the configuration bundled with this module, recording from the start.

### EXAMPLE 2
```
Start-MsGraphProxy -ConfigFile 'C:\proxy\devproxyrc.json' -ApiPort 9000
```

Starts Dev Proxy with a custom configuration and control-API port.

### EXAMPLE 3
```
Start-MsGraphProxy -CI
```

Starts Dev Proxy configured for a CI pipeline: no certificate prompt to
block startup, HTTP_PROXY/HTTPS_PROXY set for the current process, and
its root certificate trusted automatically where possible.

## PARAMETERS

### -ConfigFile
Path to a devproxyrc.json/.yaml configuration file.
Defaults to the
configuration bundled with this module.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $script:MsGraphProxyDefaultConfigFile
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiPort
Port for Dev Proxy's control API, used by Stop-MsGraphProxy for a
graceful shutdown.
Defaults to Dev Proxy's own default port, 8897.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $script:MsGraphProxyDefaultApiPort
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRecord
Don't start recording automatically.
Without this switch, Dev Proxy
starts recording immediately so Stop-MsGraphProxy has something to stop
and report on.

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

### -Force
Start a new instance even if one is already tracked as running.

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

### -CI
Configure Dev Proxy for a non-interactive session (CI pipelines,
Pester runs, etc.) instead of normal interactive use: sets
HTTP_PROXY/HTTPS_PROXY for the current session so Graph calls route
through the proxy, and trusts Dev Proxy's root certificate
automatically on a best-effort basis (see the returned object's
CertificateTrusted property, and Install-MsGraphProxyCertificate's
help for what "best-effort" means).

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

### -EntraIDLicense
Which Entra ID license tier the mocked tenant's subscribedSkus should
report - Free, P1, P2 or Governance.
Defaults to P2, so license-gated
checks (e.g.
Maester's Get-MtLicenseInformation) see a licensed tenant
out of the box.
Pass -EntraIDLicense explicitly to pick a different
tier.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: P2
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

[https://mynster-it.dk/docs/modules/msgraphProxy/commands/Start-MsGraphProxy](https://mynster-it.dk/docs/modules/msgraphProxy/commands/Start-MsGraphProxy)


