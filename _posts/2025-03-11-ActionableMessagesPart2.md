---
title: Adaptive Cards to Email through MS Graph (Actionable messages) Part 2
author: mynster
date: 2025-03-10 21:45:00 +0100
categories: [Microsoft Graph, Mail]
tags: [powershell, msgraph, mail, adaptive cards]
description: Demonstrating how to send an approval adaptive card (Actionable messages) through MS Graph
---
# Prerequisites

- App registration/service principal with correct permissions
- Token for MS Graph
- Permissions on the endpoint you are using
- Read the previous article [https://mynster9361.github.io/posts/ActionableMessages/](https://mynster9361.github.io/posts/ActionableMessages/){:target="_blank"}


## Use Cases / Examples

This blog post will not go to much into the nitty gritty of how it works but will cover some use cases that you might see or have or you can use it to develop your own use cases / adaptive cards your imagination and ideas are the only things setting the limit for you (Aswell as what is possible with adaptive cards of course :) )

### 1. PTO request

![PTO Request](/assets/img/posts/2025-03-11-ActionableMessagesPart2PTO.png)

#### JSON
```json
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "FactSet",
            "facts": [
                {
                    "title": "From:",
                    "value": "Untill:"
                },
                {
                    "title": "$fromDate",
                    "value": "$toDate"
                }
            ]
        },
                {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Approve",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"user\":\"$($userUPN)\"}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                },
                {
                    "type": "Action.Http",
                    "title": "Reject",
                    "id": "reject",
                    "method": "POST",
                    "body": "{\"Action\":\"Reject\",\"user\":\"$($userUPN)\"}",
                    "url": "$httpURL",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
```

#### Powershell script:
```powershell

# Originator id
$originatorId = "Your originator id"

# Your url for the logic app saved from earlier the same one used for the `HTTP URL`
$httpURL = "Your logic app url"

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = "Your-tenant-id"
$clientId = "Your-client-id"
$clientSecret = "Your-Secret"

# Example values for other variables
$userName = "John Doe"
$userUPN = "John.Doe@contoso.com"
$header = "PTO request from $userName"
$userImage = "https://pbs.twimg.com/profile_images/3647943215/d7f12830b3c17a5a9e4afcc370e3a37e_400x400.jpeg"
$reason = "I need to visit family"
$date = get-date -format "yyyy-MM-dd, HH:mm"
$fromDate = get-date -format "yyyy-MM-dd" -date "2026-01-01"
$toDate = get-date -format "yyyy-MM-dd" -date "2026-01-10"

$params = @{
    message         = @{
        subject      = "$header"
        body         = @{
            contentType = "HTML"
            content     = @"
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <script type="application/adaptivecard+json">
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "FactSet",
            "facts": [
                {
                    "title": "From:",
                    "value": "Untill:"
                },
                {
                    "title": "$fromDate",
                    "value": "$toDate"
                }
            ]
        },
                {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Approve",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"user\":\"$($userUPN)\"}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                },
                {
                    "type": "Action.Http",
                    "title": "Reject",
                    "id": "reject",
                    "method": "POST",
                    "body": "{\"Action\":\"Reject\",\"user\":\"$($userUPN)\"}",
                    "url": "$httpURL",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
        </script>
        </head>
        <p>Please find a new owner for the group and fill it in below and press submit. Thank you ín advance! </p>
        </html>
"@
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "Jane.Doe@contoso.com"
                }
            }
        )
    }
    saveToSentItems = "false"
} | ConvertTo-Json -Depth 10



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
    "Content-type" = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/{user-id or UPN to send the mail from}/sendMail"
$request = Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params

```

### 2. Access request

![Access Request](/assets/img/posts/2025-03-11-ActionableMessagesPart2AccessRequest.png)

#### JSON
```json
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "Input.ChoiceSet",
            "choices": $($choiceSet | convertto-json),
            "placeholder": "Placeholder text",
            "style": "expanded",
            "spacing": "Small",
            "isMultiSelect": true,
            "id": "groupSelection"
        },
        {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Approve selected",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"Approved_groups\":\"{{groupSelection.value}}\",\"user\":\"$($userUPN)\"}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                },
                {
                    "type": "Action.Http",
                    "title": "Reject All",
                    "id": "reject",
                    "method": "POST",
                    "body": "{\"Action\":\"Reject\",\"Approved_groups\":\"{{groupSelection.value}}\",\"user\":\"$($userUPN)\"}",
                    "url": "$httpURL",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
```

#### Powershell script:
```powershell
# Originator id
$originatorId = "Your originator id"

# Your url for the logic app saved from earlier the same one used for the `HTTP URL`
$httpURL = "Your logic app url"

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = "Your-tenant-id"
$clientId = "Your-client-id"
$clientSecret = "Your-Secret"

# Example values for other variables
$userName = "John Doe"
$userUPN = "John.Doe@contoso.com"
$header = "Access request from $userName"
$userImage = "https://pbs.twimg.com/profile_images/3647943215/d7f12830b3c17a5a9e4afcc370e3a37e_400x400.jpeg"
$reason = "I am new in the company and need more permissions"
$date = get-date -format "yyyy-MM-dd, HH:mm"


$choiceSet = @(
    @{
        title = "Group Name 1"
        value = "Group1"
    },
    @{
        title = "Group Name 2"
        value = "Group2"
    },
    @{
        title = "Group Name 3"
        value = "Group3"
    },
    @{
        title = "Group Name 4"
        value = "Group4"
    }
)

$params = @{
    message         = @{
        subject      = "$header"
        body         = @{
            contentType = "HTML"
            content     = @"
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <script type="application/adaptivecard+json">
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "Input.ChoiceSet",
            "choices": $($choiceSet | convertto-json),
            "placeholder": "Placeholder text",
            "style": "expanded",
            "spacing": "Small",
            "isMultiSelect": true,
            "id": "groupSelection"
        },
        {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Approve selected",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"Approved_groups\":\"{{groupSelection.value}}\",\"user\":\"$($userUPN)\"}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                },
                {
                    "type": "Action.Http",
                    "title": "Reject All",
                    "id": "reject",
                    "method": "POST",
                    "body": "{\"Action\":\"Reject\",\"Approved_groups\":\"{{groupSelection.value}}\",\"user\":\"$($userUPN)\"}",
                    "url": "$httpURL",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
        </script>
        </head>
        <p>Please find a new owner for the group and fill it in below and press submit. Thank you ín advance! </p>
        </html>
"@
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "Jane.Doe@contoso.com"
                }
            }
        )

    }
    saveToSentItems = "false"
} | ConvertTo-Json -Depth 10

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
    "Content-type" = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/{user-id or UPN to send the mail from}/sendMail"
$request = Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```

And our body will look like this in our logic app returning only the groups selected which we can continue to work off

```json
{
  "Action":"Approve",
  "Approved_groups":"Group2,Group4",
  "user":"John.Doe@contoso.com"
}
```

### 3. Who should be the new owner/approver?

![New Owner](/assets/img/posts/2025-03-11-ActionableMessagesPart2NewOwner.png)

![New Owner2](/assets/img/posts/2025-03-11-ActionableMessagesPart2NewOwner2.png)
#### JSON
```json
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "FactSet",
            "facts": $($factSet | convertto-json),
            "id": "facts"
        },
        {
            "type": "Input.ChoiceSet",
            "choices": $($choiceSet | convertto-json),
            "placeholder": "Please choose one of your direct reports as the new owner",
            "id": "choice"
        },
        {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Sellect new owner",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"New_Owner\":\"{{choice.value}}\",\"Old_Owner\":\"$($userUPN)\",\"Objects\":$($objectsJoinedEscaped)}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
```

#### Powershell script:
```powershell
# Originator id
$originatorId = "Your originator id"

# Your url for the logic app saved from earlier the same one used for the `HTTP URL`
$httpURL = "Your logic app url"

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = "Your-tenant-id"
$clientId = "Your-client-id"
$clientSecret = "Your-Secret"

# Example values for other variables
$userName = "John Doe"
$userUPN = "John.Doe@contoso.com"
$header = "We need a new owner to replace $userName"
$userImage = "https://pbs.twimg.com/profile_images/3647943215/d7f12830b3c17a5a9e4afcc370e3a37e_400x400.jpeg"
$reason = "We can see the employee is set to leave the company on $date and request that you as the manager choose a new person to be responsible for the things the previous employee was set as owner of."
$date = get-date -format "yyyy-MM-dd, HH:mm"


$choiceSet = @(
    @{
        title = "Bob Bob"
        value = "Bob.Bob@contoso.com"
    },
    @{
        title = "Jane Doe"
        value = "Jane.Doe@contoso.com"
    },
    @{
        title = "John Doe"
        value = "John.Doe@contoso.com"
    },
    @{
        title = "Shane Doe"
        value = "Shane.Doe@contoso.com"
    }
)

$factSet = @(
    @{
        title = "Group_Name"
        value = "Group"
    },
    @{
        title = "service_user"
        value = "User"
    },
    @{
        title = "Server_Name"
        value = "Server"
    },
    @{
        title = "Server_Name1"
        value = "Server"
    },
    @{
        title = "Server_Name2"
        value = "Server"
    },
    @{
        title = "Server_Name3"
        value = "Server"
    }
)

# Transform the factSet to create a new array with Type and Name properties
$transformedFactSet = $factSet | ForEach-Object {
    [PSCustomObject]@{
        Type = $_.value
        Name = $_.title
    }
}

# Convert the transformed array to a JSON string needs to be oneline which is why we use -Compress
$objectsJoined = $transformedFactSet | ConvertTo-Json -Compress

# Manually escape the quotes in the JSON string needed for adaptive cards
$objectsJoinedEscaped = $objectsJoined -replace '"', '\"'


$params = @{
    message         = @{
        subject      = "$header"
        body         = @{
            contentType = "HTML"
            content     = @"
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <script type="application/adaptivecard+json">
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "FactSet",
            "facts": $($factSet | convertto-json),
            "id": "facts"
        },
        {
            "type": "Input.ChoiceSet",
            "choices": $($choiceSet | convertto-json),
            "placeholder": "Please choose one of your direct reports as the new owner",
            "id": "choice"
        },
        {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Sellect new owner",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"New_Owner\":\"{{choice.value}}\",\"Old_Owner\":\"$($userUPN)\",\"Objects\":$($objectsJoinedEscaped)}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
        </script>
        </head>
        <p>Please find a new owner for the group and fill it in below and press submit. Thank you ín advance! </p>
        </html>
"@
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "Jane.Doe@contoso.com"
                }
            }
        )

    }
    saveToSentItems = "false"
} | ConvertTo-Json -Depth 10

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
    "Content-type" = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/{user-id or UPN to send the mail from}/sendMail"
$request = Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```

And your body in the logic app will look a bit like this
```json
{
  "Action": "Approve",
  "New_Owner": "Jane.Doe@contoso.com",
  "Old_Owner": "John.Doe@contoso.com",
  "Objects":
    [
      { "Type": "Group", "Name": "Group_Name" },
      { "Type": "User", "Name": "service_user" },
      { "Type": "Server", "Name": "Server_Name" },
      { "Type": "Server", "Name": "Server_Name1" },
      { "Type": "Server", "Name": "Server_Name2" },
      { "Type": "Server", "Name": "Server_Name3" },
    ],
}

```


## Conclusion

Combine these use cases together with my last blog post:
[https://mynster9361.github.io/posts/ActionableMessages/](https://mynster9361.github.io/posts/ActionableMessages/){:target="_blank"}

And you will be well on your way to improve some automation process that you launch to the end users in order to gather infomation and take action on the information gathered straight away instead of going through the collection process your self.


## Reference/Documentation links

- Actionable Message Designer [https://amdesigner.azurewebsites.net/](https://amdesigner.azurewebsites.net/){:target="_blank"}
- Actionable messages in outlook [https://learn.microsoft.com/en-us/outlook/actionable-messages/](https://learn.microsoft.com/en-us/outlook/actionable-messages/){:target="_blank"}
- Actionable Email Developer Dashboard [https://outlook.office.com/connectors/oam/publish](https://outlook.office.com/connectors/oam/publish){:target="_blank"} *Note you might have to have outlook on the web open first*
- Admin dashboard for the Actionable Email Developer Dashboard [https://outlook.office.com/connectors/oam/admin](https://outlook.office.com/connectors/oam/admin){:target="_blank"}
- Microsoft Graph API: [https://learn.microsoft.com/en-us/graph/api/overview](https://learn.microsoft.com/en-us/graph/api/overview){:target="_blank"}
