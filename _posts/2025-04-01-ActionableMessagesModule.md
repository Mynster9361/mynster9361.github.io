---
title: ActionableMessages PowerShell Module - Building Interactive Emails Made Easy
author: mynster
date: 2025-04-01 22:45:00 +0100
categories: [PowerShell, Modules]
tags: [powershell, msgraph, mail, adaptive cards, actionable messages]
description: Introducing the ActionableMessages PowerShell module - a powerful way to create interactive Adaptive Cards for email
---

# ActionableMessages PowerShell Module

Creating interactive Adaptive Cards for email using Microsoft's Actionable Messages has never been easier.

In my [previous post](https://mynster9361.github.io/posts/ActionableMessages/){:target="_blank"}, we explored the raw JSON approach to creating these cards.

Today, I'm excited to introduce my PowerShell module that simplifies the entire process.

## Installing the Module

```powershell
# Install from PowerShell Gallery
Install-Module -Name ActionableMessages -Scope CurrentUser
```

# Why Use This Module?
- Simplified Syntax: Create complex cards with intuitive PowerShell commands
- Reduced Errors: No more struggling with nested JSON and escaping special characters
- Improved Readability: Clean PowerShell code instead of complex JSON structures
- Reusable Components: Build and save card components for reuse


## Basic Usage
Let's start with a simple example:
OVA result:

![simple example ova](/assets/img/posts/2025-04-01-ActionableMessagesModule-Basic-ova.png)

Mobile result:

![simple example mobile](/assets/img/posts/2025-04-01-ActionableMessagesModule-Basic-mobile.png){: width="300" height="400" }

```powershell
# Import the module
Import-Module ActionableMessages

# Create a new card
$card = New-AMCard -OriginatorId "1234"

# Add a title
$title = New-AMTextBlock -Text "Hello World" -Size "Large" -Weight "Bolder" -Color "Accent"
Add-AMElement -Card $card -Element $title

# Add a button
$action = New-AMOpenUrlAction -Title "Visit our website" -Url "https://example.com"
$actionSet = New-AMActionSet -Actions @($action)
Add-AMElement -Card $card -Element $actionSet

# Export to HTML for email
$graphParams = Export-AMCardForEmail -Card $card -Subject "Test Card" -ToRecipients "John.Doe@contoso.com" -CreateGraphParams -FallbackText "Your email client doesn't support Adaptive Cards"
Write-Host "Graph parameters created successfully."

$params = $graphParams |ConvertTo-Json -Depth 50

# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/John.Doe@contoso.com/sendMail"
Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```

## Advanced Examples
Now let's recreate the examples from my previous post using this module.

#### PTO Request Card

OVA result:

![pto example ova](/assets/img/posts/2025-04-01-ActionableMessagesModule-PTO-ova.png)

Mobile result:

![pto example mobile](/assets/img/posts/2025-04-01-ActionableMessagesModule-PTO-mobile.png){: width="300" height="400" }

```powershell
# Import the module
Import-Module ActionableMessages
# Create a new card
$card = New-AMCard -OriginatorId "1234"

# Add header
$header = New-AMTextBlock -Text "PTO Request from John Doe" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $header

# Create person info container
$personContainer = New-AMContainer -Id "person-container"
Add-AMElement -Card $card -Element $personContainer

# Create columns for person info
$imageColumn = New-AMColumn -Width "auto" -Items @(
    (New-AMImage -Url "https://amdesigner.azurewebsites.net/samples/assets/Miguel_Garcia.png" -Size "Small" -AltText "John Doe")
)

$infoColumn = New-AMColumn -Width "stretch" -Items @(
    (New-AMTextBlock -Text "John Doe" -Weight "Bolder"),
    (New-AMTextBlock -Text "Requested on: $(Get-Date -Format 'yyyy-MM-dd')" -Size "Small" -IsSubtle $true),
    (New-AMTextBlock -Text "Reason: Family visit" -Size "Small" -IsSubtle $true)
)

# Add columns to a column set
$columnSet = New-AMColumnSet -Columns @($imageColumn, $infoColumn) -id "person-columns"
Add-AMElement -Card $card -Element $columnSet -ContainerId "person-container"

# Add date information
$facts = @(
    (New-AMFact -Title "From:" -Value "Until:"),
    (New-AMFact -Title "2023-06-01" -Value "2023-06-10")
)
$factSet = New-AMFactSet -Facts $facts
Add-AMElement -Card $card -Element $factSet

# Add approve/reject actions
$approveAction = New-AMExecuteAction -Title "Approve" -Verb "POST" `
    -Url "https://your-logic-app-url" `
    -Body '{"Action":"Approve","user":"john.doe@contoso.com"}'

$rejectAction = New-AMExecuteAction -Title "Reject" -Verb "POST" `
    -Url "https://your-logic-app-url" `
    -Body '{"Action":"Reject","user":"john.doe@contoso.com"}'

$actionSet = New-AMActionSet -Actions @($approveAction, $rejectAction)
Add-AMElement -Card $card -Element $actionSet

# Or create Microsoft Graph params
$graphParams = Export-AMCardForEmail -Card $card -Subject "PTO Request" `
    -ToRecipients "john.doe@contoso.com" -CreateGraphParams

$params = $graphParams |ConvertTo-Json -Depth 50


# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/john.doe@contoso.com/sendMail"
Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```

#### Access Request with Choice Selection
OVA result:

![access request example ova](/assets/img/posts/2025-04-01-ActionableMessagesModule-AccessRequest-ova.png)

Mobile result:

![access request example mobile](/assets/img/posts/2025-04-01-ActionableMessagesModule-AccessRequest-mobile.png){: width="300" height="400" }

```powershell
# Import the module
Import-Module ActionableMessages
# Create a new card
$card = New-AMCard -OriginatorId "1234"

# Add header
$header = New-AMTextBlock -Text "Access Request from John Doe" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $header

# Create choice set for group selection
$choices = @(
    (New-AMChoice -Title "Group Name 1" -Value "Group1"),
    (New-AMChoice -Title "Group Name 2" -Value "Group2"),
    (New-AMChoice -Title "Group Name 3" -Value "Group3"),
    (New-AMChoice -Title "Group Name 4" -Value "Group4")
)

$choiceSet = New-AMChoiceSetInput -Id "groupSelection" -Choices $choices `
    -Style "expanded" -IsMultiSelect $true -Placeholder "Select groups to approve"
Add-AMElement -Card $card -Element $choiceSet

# Add approve/reject actions
$approveAction = New-AMExecuteAction -Title "Approve Selected" -Verb "POST" `
    -Url "https://your-logic-app-url" `
    -Body '{"Action":"Approve","Approved_groups":"{{groupSelection.value}}","user":"john.doe@contoso.com"}'

$rejectAction = New-AMExecuteAction -Title "Reject All" -Verb "POST" `
    -Url "https://your-logic-app-url" `
    -Body '{"Action":"Reject","Approved_groups":"","user":"john.doe@contoso.com"}'

$actionSet = New-AMActionSet -Actions @($approveAction, $rejectAction)
Add-AMElement -Card $card -Element $actionSet

# Export for email
$emailHtml = Export-AMCardForEmail -Card $card -Subject "Select New Owner" -FallbackText "Please select a new owner"

# Or create Microsoft Graph params
$graphParams = Export-AMCardForEmail -Card $card -Subject "Access Request" `
    -ToRecipients "john.doe@contoso.com" -CreateGraphParams

$params = $graphParams |ConvertTo-Json -Depth 50


# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/john.doe@contoso.com/sendMail"
Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```

#### New Owner Selection Card
OVA result:

![new owner example ova](/assets/img/posts/2025-04-01-ActionableMessagesModule-NewOwner-ova.png)

Mobile result:

![new owner1 example mobile](/assets/img/posts/2025-04-01-ActionableMessagesModule-NewOwner1-mobile.png){: width="300" height="400" }

Mobile result selection:

![new owner2 example mobile](/assets/img/posts/2025-04-01-ActionableMessagesModule-NewOwner2-mobile.png){: width="300" height="400" }

```powershell
# Create a new card with header and info (similar to previous examples)
$card = New-AMCard -OriginatorId "1234"

# Add facts about resources needing new owner
$facts = @(
    (New-AMFact -Title "Group_Name" -Value "Group"),
    (New-AMFact -Title "service_user" -Value "User"),
    (New-AMFact -Title "Server_Name" -Value "Server")
    # More facts as needed
)
$factSet = New-AMFactSet -Facts $facts -Id "facts"
Add-AMElement -Card $card -Element $factSet

# Create choice set for new owner selection
$choices = @(
    (New-AMChoice -Title "Bob Bob" -Value "Bob.Bob@contoso.com"),
    (New-AMChoice -Title "Jane Doe" -Value "Jane.Doe@contoso.com"),
    (New-AMChoice -Title "Shane Doe" -Value "Shane.Doe@contoso.com")
)

$choiceSet = New-AMChoiceSetInput -Id "choice" -Choices $choices `
    -Placeholder "Please choose one of your direct reports as the new owner"
Add-AMElement -Card $card -Element $choiceSet

# Transform objects for the payload
$objects = @(
    @{ Type = "Group"; Name = "Group_Name" },
    @{ Type = "User"; Name = "service_user" },
    @{ Type = "Server"; Name = "Server_Name" }
    # More objects as needed
)
$objectsJson = $objects | ConvertTo-Json -Compress

# Add action
$selectAction = New-AMExecuteAction -Title "Select new owner" -Verb "POST" `
    -Url "https://your-logic-app-url" `
    -Body "{`"Action`":`"Approve`",`"New_Owner`":`"{{choice.value}}`",`"Old_Owner`":`"john.doe@contoso.com`",`"Objects`":$objectsJson}"

$actionSet = New-AMActionSet -Actions @($selectAction)
Add-AMElement -Card $card -Element $actionSet

# Export for email
$emailHtml = Export-AMCardForEmail -Card $card -Subject "Select New Owner" -FallbackText "Please select a new owner"

# Or create Microsoft Graph params
$graphParams = Export-AMCardForEmail -Card $card -Subject "Select New Owner" `
    -ToRecipients "john.doe@contoso.com" -CreateGraphParams

$params = $graphParams |ConvertTo-Json -Depth 50


# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/john.doe@contoso.com/sendMail"
Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```

## Converting Back and Forth
If you already have JSON or want to create it with the [Microsoft Actionable Message Designer](https://amdesigner.azurewebsites.net/){:target="_blank"} and want to convert it to PowerShell commands:
```powershell
# Convert JSON to PowerShell commands
$json = Get-Content -Path "existing-card.json" -Raw
$psCommands = ConvertTo-AMScriptFromJson -Json $json -OutputPath "card-script.ps1"
```

## Benefits Over Raw JSON
1. Simplified Development: No need to manually construct complex JSON
2. IntelliSense Support: Get command completion and parameter help
3. Cleaner Syntax: PowerShell's pipeline and object model leads to cleaner code
4. Reusable Components: Build libraries of card elements
5. Easier Debugging: PowerShell error messages are clearer than JSON parsing errors

## Conclusion
The ActionableMessages module transforms the complex JSON structure in your scripts for creating Adaptive Cards into a simple, intuitive PowerShell experience.

For more information and source code, check out the [GitHub repository.](https://github.com/Mynster9361/ActionableMessages){:target="_blank"}

And also the [documentation.](https://mynster9361.github.io/modules/actionablemessages/){:target="_blank"}

Reference Links

- [Module on PowerShell Gallery](https://www.powershellgallery.com/packages/ActionableMessages/){:target="_blank"}
- [Actionable Message Designer](https://amdesigner.azurewebsites.net/){:target="_blank"}
- [Microsoft Actionable Messages Documentation](https://learn.microsoft.com/en-us/outlook/actionable-messages/get-started){:target="_blank"}
- [Actionable Email Developer Dashboard](https://mynster9361.github.io/modules/actionablemessages/){:target="_blank"}
