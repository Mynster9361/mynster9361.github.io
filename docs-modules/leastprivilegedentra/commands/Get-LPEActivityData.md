---
title: Get-LPEActivityData
---

# Get-LPEActivityData

## SYNOPSIS
Returns the least-privileged Microsoft Entra RBAC role and Microsoft Graph permission required for an audit log activity.

## SYNTAX

```
Get-LPEActivityData [-Category] <String> [[-Name] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Looks up a Microsoft Entra ID audit log Category, and optionally a specific Activity display name, in the
built-in activity-to-permission map and returns the least privileged Entra RBAC role and Microsoft Graph
permission needed to perform that activity.

## EXAMPLES

### EXAMPLE 1
```
Get-LPEActivityData -Category AdministrativeUnit -Name "Add administrative unit"
```

Returns the least privileged RBAC role and Graph permission for adding an administrative unit.

### EXAMPLE 2
```
Get-LPEActivityData -Category UserManagement -Name "*password*"
```

Returns the least privileged permissions for every UserManagement activity whose name contains "password".

### EXAMPLE 3
```
Get-LPEActivityData -Category * | Where-Object Relevant
```

Returns every activity, across all categories, that is flagged as relevant.

## PARAMETERS

### -Category
The audit log Category to look up (e.g.
"AdministrativeUnit", "UserManagement", "GroupManagement").
Supports wildcards; pass "*" to return every category.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Name
The audit log Activity display name to look up (e.g.
"Add administrative unit").
Supports wildcards.
If omitted, every activity in the category is returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
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

