---
title: Client ID and Certificate Authentication to Microsoft Graph API
author: mynster
date: 2025-01-23 22:30:00 +0100
categories: [Microsoft Graph, Authentication]
tags: [powershell, msgraph]
description: Demonstrating Client ID and Certificate Authentication to Microsoft Graph
---


# Authenticating to Microsoft Graph API

In this post, I'll demonstrate how to authenticate to the Microsoft Graph API using Client ID and Certificate in PowerShell.
The certificate-based authentication method is more secure than using a client secret and is suitable for scenarios where enhanced security is required. This method is demonstrated in the script below:

## First off we need to create the app registration in Azure/Entra

Go to App Registrations page and click create "New registration"
![img-description](/assets/img/posts/2025-01-23 19_36_54-App registrations - Microsoft Azure.png)

Give it a new and click "Register"
![img-description](/assets/img/posts/2025-01-23 19_38_29-Register an application - Microsoft Azure.png)

On the front page of the new app also called "Overview" we need to get the "Directory (tenant) ID" and "Application (client) ID"
![img-description](/assets/img/posts/2025-01-23 19_43_12-Some Name - Microsoft Azure.png)

Go to the "Certificates & secrets" page and click "Certificates" tab and "Upload certificate"
- Note if you do not have a certificate then you can generate a self signed certificate by following this article from Microsoft
- [https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-self-signed-certificate](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-self-signed-certificate)

![img-description](/assets/img/posts/2025-01-23 22_07_49-Upload certificate - Microsoft Azure.png)

### Now lets take what we just created and ask for a token

First off we need to define or variables for authentication take the tenant id, client id and the thumbprint we made above in our instance it would be the following
- Note we need to have the certificate installed in the user context that we are using to authenticate.
```powershell
# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = "Your-tenant-id"
$clientId = "Your-client-id"
$thumbprint = "Your-Certificate-thumbprint"
```

Next up we need to configure our body for authenticaton.
By looking at [Microsoft documentation](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow#second-case-access-token-request-with-a-certificate)
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
      <td>The directory tenant the application plans to operate against, in GUID or domain-name format.</td>
    </tr>
    <tr>
      <td>client_id</td>
      <td>Required</td>
      <td>The application (client) ID that's assigned to your app.</td>
    </tr>
    <tr>
      <td>scope</td>
      <td>Required</td>
      <td>The value passed for the scope parameter in this request should be the resource identifier (application ID URI) of the resource you want, suffixed with .default. All scopes included must be for a single resource. Including scopes for multiple resources will result in an error. For the Microsoft Graph example, the value is <code>https://graph.microsoft.com/.default</code>. This value tells the Microsoft identity platform that of all the direct application permissions you have configured for your app, the endpoint should issue a token for the ones associated with the resource you want to use. To learn more about the /.default scope, see the consent documentation.</td>
    </tr>
    <tr>
      <td>client_assertion_type</td>
      <td>Required</td>
      <td>The value must be set to <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>.</td>
    </tr>
    <tr>
      <td>client_assertion</td>
      <td>Required</td>
      <td>An assertion (a JSON web token) that you need to create and sign with the certificate you registered as credentials for your application. Read about certificate credentials to learn how to register your certificate and the format of the assertion.</td>
    </tr>
    <tr>
      <td>grant_type</td>
      <td>Required</td>
      <td>Must be set to <code>client_credentials</code>.</td>
    </tr>
  </tbody>
</table>

Right now that we have an understanding of what the endpoint expects then we can start creating our JSON web Token
```powershell
# Get the certificate from the certificate store
$cert = Get-Item Cert:\CurrentUser\My\$thumbPrint

# Create JWT header
$JWTHeader = @{
    alg = "RS256"
    typ = "JWT"
    x5t = [System.Convert]::ToBase64String($cert.GetCertHash())
}
# Create JWT payload
$JWTPayload = @{
    aud = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    iss = $clientId
    sub = $clientId
    jti = [System.Guid]::NewGuid().ToString()
    nbf = [math]::Round((Get-Date).ToUniversalTime().Subtract((Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()).TotalSeconds)
    exp = [math]::Round((Get-Date).ToUniversalTime().AddMinutes(10).Subtract((Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()).TotalSeconds)
}

# Encode JWT header and payload
$JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json -Compress))
$EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte) -replace '\+', '-' -replace '/', '_' -replace '='

$JWTPayLoadToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json -Compress))
$EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte) -replace '\+', '-' -replace '/', '_' -replace '='

# Join header and Payload with "." to create a valid (unsigned) JWT
$JWT = $EncodedHeader + "." + $EncodedPayload

# Get the private key object of your certificate
$PrivateKey = ([System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert))

# Define RSA signature and hashing algorithm
$RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
$HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256

# Create a signature of the JWT
$Signature = [Convert]::ToBase64String(
    $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT), $HashAlgorithm, $RSAPadding)
) -replace '\+', '-' -replace '/', '_' -replace '='

# Join the signature to the JWT with "."
$JWT = $JWT + "." + $Signature

# Creating the Body
$tokenBody = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion = $JWT
    grant_type    = "client_credentials"
}
```

Now this is a bit more complicated than device code authentication and secret authentication. I am to be honest not to sure how to explain it on text so everyone can understand it and if you need to use certifacte authentication it might be better to either use the msgraph module or another framework that utilizes the SDK as this part is already handled for you.
On to getting the token now that we have the body we can do the following:

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
    Demonstrates how to authenticate using a certificate with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a certificate.
    It creates a JWT (JSON Web Token) signed with the certificate's private key and requests an access token using the client credentials flow.

.NOTES
    MS Docs on how to use Ms Graph API with certificate-based authentication:
    https://learn.microsoft.com/en-us/azure/active-directory/develop/active-directory-certificate-credentials

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.PARAMETER thumbPrint
    The thumbprint of the certificate to use for authentication.

.EXAMPLE
    # Set environment variables for tenantId, clientId, and thumbPrint
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"
    $env:thumbPrint = "your-certificate-thumbprint"

    # The script will output the access token.
#>

# Tenant ID, Client ID, and Certificate Thumbprint for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId3
$thumbPrint = $env:thumbPrint

# Get the certificate from the certificate store
$cert = Get-Item Cert:\CurrentUser\My\$thumbPrint

# Create JWT header
$JWTHeader = @{
    alg = "RS256"
    typ = "JWT"
    x5t = [System.Convert]::ToBase64String($cert.GetCertHash())
}

# Create JWT payload
$JWTPayload = @{
    aud = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    iss = $clientId
    sub = $clientId
    jti = [System.Guid]::NewGuid().ToString()
    nbf = [math]::Round((Get-Date).ToUniversalTime().Subtract((Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()).TotalSeconds)
    exp = [math]::Round((Get-Date).ToUniversalTime().AddMinutes(10).Subtract((Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()).TotalSeconds)
}

# Encode JWT header and payload
$JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json -Compress))
$EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte) -replace '\+', '-' -replace '/', '_' -replace '='

$JWTPayLoadToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json -Compress))
$EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte) -replace '\+', '-' -replace '/', '_' -replace '='

# Join header and Payload with "." to create a valid (unsigned) JWT
$JWT = $EncodedHeader + "." + $EncodedPayload

# Get the private key object of your certificate
$PrivateKey = ([System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert))

# Define RSA signature and hashing algorithm
$RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
$HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256

# Create a signature of the JWT
$Signature = [Convert]::ToBase64String(
    $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT), $HashAlgorithm, $RSAPadding)
) -replace '\+', '-' -replace '/', '_' -replace '='

# Join the signature to the JWT with "."
$JWT = $JWT + "." + $Signature

# body
$tokenBody = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion = $JWT
    grant_type    = "client_credentials"
}

# Request a token
$token = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Output the token
$token
```

These scripts demonstrate different methods to authenticate to the Microsoft Graph API using PowerShell. Choose the method that best suits your scenario and security requirements.
