---
title: Get-LPELogActivityData
---

# Get-LPELogActivityData

## SYNOPSIS
Returns Entra ID audit log activity, grouped per user, from a Log Analytics workspace.

## SYNTAX

```
Get-LPELogActivityData [-WorkspaceId] <String> [[-UserId] <String[]>] [[-Days] <Int32>] [-IncludeFailures]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the AuditLogs table in a Log Analytics workspace and, for each user who initiated at least one
audit event, returns the distinct Category/DisplayName activity combinations they performed together with
the first and last time each was seen and how many times it occurred.

The query is restricted to the activities Get-LPEActivityData flags as Relevant ($true) - activities with no
meaningful least-privilege mapping (informational/read-only events, "started (bulk)" markers, etc.) are
excluded so the results only reflect actions that actually required a role or Microsoft Graph permission.

The Category and DisplayName columns match the Category and Activity.DisplayName values used by
Get-LPEActivityData, so the two can be cross-referenced to determine when a privileged user last performed an
activity that required a given least-privileged role or Microsoft Graph permission.

Requires Get-LPEActivityData to be loaded in the session, an existing EntraAuth connection
(Connect-EntraService -Service LogAnalytics) with read access to the Log Analytics workspace, and that
Entra ID audit logs are being streamed to it via diagnostic settings.

## EXAMPLES

### EXAMPLE 1
```
Get-LPELogActivityData -WorkspaceId $workspaceId -UserId $privilegedUsers.Id -Days 90
```

Returns activity for the given privileged users over the last 90 days.

### EXAMPLE 2
```
$activity = Get-LPELogActivityData -WorkspaceId $workspaceId -Days 30
($activity | Where-Object Id -eq $userId).Activities | Where-Object { $_.Category -eq 'AdministrativeUnit' -and $_.DisplayName -eq 'Update administrative unit' }
```

Finds the last time a specific user performed an activity that Get-LPEActivityData maps to a least-privileged permission.

## PARAMETERS

### -WorkspaceId
The Log Analytics workspace ID (customer ID GUID) containing the AuditLogs table.

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

### -UserId
One or more Entra ID user object IDs to restrict the query to (e.g.
the Id values returned by
Get-LPEPrivilegedUser).
If omitted, activity for every user found in the window is returned.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: 90
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeFailures
Every returned activity always carries both ActivityCount (successful occurrences) and FailureCount (failed
occurrences), and LastActivityTime/FirstActivityTime always reflect successful occurrences only.
By default,
activities that never succeeded (ActivityCount 0) are dropped from the results entirely.
Pass this switch to
also include those attempted-but-always-failed activities - useful for spotting users who keep attempting
an action they don't have permission for, which Get-LPEPermissionAnalysis surfaces as DeniedAttempts.

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

### PSCustomObject
## NOTES

## RELATED LINKS

