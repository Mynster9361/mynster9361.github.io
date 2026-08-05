---
title: LeastPrivilegedMSGraph PowerShell Module
sidebar_position: 1
---

# LeastPrivilegedMSGraph PowerShell Module

A PowerShell module that analyzes your tenant's Microsoft Graph Activity Logs and compares them against each application's assigned permissions, so you can see exactly which permissions are actually being used and which can be safely removed.

## Key Features

* Reports on both application and delegated Microsoft Graph permissions
* Flags apps with excessive permissions (assigned but unused, or higher-privileged than needed)
* Flags apps with no Microsoft Graph activity at all - the easy wins for cleanup
* Surfaces Microsoft Graph throttling statistics per app
* Generates a self-contained HTML report you can share or archive

## Prerequisites

* An Entra ID **P1 or P2** license (required for Microsoft Graph Activity Logs) - check under the Entra Overview page if you're not sure which one you have
* A Log Analytics workspace with Entra diagnostic settings sending **MicrosoftGraphActivityLogs** to it
* An app registration with:
  * `Log Analytics Reader` on the Log Analytics workspace
  * `Application.Read.All` (add `Directory.Read.All` too if you also want to audit delegated permissions - it's the least-privileged role that can query `/oauth2permissiongrants`)

## Installation

```powershell
Install-Module -Name LeastPrivilegedMSGraph -Scope CurrentUser
```

## Quick Start

```powershell
$tenantId = "Your tenant id"
$clientId = "App id"
$clientSecret = "App secret" | ConvertTo-SecureString -AsPlainText -Force
$daysToQuery = 5 # How far back the report should look
$logAnalyticsWorkspaceId = "Workspace id from the Log Analytics overview page"

Import-Module LeastPrivilegedMSGraph

Initialize-LPMSLogAnalyticsApi

# Connect-EntraService comes from the EntraAuth module, not this one
Connect-EntraService -Service "LogAnalytics", "GraphBeta" -ClientID $clientId -TenantID $tenantId -ClientSecret $clientSecret

$msGraphReport = Get-LPMSAppRoleAssignment
$msGraphReport | Get-LPMSAppActivityData -WorkspaceId $logAnalyticsWorkspaceId -Days $daysToQuery # defaults to 100k entries per app, -MaxActivityEntries goes up to 500k
$msGraphReport | Get-LPMSAppThrottlingData -WorkspaceId $logAnalyticsWorkspaceId -Days $daysToQuery
$msGraphReport | Get-LPMSPermissionAnalysis
Export-LPMSPermissionAnalysisReport -AppData $msGraphReport -OutputPath ".\report.html"
```

That produces an HTML report you can open straight in a browser.

## Reading the Report

* **No Activity** - apps holding Microsoft Graph permissions (often just the default `User.Read`) with zero recorded activity. The quickest cleanup: most of these can be removed without further investigation.
* **Excessive Permissions** - apps whose assigned permissions are broader than what they actually request. For example, an app calling `GET /groups` only needs `GroupMember.Read.All`, so being assigned `Group.ReadWrite.All` instead would land it here.
* **Optimal Permissions** - apps that already match their permissions to their actual usage.
* **Unmatched Activities** - requests the module couldn't map to a known permission yet; each affected app lists the specific endpoints so you can investigate manually.
* **Throttling** - per-app Microsoft Graph throttling stats, useful if you're chasing down apps hitting rate limits.

## Resources

* [Step by step guide for getting up and running with least privileged msgraph](/2026/02/26/LeastPrivilegedMSGraphSetup) - the full walkthrough with screenshots: Log Analytics workspace setup, Entra diagnostic settings, app registration, and how to read every section of the report
* [Module on PowerShell Gallery](https://www.powershellgallery.com/packages/LeastPrivilegedMSGraph/)

## Command Reference

See the [command reference](/docs/modules/leastprivilegedmsgraph/commands) for details on every function.
