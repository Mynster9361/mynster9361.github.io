---
title: Authenticating to Microsoft Graph with EntraAuth
authors: mynster
date: 2026-09-21
tags: [powershell, msgraph, authentication, entra]
description: A recap of a two-part PowerShell Wednesday series on authenticating to Microsoft Graph (and other Microsoft APIs) with the EntraAuth module, covering delegated and application authentication.
---

A recap of a two-part PowerShell Wednesday series on authenticating to Microsoft Graph with the EntraAuth module, covering delegated and application authentication.

<!-- truncate -->

## Intro

A little while back I joined Andrew Pla over on [PDQ's Discord](https://discord.gg/pdq) for two episodes of PowerShell Wednesday to talk about authenticating to Microsoft Graph (and other Microsoft APIs) using [EntraAuth](https://www.powershellgallery.com/packages/EntraAuth), a module by Friedrich "Fred" Weinmann.

Part 1 was about delegated authentication, Part 2 about application authentication. Both were done live, low prep, low setup - basically "watch us stumble through it" so you don't have to. This post is the write-up with the parts that matter, the videos, and links to the full code.

If you want to follow along yourself, the code from the sessions is published on my GitHub in the [SpeakerPresentations repo](https://github.com/Mynster9361/SpeakerPresentations/tree/main/2026):
- Part 1: [DelegatedAuthentication.ps1](https://github.com/Mynster9361/SpeakerPresentations/blob/main/2026/DelegatedAuthentication%20-%20PDQ/DelegatedAuthentication.ps1)
- Part 2: [readme.md](https://github.com/Mynster9361/SpeakerPresentations/blob/main/2026/ApplicationAuthentication%20-%20PDQ/readme.md)

## Why EntraAuth

You can absolutely authenticate to Microsoft Graph (or Azure, Key Vault, Log Analytics, Security, Endpoint, etc.) by hand - build the token request, handle the redirects, cache and refresh the token yourself. I've done it. It works, but you end up rebuilding the same plumbing for every auth flow you support, and then again for the next project.

EntraAuth wraps all of that into three commandlets you'll use constantly:

- `Connect-EntraService` - authenticate, regardless of the method
- `Get-EntraToken` - see what you're currently authenticated with
- `Invoke-EntraRequest` - make a request against whichever service you connected to, without hand-rolling `Invoke-RestMethod`

Plus `Get-EntraService` to see which services are available (Graph, GraphBeta, Azure, KeyVault, Security, LogAnalytics, Endpoint, and you can register your own). Install it with:

```powershell
Install-Module EntraAuth -Scope CurrentUser -Force
```

## Part 1: Delegated authentication

<div class="youtube-embed"><iframe src="https://www.youtube.com/embed/OtWMrmlCvwQ" title="YouTube video" allowfullscreen></iframe></div>

Delegated authentication means a user is logging in - the application acts *as* that user, with whatever permissions that user (and the app registration) has been granted.

### Interactive (browser) login

The simplest possible flow:

```powershell
Connect-EntraService -ClientID Graph
Get-EntraToken
```

`Graph` here is one of a few built-in client IDs Fred has pre-registered in the module (`Graph`, `Azure`, ...) so you don't have to go create an app registration just to try things out. Run it and you get a normal browser login window - authenticate like you would to any Microsoft 365 sign-in.

### Finding your tenant ID without exposing your token

Once you're connected, a handy first request is getting your tenant ID:

```powershell
Invoke-EntraRequest -Path 'organization?$select=id'
```

You *can* also pull it out of `Get-EntraToken | Format-List *`, since the token object carries the client ID and tenant ID too - but that same object also has your access token and refresh token on it. Those are your actual session secrets, so avoid printing or logging the full token object unless you have a reason to.

### Device code authentication

```powershell
Connect-EntraService -DeviceCode -ClientID Graph -TenantID <Tenant-ID>
Get-EntraToken
```

This gives you a URL and a short code to type in on another device - useful for something like a conference room screen with no keyboard. It's also a well-known phishing vector: whoever *starts* the device code flow is the one who receives the resulting token, not whoever types in the code. Send someone a link and a code, they log in on their end, and you walk away with their session.

Because of that, block device code authentication with Conditional Access unless you specifically need it, and only allow it for the accounts/scenarios that do. Newer tenants that have Security Defaults enabled get this blocked by default already (Microsoft rolled this out mid-2026).

### Reusing your session with a refresh token

Delegated tokens expire after about an hour. Rather than prompting the user again, reuse the refresh token:

```powershell
$refreshToken = Get-EntraToken
Connect-EntraService -RefreshTokenObject $refreshToken
```

`Get-EntraToken` will show you a `Type` property (`Browser`, `DeviceCode`, `Refresh`, ...) so you always know how the current session got authenticated.

### Reusing a token from another module (Az.Accounts)

If you're already authenticated with `Az.Accounts` - say, inside a runbook that already has an Azure context - you don't need to authenticate a second time:

```powershell
Connect-AzAccount
Connect-EntraService -AsAzAccount
Get-EntraToken
```

This works because most of Microsoft's newer APIs sit on the same underlying auth model, so a token issued for one can, with the right scope, be handed to another.

### Connecting to multiple services without multiple prompts

If you need Graph, Graph beta, and Azure in the same session, there are a few ways to avoid logging in three separate times:

```powershell
# Method 1: one Connect-EntraService call, multiple services (will prompt once per service)
Connect-EntraService -Service Graph, GraphBeta, Azure -ClientID Azure

# Method 2: authenticate once via Az.Accounts, reuse it for everything
Connect-AzAccount
Connect-EntraService -AsAzAccount -Service Graph, GraphBeta, Azure

# Method 3: authenticate once, then extend the session to the rest with the refresh token
Connect-EntraService -Service Graph -ClientID Graph
Connect-EntraService -Service Graph, GraphBeta, Azure -UseRefreshToken -ClientID Graph
```

Methods 2 and 3 are the ones you actually want in scripts and automation - a single login, then every other service just rides along on that session.

### Setting up an app registration for delegated auth

The built-in `Graph`/`Azure` client IDs are great for testing, but for anything real you'll want your own app registration:

1. **App registrations -> New registration.**
2. **Authentication -> Add a platform -> Mobile and desktop applications**, add `http://localhost` as a redirect URI, and switch **Allow public client flows** to **Yes**. This is required because a PowerShell session doing delegated auth is a "public client" - it can't keep a secret.
3. **API permissions**: remove the default `User.Read` permission if you don't need it, then add the **delegated** Microsoft Graph permissions your app actually needs. Don't click admin consent here - delegated permissions are meant to be consented to by the signed-in user, not pre-approved by an admin, unless you deliberately want the whole org to skip that prompt.
4. Go to **Enterprise applications -> your app -> Properties** and set **Assignment required** to **Yes**, then add the users/groups allowed to use it under **Users and groups**. Otherwise, anyone in the tenant can sign into your app.

> **Note:** if a user tries to consent to a permission that needs admin approval, they'll be blocked and can submit a request for an admin to review - if you've enabled that workflow under **Enterprise applications -> Security -> Admin consent settings**.

One more thing worth setting up if you're in a larger org: **Enterprise applications -> Security -> Consent and permissions -> Permission classifications**. You can mark low-risk delegated permissions (`email`, `offline_access`, `openid`, `profile`, and often `User.Read`) as ones users are allowed to self-consent to. That alone cuts down a huge amount of "can you approve this app" requests without loosening anything sensitive.

## Part 2: Application authentication

<div class="youtube-embed"><iframe src="https://www.youtube.com/embed/SE-GzZxoaiw" title="YouTube video" allowfullscreen></iframe></div>

Application authentication has no user behind it - the app acts as itself, using whatever **application permissions** (not delegated) it's been granted. That also means there's no refresh token concept: when you need new permissions to take effect, or the token expires, you just reauthenticate.

### Client secret authentication

The simplest option, and the one I'd recommend the least. Create the app registration, then under **Certificates & secrets -> Client secrets -> New client secret**, copy the value the moment you create it - you won't see it again.

```powershell
$tenantId = "<Tenant-ID>"
$clientId = "<client_id>"
$clientSecret = Read-Host -AsSecureString

Connect-EntraService -ClientID $clientId -TenantID $tenantId -ClientSecret $clientSecret

Get-EntraToken | Select-Object -ExcludeProperty TokenData, AccessToken, ClientID, TenantID, Issuer
```

`Get-EntraToken` will now show `Type: ClientSecret` and roughly an hour of validity. If you haven't granted the app any API permissions yet, it's still authenticated - it just can't do anything, which is a good default to be in.

### Certificate authentication

More secure than a secret, since only the public key ever leaves your machine. For a quick test, a self-signed certificate works:

```powershell
$certname = "Mynster"
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048

Export-Certificate -Cert $cert -FilePath "./$certname.cer"
```

Upload that `.cer` file under **Certificates & secrets -> Certificates** on the app registration, then connect with either the certificate object directly, or its thumbprint from the local certificate store:

```powershell
$tenantId = "<Tenant-ID>"
$certClientId = "<client_id>"

# Using the certificate object directly
Connect-EntraService -ClientID $certClientId -TenantID $tenantId -Certificate $cert

# Or, if it's installed in the certificate store
Connect-EntraService -ClientID $certClientId -TenantID $tenantId -CertificateThumbprint $cert.Thumbprint

Get-EntraToken | Select-Object -ExcludeProperty TokenData, AccessToken, ClientID, TenantID, Issuer
```

In production, get the certificate from your own CA rather than self-signing it, and move it straight from wherever it's issued into your secrets manager (Key Vault, etc.) instead of passing it around manually.

### Federated credentials (no secret at all)

This is the one I'd reach for over a client secret or certificate whenever the platform supports it: no password or key ever leaves GitHub (or whichever provider issues the OIDC token) - Entra just trusts tokens signed for a specific repo and branch. Setup, using GitHub Actions as an example:

1. **App registration -> Certificates & secrets -> Federated credentials -> Add credential -> GitHub Actions deploying Azure resources.**
2. Fill in your GitHub **organization** and **repository** name, entity type **Branch**, and the branch name (e.g. `main`).
3. You'll also be asked for an **Organization ID** and **Repository ID** - these are the numeric IDs behind your GitHub org/repo, not the names. Pinning the trust to the IDs instead of the names means a renamed or transferred repo can't silently inherit the federated credential. In the GitHub repo, go to **Settings -> Actions -> General -> Enable "Use immutable subject claim"**, which is where these IDs come from. If you can't find them there, GitHub's API gives you both: `https://api.github.com/users/<username>` and `https://api.github.com/repos/<owner>/<repo>`.

Then in the workflow itself:

```yaml
name: test

on:
    workflow_dispatch:

jobs:
    get-token:
        runs-on: windows-latest
        permissions:
            id-token: write # Required to fetch an OIDC token.
        steps:
            - name: Get an Entra token via the federated credential
              shell: pwsh
              run: |
                  Install-Module EntraAuth -Scope CurrentUser -Force
                  Connect-EntraService -ClientID $env:CLIENT_ID -TenantID $env:AZURE_TENANT_ID -Federated
                  Get-EntraToken | Select-Object -ExcludeProperty TokenData, AccessToken, ClientID, TenantID, Issuer
              env:
                  AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
                  CLIENT_ID: ${{ secrets.CLIENT_ID }}
```

Store the tenant ID and client ID as repository secrets (**Settings -> Secrets and variables -> Actions**). The `id-token: write` permission on the job is what lets GitHub mint the short-lived OIDC token that Entra exchanges for a Graph token - without it, the `-Federated` connection will fail.

### Managed identity

If your code is already running on an Azure resource (an Automation Account, Function App, VM, ...), skip credentials entirely. First grant the managed identity's application permissions - for example, `User.Read.All`:

>NOTE: I know there is a MVP ([Christian Ritter](https://www.linkedin.com/in/christian-ritter-9661a41b2/)) that is working on something in regards to assiging permissions to a Managed identity to make it easier and more powershell native link to the [github repo](https://github.com/HCRitter/MIAU)


```powershell
$miId = "" # The managed identity's object/principal ID

$miRoleAssignment = @{
    principalId = $miId
    resourceId  = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    appRoleId   = "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All (Application)
}

Invoke-EntraRequest -Path "servicePrincipals/$miId/appRoleAssignments" -Body $miRoleAssignment
```

Then, from that resource:

```powershell
Connect-EntraService -Identity
Get-EntraToken | Select-Object -ExcludeProperty TokenData, AccessToken, ClientID, TenantID, Issuer
```

No secret or certificate to create, rotate, or accidentally leak - Azure handles the credential lifecycle entirely.

## Which one should you actually use?

If you take one thing away from both sessions, it's this rough priority order for application authentication:

1. **Managed identity** - if the code runs on Azure, use this.
2. **Federated credentials** - if you're running from somewhere that can issue OIDC tokens (GitHub Actions, Azure DevOps, ...).
3. **Certificate** - if neither of the above is an option.
4. **Client secret** - last resort, mainly for the handful of APIs that still only support it. I'll also accept it for testing something quikly as long as it is cleaned up again.

And for delegated authentication: keep device code blocked unless you have a specific reason not to, and don't grant admin consent on delegated permissions unless you actually mean for every user of the app to skip the consent prompt.

## Links

- [EntraAuth on the PowerShell Gallery](https://www.powershellgallery.com/packages/EntraAuth)
- [EntraAuth on GitHub](https://github.com/FriedrichWeinmann/EntraAuth)
- [Part 1 code - Delegated authentication](https://github.com/Mynster9361/SpeakerPresentations/blob/main/2026/DelegatedAuthentication%20-%20PDQ/DelegatedAuthentication.ps1)
- [Part 2 code - Application authentication](https://github.com/Mynster9361/SpeakerPresentations/blob/main/2026/ApplicationAuthentication%20-%20PDQ/readme.md)
- [PDQ Discord](https://discord.gg/pdq)
