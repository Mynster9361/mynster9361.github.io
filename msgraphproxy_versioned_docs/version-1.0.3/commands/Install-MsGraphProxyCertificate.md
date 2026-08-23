---
title: Install-MsGraphProxyCertificate
---

# Install-MsGraphProxyCertificate

## SYNOPSIS
Trusts the running Dev Proxy instance's root CA certificate for the
current user.

## SYNTAX

```
Install-MsGraphProxyCertificate [[-ApiPort] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Fetches Dev Proxy's root CA certificate from its control API and
trusts it for the current OS user, so HTTPS clients accept the
certificates Dev Proxy generates for intercepted requests without any
client-side accommodation (like skipping certificate validation).

Supported on Windows (via certutil), Linux (via
update-ca-certificates) and macOS (via the current user's login
keychain).
This is best-effort, not guaranteed: trusting a
certificate can require an interactive confirmation dialog, which
will never resolve in a non-interactive session (most commonly hit
via Start-MsGraphProxy -CI).
Rather than hang waiting for it, this
function waits up to 15 seconds and then returns $false with a
warning instead of throwing, so callers can decide for themselves
whether to fall back to skipping certificate validation in their own
requests.
On a genuine interactive desktop session, trust normally
succeeds and the confirmation dialog (Windows only) can just be
answered.

## EXAMPLES

### EXAMPLE 1
```
Install-MsGraphProxyCertificate
```

Fetches and trusts the root certificate of the Dev Proxy instance
using the default control-API port.

## PARAMETERS

### -ApiPort
Port of Dev Proxy's control API.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $script:MsGraphProxyDefaultApiPort
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

### System.Boolean
## NOTES

## RELATED LINKS

[https://mynster-it.dk/docs/modules/msgraphProxy/commands/Install-MsGraphProxyCertificate](https://mynster-it.dk/docs/modules/msgraphProxy/commands/Install-MsGraphProxyCertificate)


