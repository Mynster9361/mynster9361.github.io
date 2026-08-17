---
title: msgraphProxy PowerShell Module
sidebar_position: 1
---

# msgraphProxy PowerShell Module

A PowerShell wrapper around a self-contained [Dev Proxy](https://github.com/dotnet/dev-proxy) build, extended with
two custom plugins:

- **`GraphSchemaMockPlugin`** - mocks any Microsoft Graph v1.0 or beta endpoint straight from its real CSDL schema
  (including `$select`, `$expand`, `$filter`, `$orderby`, `$search` and `$batch`), no hand-written fixtures needed.
- **`EntraTokenMockPlugin`** - mocks the Entra ID token endpoint, so auth flows (including license-gated checks like
  [Maester](https://maester.dev)'s) work end-to-end without a real app registration or tenant.

In short: point your Graph-calling PowerShell code at a fake tenant and get schema-accurate, fabricated responses
back - useful for testing, demos, and CI pipelines that shouldn't need a real Microsoft 365 tenant. No real tenant,
no app registration, and no separate .NET install required on the machine running it (Dev Proxy ships as a
self-contained, RID-specific build).

Shoutout to Daniel Bradley on his awesome post here [Identify minimum graph permissions for scripts with the Dev Proxy](https://ourcloudnetwork.com/identify-minimum-graph-permissions-for-scripts-with-the-dev-proxy/) with out it i had never known about the devproxy project

## Installation

```powershell
Install-Module -Name msgraphProxy -Scope CurrentUser
```

## Available Commands

| Command | Description |
| --- | --- |
| [`Install-MsGraphProxy`](/docs/modules/msgraphproxy/commands/Install-MsGraphProxy) | Downloads and caches the Dev Proxy build for your OS. Called automatically by `Start-MsGraphProxy` if needed. |
| [`Start-MsGraphProxy`](/docs/modules/msgraphproxy/commands/Start-MsGraphProxy) | Starts Dev Proxy, installing it first if needed. Recording starts automatically. |
| [`Stop-MsGraphProxy`](/docs/modules/msgraphproxy/commands/Stop-MsGraphProxy) | Stops Dev Proxy and returns any recorded reports (e.g. minimal Graph permissions used). |
| [`Get-MsGraphProxyStatus`](/docs/modules/msgraphproxy/commands/Get-MsGraphProxyStatus) | Reports whether Dev Proxy is currently running. |
| [`Install-MsGraphProxyCertificate`](/docs/modules/msgraphproxy/commands/Install-MsGraphProxyCertificate) | Trusts Dev Proxy's root certificate for the current user, best-effort. |

Every command ships with full comment-based help - run `Get-Help <command> -Full` for parameters and examples.

## Quick start

```powershell
Import-Module msgraphProxy

# One-time (or after a new Dev Proxy build is released): download the binaries for this OS
Install-MsGraphProxy

# Start Dev Proxy using the bundled configuration
Start-MsGraphProxy

# ...point your Graph calls at https://graph.microsoft.com as usual - Dev Proxy
# intercepts and mocks them while it's running. This also works for anything that
# ends up calling Microsoft Graph under the hood, e.g. the Microsoft Graph SDK or
# the EntraAuth module, not just raw Invoke-RestMethod calls.

Get-MsGraphProxyStatus
Stop-MsGraphProxy
```

See [`sample/Show-Sample.ps1`](https://github.com/Mynster9361/msgraphProxy/blob/main/sample/Show-Sample.ps1) on
GitHub for a runnable end-to-end example, including calling Graph with a real-looking token, calling it with no
token at all, and reading back the minimal-permissions report.

## Recording and minimal permissions

Recording starts automatically the moment Dev Proxy starts (pass `-NoRecord` to `Start-MsGraphProxy` to opt out).
Every Graph call made while it's running gets analyzed, and `Stop-MsGraphProxy` returns the results - including a
least-privilege permissions report, so you can find out exactly which Graph permissions a script or app actually
needs instead of guessing:

```powershell
Start-MsGraphProxy

# ...exercise the code you want a permissions report for...

$r = Stop-MsGraphProxy
$r.Recording.GraphMinimalPermissionsPlugin
```

```text
errors             : {}
minimalPermissions : {User.ReadBasic.All, Application.Read.All}
permissionsType    : Application
requests           : {@{method=GET; requestUrl=/users}, @{method=GET; requestUrl=/applications}}
```

`minimalPermissions` is the smallest set of Graph permissions that covers every request that was made - handy for
tightening an app registration's permissions down from "whatever seemed safe" to "exactly what's used."

> **Note:** not all endpoints have a least-privilege permission registered against them, so treat this as a strong
> starting point rather than a guaranteed-complete list.

## Running in CI

`Start-MsGraphProxy -CI` configures Dev Proxy for a non-interactive session: it routes Graph calls through the proxy
automatically and trusts the root certificate on a best-effort basis, so it also works unattended in a GitHub
Actions/Azure DevOps/etc. pipeline. `-EntraIDLicense` picks which Entra ID license tier the mocked tenant reports
(defaults to `P2`), for license-gated checks like Maester's `Get-MtLicenseInformation`.

```powershell
Import-Module msgraphProxy
Install-MsGraphProxy
$result = Start-MsGraphProxy -CI -Confirm:$false
Write-Host "CertificateTrusted: $($result.CertificateTrusted)"

# ...run your Graph-calling tests here - Microsoft.Graph SDK, EntraAuth, raw
# Invoke-RestMethod, whatever your code uses...

Stop-MsGraphProxy -Confirm:$false
```

The module will in general just be a man in the middle for your requests against msgraph here is a total list of the urls being monitored:

```txt
"https://graph.microsoft.com/v1.0/*",
"https://graph.microsoft.com/beta/*",
"https://graph.microsoft.us/v1.0/*",
"https://graph.microsoft.us/beta/*",
"https://dod-graph.microsoft.us/v1.0/*",
"https://dod-graph.microsoft.us/beta/*",
"https://microsoftgraph.chinacloudapi.cn/v1.0/*",
"https://microsoftgraph.chinacloudapi.cn/beta/*",
"https://login.microsoftonline.com/*/oauth2/*"
"https://graph.microsoft.com/*/external/connections/*/schema",
"https://graph.microsoft.us/*/external/connections/*/schema",
"https://dod-graph.microsoft.us/*/external/connections/*/schema",
"https://microsoftgraph.chinacloudapi.cn/*/external/connections/*/schema"
```

See [`.github/workflows/maester-example.yml`](https://github.com/Mynster9361/msgraphProxy/blob/main/.github/workflows/maester-example.yml)
for a working example: running a limited set of tests from [Maester](https://maester.dev).
Running against this mock instead of a real tenant.

**Source:** [github.com/Mynster9361/msgraphProxy](https://github.com/Mynster9361/msgraphProxy)
