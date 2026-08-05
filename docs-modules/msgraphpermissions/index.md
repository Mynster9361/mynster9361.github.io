---
title: MSGraphPermissions PowerShell Module
sidebar_position: 1
---

# MSGraphPermissions PowerShell Module

A PowerShell implementation of [Kibali](https://github.com/microsoftgraph/kibali) for finding least privileged Microsoft Graph API permissions. The module downloads the latest permissions data straight from the Microsoft Graph repository and gives you cmdlets to query the required permission for any Graph API endpoint - by path, HTTP method, and authentication scheme.

:::note
This is a static, offline lookup against Microsoft's own permissions dataset ("what permission does this endpoint need"), not a report of what your tenant's apps are actually using. For an activity-log-based audit of your own tenant, see [LeastPrivilegedMSGraph](/docs/modules/leastprivilegedmsgraph).
:::

## Key Features

* Automatically fetches the latest permissions data from Microsoft Graph's GitHub repository
* Finds the minimal required permission for any Graph API endpoint
* Query by path, HTTP method, and authentication scheme (Application, DelegatedWork, DelegatedPersonal)
* Wildcard path discovery for exploring the Graph API surface
* Full PowerShell pipeline support

## Requirements

* PowerShell 7.0+
* Internet connection (for downloading the permissions dataset on first use)

## Installation

```powershell
Install-Module -Name MSGraphPermissions -Scope CurrentUser
```

## Quick Start

```powershell
Import-Module MSGraphPermissions

# Downloads and caches the latest permissions data (happens automatically on first use)
Initialize-GraphPermissions

# Find the least privileged permission for an endpoint
Find-GraphLeastPrivilege -Path "/users/{id}/messages" -Method GET -Scheme DelegatedWork
```

```
Path                 Method Scheme        Permission
----                 ------ ------        ----------
/users/{id}/messages GET    DelegatedWork Mail.ReadBasic
```

## Core Cmdlets

### Initialize-GraphPermissions

Downloads and caches the latest Microsoft Graph permissions data.

```powershell
Initialize-GraphPermissions

# Force a fresh download instead of using the cache
Initialize-GraphPermissions -Force
```

### Find-GraphLeastPrivilege

Finds the least privileged permission(s) required for a specific endpoint. `-Path` is required; `-Method` and `-Scheme` narrow the result. Also accepts paths from the pipeline (warns rather than throwing if a path isn't found).

```powershell
Find-GraphLeastPrivilege -Path "/accessreviews" -Method GET -Scheme DelegatedWork
```

```
Path           Method Scheme        Permission
----           ------ ------        ----------
/accessreviews GET    DelegatedWork AccessReview.Read.All
```

Omit `-Method`/`-Scheme` to see every combination for a path:

```powershell
Find-GraphLeastPrivilege -Path "/me/messages"
```

### Get-GraphPermissions

Returns *all* permissions for an endpoint - not just the least privileged one - flagging which are least privileged and which need to be paired with another permission.

```powershell
Get-GraphPermissions -Path "/users/{id}" -Method GET
```

### Find-GraphPath

Searches for API paths matching a wildcard pattern - useful for exploring what's available under a given resource.

```powershell
Find-GraphPath -Pattern "/me/*"
```

## Resources

* [Kibali](https://github.com/microsoftgraph/kibali) - the Microsoft Graph permissions dataset this module is built on
* [Module on PowerShell Gallery](https://www.powershellgallery.com/packages/MSGraphPermissions/)
* [Source on GitHub](https://github.com/Mynster9361/MSGraphPermissions)

## Command Reference

See the [command reference](/docs/modules/msgraphpermissions/commands) for details on every function.
