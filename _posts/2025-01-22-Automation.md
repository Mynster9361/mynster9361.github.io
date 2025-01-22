---
title: Authenticating to Microsoft Graph API
author: <1>
date: 2025-01-22 14:43:00 +0100
categories: [Microsoft Graph, Authentication]
tags: [powershell, msgraph]
description: Demonstrating different methods to authenticate to Microsoft Graph API using PowerShell.
---

# Authenticating to Microsoft Graph API

In this post, I'll demonstrate three different methods to authenticate to the Microsoft Graph API using PowerShell. These methods include using the device code flow, client secret, and certificate-based authentication.

## 1. Authenticating Using Device Code Flow

The device code flow is useful for scenarios where a user needs to authenticate interactively on a device that doesn't have a browser. This method is demonstrated in the script below:

### Example Script

```powershell
<#
.SYNOPSIS
    Demonstrates how to authenticate using the device code flow with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate a user interactively using the device code flow.
    It retrieves a device code, prompts the user to authenticate, and then requests an access token.

.NOTES
    MS Docs on how to use Ms Graph API with device code flow:
    https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code

    Remember to enable "Allow public client flows" under Authentication - Advanced settings on the app registration
    otherwise you will get an error.

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.EXAMPLE
    # Set environment variables for tenantId and clientId
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"

    # Follow the instructions to authenticate and obtain an access token.
#>

# Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId1

# Interactive login for the MS Graph API
$response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -Method POST -Body @{
    client_id     = $clientId
    scope         = "user.read"
}
# Extract device code, user code and verification uri
$deviceCode = $response.device_code
$userCode = $response.user_code
$verificationUrl = $response.verification_uri

# Open authentication url in default browser
Start-Process $verificationUrl
# Display instructions to the user
Write-Host "Please type in the following code: $userCode"
Pause "Press Enter to continue..."

# Once the user has authenticated, request a token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "urn:ietf:params:oauth:grant-type:device_code"
    device_code   = $deviceCode
}
$tokenResponse
```


## 2. Authenticating Using Client Secret

The client secret method is suitable for server-to-server communication where a client secret is used to authenticate the application. This method is demonstrated in the script below:

### Example Script

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

## 3. Authenticating Using Certificate

The certificate-based authentication method is more secure than using a client secret and is suitable for scenarios where enhanced security is required. This method is demonstrated in the script below:

### Example Script

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

# Request a token
$token = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion = $JWT
    grant_type    = "client_credentials"
}

# Output the token
$token
```

These scripts demonstrate different methods to authenticate to the Microsoft Graph API using PowerShell. Choose the method that best suits your scenario and security requirements.
