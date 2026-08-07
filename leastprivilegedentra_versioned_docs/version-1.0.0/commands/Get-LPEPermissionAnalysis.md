---
title: Get-LPEPermissionAnalysis
---

# Get-LPEPermissionAnalysis

## SYNOPSIS
Couples each privileged user's roles with evidence of whether they actually used them, and suggests a
right-sized role set.

## SYNTAX

```
Get-LPEPermissionAnalysis [-PrivilegedUser] <PSObject[]> [[-ActivityLog] <PSObject[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Combines the output of three functions to answer, per user, "which of these roles does this person
actually need?":

- Get-LPEPrivilegedUser supplies which roles each user holds (Active or Eligible, direct or via group).
- Get-LPELogActivityData supplies which relevant audit log activities each user actually performed, and when.
- Get-LPEActivityData supplies the least-privileged role (and Microsoft Graph permission) required for each
  audit log activity, which is what lets a role be matched back to the activities it grants.

Returns one object per user, containing:

- Roles: one entry per role the user holds, with a Status ("Used" / "NotUsedInWindow" / "NoMappedActivity")
  and a RelatedActivities drill-down listing every activity Get-LPEActivityData maps to that role, whether the
  user actually performed it, and when.
"NoMappedActivity" means usage can't be observed from audit logs at
  all (e.g.
read-only roles), so no removal is ever suggested for it.
- Suggestion: a right-sizing recommendation built from everything the user actually did, independent of
  which roles they currently hold:
    - RemoveRoles: held roles with no corresponding activity in the queried window.
    - KeepRoles: held roles that are either justified by observed activity or can't be evaluated at all.
    - AddRoles: roles implied by the user's activity that they do not currently hold - typically because a
      broader role (e.g.
Global Administrator) is covering for a narrower one (e.g.
User Administrator)
      that would have sufficed.
    - DeniedAttempts: roles the user does not hold and never successfully exercised via another role, but
      repeatedly attempted (and were denied) actions that map to.
Only populated when ActivityLog was
      collected with Get-LPELogActivityData -IncludeFailures; otherwise always empty.

Requires Get-LPEActivityData to be loaded in the session.

## EXAMPLES

### EXAMPLE 1
```
$privilegedUsers = Get-LPEPrivilegedUser
$activityLog = Get-LPELogActivityData -WorkspaceId $workspaceId -UserId $privilegedUsers.Id -Days 90
Get-LPEPermissionAnalysis -PrivilegedUser $privilegedUsers -ActivityLog $activityLog
```

Returns one object per privileged user, with their per-role usage evidence and a right-sizing suggestion.

### EXAMPLE 2
```
Get-LPEPermissionAnalysis -PrivilegedUser $privilegedUsers -ActivityLog $activityLog |
    Where-Object { $_.Suggestion.RemoveRoles } |
    Select-Object DisplayName, @{N = 'RemoveRoles'; E = { $_.Suggestion.RemoveRoles -join ', ' } }
```

Lists every user with at least one unused role, and which role(s) to remove.

### EXAMPLE 3
```
(Get-LPEPermissionAnalysis -PrivilegedUser $privilegedUsers -ActivityLog $activityLog |
    Where-Object DisplayName -eq 'Jane Doe').Roles.RelatedActivities
```

Shows the full activity-by-activity breakdown behind every role a specific user holds.

## PARAMETERS

### -PrivilegedUser
One or more user objects as returned by Get-LPEPrivilegedUser (must have Id and a Roles collection).

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ActivityLog
Zero or more user activity objects as returned by Get-LPELogActivityData (must have Id and an Activities
collection).
Users with no corresponding entry - including when this is omitted entirely - are treated as
having no logged activity, so every role they hold is reported as "NotUsedInWindow".

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @()
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

