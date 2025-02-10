---
title: Client ID and Secret Authentication to Microsoft Graph API
author: 1
date: 2025-01-23 21:30:00 +0100
categories: [Microsoft Graph, Authentication]
tags: [powershell, msgraph]
description: Demonstrating Client ID and Secret Authentication to Microsoft Graph
---


# Authenticating to Microsoft Graph API

In this post, I'll demonstrate how to authenticate to the Microsoft Graph API using Client ID and Secret in PowerShell.
The client secret method is suitable for server-to-server communication where a client secret is used to authenticate the application.


## First off we need to create the app registration in Azure/Entra

Go to App Registrations page and click create "New registration"
![img-description](/assets/img/posts/2025-01-23 19_36_54-App registrations - Microsoft Azure.png)

Give it a new and click "Register"
![img-description](/assets/img/posts/2025-01-23 19_38_29-Register an application - Microsoft Azure.png)

On the front page of the new app also called "Overview" we need to get the "Directory (tenant) ID" and "Application (client) ID"
![img-description](/assets/img/posts/2025-01-23 19_43_12-Some Name - Microsoft Azure.png)

Go to the "Certificates & secrets" page and click "New client secret"
![img-description](/assets/img/posts/2025-01-23 19_40_04-Add a client secret - Microsoft Azure.png)

Now you should see your new secret (Save this for later as it will not always be visible on the app registration)
![img-description](/assets/img/posts/2025-01-23 19_41_28-Some Name - Microsoft Azure.png)

### Now lets take what we just created and ask for a token

First off we need to define or variables for authentication take the tenant id, client id and the secret we made above in our instance it would be
```powershell
# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = "Your-tenant-id"
$clientId = "Your-client-id"
$clientSecret = "Your-Secret"
```

Next up we need to configure our body for authenticaton.
By looking at [Microsoft documentation](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow#get-a-token)
We can see that we need to provide the following information in our body:
<table>
<thead>
<tr>
<th>Parameter</th>
<th>Condition</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tenant</td>
<td>Required</td>
<td>Your tenant id</td>
</tr>
<tr>
<td>client_id</td>
<td>Required</td>
<td>Your client id</td>
</tr>
<tr>
<td>scope</td>
<td>Required</td>
<td>You only need to specify anything if you are not going to hit the default endpoint</td>
</tr>
<tr>
<td>client_secret</td>
<td>Required</td>
<td>Your client secret</td>
</tr>
<tr>
<td>grant_type</td>
<td>Required</td>
<td>client_credentials</td>
</tr>
</tbody>
</table>


Right now that we have an understanding of what the endpoint expects then we can form our body from that like shown here:
```powershell
# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
```

Easy as that now all we need is to send a request to Azure/Entra for the token on the endpoint/host specified in the documentation "https://login.microsoftonline.com/tenantId/oauth2/v2.0/token"

```powershell
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody
# Output the token
$tokenResponse
```

And you are done now you have a token you can use to make api request to microsoft graph if you need assitance as to how, you can see one of my other blog posts.

#### Complete Script with Synopsis

```powershell
<#
.SYNOPSIS
    Demonstrates how to authenticate using a client secret with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret.
    It requests an access token using the client credentials flow.

.NOTES
    MS Docs on how to use Ms Graph API with client credentials flow:
    https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.PARAMETER clientSecret
    The client secret of the registered application.

.EXAMPLE
    # Set environment variables for tenantId, clientId, and clientSecret
    $env:tenantId = "your-tenant-id"
    $env:clientIdSecret = "your-client-id"
    $env:clientSecret = "your-client-secret"

    # The script will output the access token.
#>

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId2
$clientSecret = $env:clientSecret

# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}

# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Output the token
$tokenResponse
```
