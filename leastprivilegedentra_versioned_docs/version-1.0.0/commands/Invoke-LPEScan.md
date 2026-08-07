---
title: Invoke-LPEScan
---

# Invoke-LPEScan

## SYNOPSIS
Runs a full least-privilege scan against a tenant: connects, gathers privileged users and their audit log
activity, and returns a per-user role usage analysis.

## SYNTAX

### Connect
```
Invoke-LPEScan -TenantId <String> -ClientId <String> -ClientSecret <SecureString> -WorkspaceId <String>
 [-Days <Int32>] [-IncludeFailures] [-OutFile <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### SkipConnect
```
Invoke-LPEScan -WorkspaceId <String> [-Days <Int32>] [-IncludeFailures] [-OutFile <String>] [-SkipConnect]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Wraps the end-to-end LeastPrivilegedEntra workflow:

1.
Connects to Microsoft Graph and Log Analytics via EntraAuth (Connect-EntraService), using an app
   registration's client ID/secret, unless -SkipConnect is passed to reuse an existing connection.
2.
Get-LPEPrivilegedUser enumerates every user holding an Entra ID directory role (active or PIM-eligible).
3.
Get-LPELogActivityData queries the Log Analytics workspace for each privileged user's relevant audit log
   activity over the requested window.
4.
Get-LPEPermissionAnalysis couples the two to produce, per user, per-role usage evidence and a right-sizing
   suggestion (roles to remove/keep/add).

Optionally writes the analysis to a JSON file via -OutFile.

## EXAMPLES

### EXAMPLE 1
```
$secret = "secret" | ConvertTo-SecureString -AsPlainText -Force
Invoke-LPEScan -TenantId $tenantId -ClientId $appId -ClientSecret $secret -WorkspaceId $workspaceId
```

Connects to the tenant and returns the full per-user role usage analysis.

### EXAMPLE 2
```
Invoke-LPEScan -TenantId $tenantId -ClientId $appId -ClientSecret $secret -WorkspaceId $workspaceId -Days 30 -OutFile ".\PrivilegedUsersAnalysis.json"
```

Runs the scan over a 30-day window and writes the results to a JSON file.

## PARAMETERS

### -TenantId
The Entra ID tenant ID (GUID) to connect to.

```yaml
Type: String
Parameter Sets: Connect
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
The application (client) ID of the app registration used to authenticate.

```yaml
Type: String
Parameter Sets: Connect
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
The application's client secret, as a SecureString.

```yaml
Type: SecureString
Parameter Sets: Connect
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspaceId
The Log Analytics workspace ID (customer ID GUID) containing the AuditLogs table.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Days
Number of days of audit log history to query.
Default is 90.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 90
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeFailures
By default only activities that succeeded are returned.
Pass this switch to also include failed attempts.

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

### -OutFile
Optional path to write the analysis results to as JSON.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipConnect
Skip calling Connect-EntraService, and reuse an already-established EntraAuth connection
(Graph and LogAnalytics services must already be connected).

```yaml
Type: SwitchParameter
Parameter Sets: SkipConnect
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

### PSCustomObject
## NOTES

## RELATED LINKS

