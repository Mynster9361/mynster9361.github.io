---
title: Get-LPEPrivilegedUser
---

# Get-LPEPrivilegedUser

## SYNOPSIS
Returns every user who holds any Microsoft Entra ID directory role, whether actively assigned or PIM-eligible.

## SYNTAX

```
Get-LPEPrivilegedUser [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Enumerates every Entra ID directory role definition, resolves its active and PIM-eligible assignments, and
expands any role-assigned groups to their member users (Entra ID role-assignable groups do not currently
support nested group membership, so only one level of expansion is needed).
Returns one object per user,
with a Roles property listing every role/assignment-type/via-group combination that makes them privileged.

Falls back to the legacy roleAssignments endpoint for tenants without Entra ID P2/Governance (PIM).

Requires an existing EntraAuth connection (Connect-EntraService -Service Graph) with at least
RoleManagement.Read.Directory, GroupMember.Read.All, and User.ReadBasic.All.
Without User.ReadBasic.All,
GroupMember.Read.All is enough to enumerate group membership but not to read displayName/userPrincipalName for
members resolved via a role-assignable group, so those users come back with both fields blank.

## EXAMPLES

### EXAMPLE 1
```
Get-LPEPrivilegedUser
```

Returns one object per privileged user, each with a Roles list of their active/eligible role assignments.

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

### PSCustomObject
## NOTES

## RELATED LINKS

[https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#highly-privileged-roles](https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#highly-privileged-roles)


