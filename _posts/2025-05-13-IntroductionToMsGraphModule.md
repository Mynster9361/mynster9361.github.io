---
title: Getting Started with Microsoft Graph PowerShell - A Comprehensive Guide
author: mynster
date: 2025-05-13 20:30:00 +0100
categories: [PowerShell, Microsoft Graph]
tags: [powershell, msgraph, microsoft graph, authentication, api]
description: Learn how to get started with Microsoft Graph PowerShell SDK, including authentication, finding commands, permissions, and practical examples.
---

## Introduction to Microsoft Graph PowerShell SDK

I recently hosted a talk on the [PDQ Discord for a PowerShell Wednesday](https://discord.gg/pdq){:target="_blank"}

You can watch the session here if you prefer to watch rather than read.

{% include embed/youtube.html id='hyuEvG_LNvw' %}


In this session we walked through:
- Installing the Microsoft Graph PowerShell modules
- Authentication options (delegated, client secret, and certificate)
- Finding the right commands and permissions
- Filtering and query optimization
- Debugging your Graph requests
- Practical examples including sending an email

## Installation and Setup

Installing the Microsoft Graph PowerShell SDK is straightforward using the PowerShell Gallery:

```powershell
# Install the core Microsoft Graph module (recommended for current user only)
Install-Module Microsoft.Graph -Scope CurrentUser

# If you need beta endpoints, install the beta module as well
Install-Module Microsoft.Graph.Beta -Scope CurrentUser
```

Pro tip: Only import the specific modules you need rather than the entire collection. The full Microsoft Graph module contains over 25,000 commands when including beta endpoints!

```powershell
# Import specific modules instead of the entire collection
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
```

Why? you might ask let me give you to time stamp for import of the complete `Microsoft.Graph` compared to the 2 listed above

```powershell
Measure-Command {
  Import-Module Microsoft.Graph.Authentication
  Import-Module Microsoft.Graph.Users
}
<#
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 4
Milliseconds      : 114
Ticks             : 41142211
TotalDays         : 4,76182997685185E-05
TotalHours        : 0,00114283919444444
TotalMinutes      : 0,0685703516666667
TotalSeconds      : 4,1142211
TotalMilliseconds : 4114,2211
#>

# Compared to:

Measure-Command {
    Import-Module Microsoft.Graph
}
<#
Days              : 0
Hours             : 0
Minutes           : 4
Seconds           : 50
Milliseconds      : 607
Ticks             : 2906076527
TotalDays         : 0,00336351449884259
TotalHours        : 0,0807243479722222
TotalMinutes      : 4,84346087833333
TotalSeconds      : 290,6076527
TotalMilliseconds : 290607,6527
#>
```


## Authentication Methods

Microsoft Graph offers several authentication methods, each suitable for different scenarios in this session we only covered 3 (User auth, Client Secret, Certificate):

### 1. Interactive (Delegated) Authentication

Best for testing or when running scripts manually:

```powershell
# Authenticate with delegated permissions (browser login)
Connect-MgGraph -Scopes "User.Read.All"

# You can specify multiple scopes
Connect-MgGraph -Scopes "User.Read.All","Mail.Send"

# You can also specify a tenant ID
Connect-MgGraph -TenantId "contoso.onmicrosoft.com" -Scopes "User.Read.All"
```

### 2. Client Secret Authentication

Best for automated scripts and applications:

```powershell
# Create credential object using app ID and client secret
$appId = "appid"
$secret = "secret"

# Client secret auth (for automation)
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appId, (ConvertTo-SecureString -String $secret -AsPlainText -Force)
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $credential
```

### 3. Certificate Authentication

Best for secure automation without storing and using secrets:

```powershell
# Create a self-signed certificate (for development only)
$certName = "GraphAPIAccess"
$cert = New-SelfSignedCertificate -Subject "CN=$certName" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256

# Export the certificate for uploading to Azure AD
Export-Certificate -Cert $cert -FilePath ".\$certName.cer"

# Remember to upload the cert to your application otherwise you will get a failure when trying to connect.

# Connect using certificate
Connect-MgGraph -TenantId $tenantId -CertificateThumbprint $cert.Thumbprint -AppId $clientId
```

After connecting, you can check your authentication context:

```powershell
# Check your authentication context
Get-MgContext

# View detailed scope information
(Get-MgContext).Scopes
```

## Finding Commands and Required Permissions

The Microsoft Graph PowerShell SDK includes thousands of commands, making it essential to have efficient search strategies:

### Finding Commands

```powershell
# Find all commands related to users
Find-MgGraphCommand -Command "*user*"

# Find specific commands for managing user calendars
Find-MgGraphCommand -Command "*user*calendar*"

# Filter by HTTP method
Find-MgGraphCommand -Method "GET" -Uri ".*users.*"

# Filter by API version
Find-MgGraphCommand -ApiVersion v1.0 -Command "*user*"

# Find by URI pattern
Find-MgGraphCommand -Uri "/users/{id}"
```

### Finding Required Permissions

For each command, you'll need specific permissions:

```powershell
# cmdlet
Find-MgGraphPermission

# Diving deeper into the permissions you can just search for specific keywords that you are interested in like Calendar and specifying which type of permission you are looking for.
Find-MgGraphPermission Calendar
Find-MgGraphPermission Calendar -PermissionType 'Delegated'
Find-MgGraphPermission Calendar -PermissionType 'Application'

# You could also find it using the command and expandin the property permissions but due note that not all commands currently has this permission attached to it.
Find-MgGraphCommand -Command Get-MgUserCalendar | Select-Object -ExpandProperty Permissions | Select-Object Name, PermissionType, IsAdmin, Description, FullDescription | Sort-Object PermissionType | Format-Table

# Finding all the permissions that a user can consent to the below command only looks at the endpoints for user if you wanted all just remove the `user`
Find-MgGraphPermission user -PermissionType "Delegated" | Where-Object Consent -EQ "User"

# Finding all the permissions that a Admin has to consent to the below command only looks at the endpoints for user if you wanted all just remove the `user`
Find-MgGraphPermission user -PermissionType "Application"
```

You can also explore permissions for specific commands:

```powershell
# Get detailed permission information
Find-MgGraphCommand -Command "Get-MgUserCalendar" | Select-Object -First 1 | Select-Object -ExpandProperty Permissions
```

## Using Filters and Improving Query Performance

Microsoft Graph supports OData filters that can significantly improve performance by reducing the data transferred:

```powershell
# Simple query - gets the first 100 users
Get-MgUser

# to get all just add -All
Get-MgUser -All

# Filtered query - only enabled users
Get-MgUser -Filter "accountEnabled eq true"

# Multiple filter conditions
Get-MgUser -Filter "accountEnabled eq true and startsWith(city, 'Seattle')"

# Filter and select specific properties
Get-MgUser -Filter "accountEnabled eq true" -Select "displayName,mail,jobTitle"

# Limit the number of results
Get-MgUser -Top 5 -Filter "accountEnabled eq true"
```

### Debugging Filter Syntax

The OData filter syntax can be challenging as it is a bit diffrent from what we are used to from powershell.
I can recommend using the following techniques to create or debug your filter:

1. Use the Microsoft Graph Explorer web interface at [https://developer.microsoft.com/graph/graph-explorer](https://developer.microsoft.com/graph/graph-explorer)
2. Build you filter in the Azure/Entra portal and monitor the network traffic to get the filters
   1. Press F12 in your browser
   2. Go to the Network tab
   3. Filter for "fetch/XHR" requests
   4. Look for requests to graph.microsoft.com
3. Ask an AI to assist you with the filter but test it and make sure it works as expected

```powershell
# Example of a complex filter from Graph Explorer
# Here we are getting only the "accounts that are enabled" from users whose city starts with "Se" and their department has to start with "Mark"
Get-MgUser -Filter "accountEnabled eq true and startsWith(city,'Se') and startsWith(department,'Mark')"
```

## Debugging Graph Requests

When troubleshooting, these techniques can help:

### Examining HTTP Requests

```powershell
# Add debug parameter to see full HTTP requests/responses
Get-MgUser -Debug
```
Right just going over each box 1 by 1
1. The first box lets us know how our current session is authenticated in this case we are using a delegated scope and have authenticated interactively
2. The second box shows us which scopes we have authenticated our session with in this
3. Shows us the exact HTTP request.
   1. HTTP Method: GET
   2. Abosolute Uri: https://graph.microsoft.com/v1.0/users
   3. Headers sent with the request
   4. And finaly our body which in this case is empty
4. The final box contains the actual result from your query if it is a success

![debug](/assets/img/posts/2025-05-13-IntroductionToMsGraphModuleDebug.png)



### Using Browser Developer Tools Quick tip

1. Press F12 in your browser
2. Go to the Network tab
3. Filter for "fetch/XHR" requests
4. Look for requests to graph.microsoft.com

### Common Error Types you will meet and what they mean

- 401 Unauthorized: Authentication issues
- 403 Forbidden: Permission problems
- 404 Not Found: Resource doesn't exist
- 400 Bad Request: Incorrectly formatted request

## Practical Examples

### Sending an Email with Graph API

```powershell
# Connect with Mail.Send permission
Connect-MgGraph -Scopes "Mail.Send"

# Create email parameters
$params = @{
    message = @{
        subject = "Test Email from Graph API"
        body = @{
            contentType = "HTML"
            content = "<h1>Hello from Microsoft Graph!</h1><p>This is a test email sent via PowerShell.</p>"
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "recipient@example.com"
                }
            }
        )
    }
    saveToSentItems = $true
}

# Send the email
$userId = "your-user-id-or-upn"
Send-MgUserMail -UserId $userId -BodyParameter $params
```

## Best Practices

1. **Use specific scopes**: Request only the permissions your application needs
2. **Prefer delegated over application permissions** when possible
3. **Use filters** to reduce data transfer and improve performance
4. **Use proper authentication** for your scenario (interactive for user context, client credentials/certificate for automation)
5. **Check the documentation** when you encounter issues

## Conclusion

The Microsoft Graph PowerShell SDK provides a powerful way to access Microsoft 365 resources. By understanding authentication options, efficiently finding commands and permissions, and using appropriate filters, you can build robust automation solutions.

For more information, check these resources:
- [Microsoft Graph PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/microsoftgraph/)
- [Microsoft Graph API Reference](https://docs.microsoft.com/en-us/graph/api/overview)
- [Microsoft Graph Explorer](https://developer.microsoft.com/graph/graph-explorer)
