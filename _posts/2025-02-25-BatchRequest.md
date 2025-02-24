---
title: Batch Requests in MS GRAPH
author: mynster
date: 2025-02-24 16:00:00 +0100
categories: [Microsoft Graph, Batch Requests]
tags: [powershell, msgraph, speaker]
description: Demonstrating how to use batch requests in MS Graph
---


# Prerequisites
- Token for msgraph
- Permissions on the endpoint you are using

For all the below examples the variable $baseUrl will always be "https://graph.microsoft.com/v1.0"

## Introduction to Batch Requests

Batch requests in Microsoft Graph allow you to combine multiple requests into a single HTTP request. This can be useful for reducing the number of network calls and improving the performance of your application. Each individual request in a batch can be a different type of request (GET, POST, PATCH, DELETE, etc.) and can target different endpoints.

## Creating a Batch Request

To create a batch request, you need to construct a JSON payload that contains an array of individual requests. Each request must have an `id`, a `method`, a `url`, and optionally, a `body` and `headers` and/or `dependsOn`.

Here is an example of a batch request payload:

```json
{
  "requests": [
    {
      "id": "1",
      "method": "GET",
      "url": "/users"
    },
    {
      "id": "2",
      "method": "GET",
      "url": "/groups"
    }
  ]
}
```

## Sending a Batch Request
To send a batch request, you need to make a POST request to the /batch endpoint with the batch request payload. (https://graph.microsoft.com/v1.0/batch)

Here is an example of how to send a batch request using PowerShell:

```powershell
# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}

# Batch request payload
$batchPayload = @{
    requests = @(
        @{
            id = "1"
            method = "GET"
            url = "/users"
        },
        @{
            id = "2"
            method = "GET"
            url = "/groups"
        }
    )
} | ConvertTo-Json -Depth 10

# Graph API BASE URI
$baseUrl = "https://graph.microsoft.com/v1.0"
$uri = "$baseUrl/batch"

# Sending the batch request
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeaders -Body $batchPayload
```

## Handling Batch Responses
The response from a batch request contains an array of individual responses, each with an id that matches the corresponding request. You can use the id to match each response with its request.

Here is an example of how to handle the batch response in PowerShell:
```powershell
# Sending the batch request (as shown above)
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeaders -Body $batchPayload

# Handling the batch response
foreach ($result in $response.responses) {
    switch ($result.id) {
        "1" {
            Write-Host "Response for request 1 (GET /users):"
            $result.body | Format-Table
        }
        "2" {
            Write-Host "Response for request 2 (GET /groups):"
            $result.body | Format-Table
        }
    }
}
```


## Advanced Batch Requests
You can also include more complex requests in a batch, such as POST, PATCH, and DELETE requests, even requests with advanced filters and you can include request-specific headers and bodies.

Here is an example of a more advanced batch request payload:

```json
{
  "requests": [
    {
      "id": "1",
      "method": "GET",
      "url": "/users"
    },
    {
      "id": "2",
      "method": "POST",
      "url": "/groups",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": {
        "displayName": "New Group",
        "mailNickname": "newgroup",
        "mailEnabled": false,
        "securityEnabled": true
      }
    },
    {
      "id": "3",
      "method": "GET",
      "url": "/users?$filter=country eq 'Denmark' and accountEnabled eq true and startswith(jobTitle, 'TECH') and onPremisesSyncEnabled eq true&$select=id,displayName,userPrincipalName&$expand=memberOf&$count=true",
      "headers": {
        "Content-Type": "application/json",
        "ConsistencyLevel": "eventual"
      }
    }
  ]
}
```

## Sequencing your requests 1.2.3
With batch requests, we are also able to make one call dependent on an earlier call by adding the `dependsOn` attribute, as shown below. This enables you to execute a call only if the specified `dependsOn` ID is successfully completed. Otherwise, all subsequent requests that depend on that call will fail with a status code `424`. Additionally, it allows you to control the order of operations, ensuring that your call with, for example, `id = 3` is executed before the call with `id = 2`.

```json
{
  "requests": [
    {
      "id": "1",
      "method": "GET",
      "url": "/users"
    },
    {
      "id": "2",
      "dependsOn": [ "3" ],
      "method": "POST",
      "url": "/groups",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": {
        "displayName": "New Group",
        "mailNickname": "newgroup",
        "mailEnabled": false,
        "securityEnabled": true
      }
    },
        {
      "id": "3",
      "dependsOn": [ "1" ],
      "method": "GET",
      "url": "/users?`$filter=country eq 'Denmark' and accountEnabled eq true and startswith(jobTitle, 'TECH') and onPremisesSyncEnabled eq true&`$select=id,displayName,userPrincipalName&`$expand=memberOf&`$count=true",
      "headers": {
        "Content-Type": "application/json",
        "ConsistencyLevel": "eventual"
      }
    }
  ]
}
```

## Some great usecases for batch requests
Below we will have 3 diffrent use cases just as examples for what you could use batching for.

#### Onboarding - Create a user - Assign license - Assign groups - Create Calendar events - Set Calendar permissions
This one will first create a user with a normal `POST` request like you might be used to and the following `POST` request wil be batched assigning a license, assigning group membership, creating a welcome event in the new users calendar and finally setting some calendar permissions for the user.

```powershell
# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}

# Create the user
$createUserPayload = @{
    accountEnabled = $true
    displayName = "John Doe"
    mailNickname = "johndoe"
    userPrincipalName = "johndoe@example.com"
    passwordProfile = @{
        forceChangePasswordNextSignIn = $true
        password = "P@ssw0rd!"
    }
} | ConvertTo-Json -Depth 10

# Graph API BASE URI
$baseUrl = "https://graph.microsoft.com/v1.0"
$uri = "$baseUrl/users"

# Sending the request to create the user
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeaders -Body $createUserPayload

# Extract the user ID from the response
$userId = $response.id

# Second Batch Request: Assign License, Add to Groups, Create Calendar Events, Set Calendar Permissions
$configureUser = @{
    requests = @(
        @{
            id = "1"
            method = "POST"
            url = "/users/$userId/assignLicense"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                addLicenses = @(
                    @{
                        skuId = "05e9a617-0261-4cee-bb44-138d3ef5d965"  # Microsoft 365 E3
                    }
                )
                removeLicenses = @()
            }
        },
        @{
            id = "2"
            dependsOn = "1"
            method = "POST"
            url = "/groups/{group-id}/members/`$ref"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId"
            }
        },
        @{
            id = "3"
            dependsOn = "2"
            method = "POST"
            url = "/users/$userId/events"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                subject = "Welcome Meeting"
                body = @{
                    contentType = "HTML"
                    content = "Welcome to the company!"
                }
                start = @{
                    dateTime = "2025-02-26T09:00:00"
                    timeZone = "Pacific Standard Time"
                }
                end = @{
                    dateTime = "2025-02-26T10:00:00"
                    timeZone = "Pacific Standard Time"
                }
                attendees = @(
                    @{
                        emailAddress = @{
                            address = "johndoe@example.com"
                            name = "John Doe"
                        }
                        type = "required"
                    }
                )
            }
        },
        @{
            id = "4"
            dependsOn = "3"
            method = "POST"
            url = "/users/$userId/calendar/calendarPermissions"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
              isRemovable = $true
              isInsideOrganization = $true
                role = "limitedRead"
                emailAddress = @{
                    address = "johndoe@example.com"
                    name = "John Doe"
                }
            }
        }
    )
} | ConvertTo-Json -Depth 10

# Sending the second batch request
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeaders -Body $configureUser
```

#### Add 1 user to multiple groups in 1 go
Currently with msgraph we are able to add multiple users to a single group but unfortunately we can not add 1 user to multiple groups at once. One way to handle this limitation is to do it with batch requests like shown here:

```powershell
# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}

# Batch request payload to add one user to multiple groups
$batchPayload = @{
    requests = @(
        @{
            id = "1"
            method = "POST"
            url = "/groups/{group-id-1}/members/`$ref"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/users/{user-id}"
            }
        },
        @{
            id = "2"
            method = "POST"
            url = "/groups/{group-id-2}/members/`$ref"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/users/{user-id}"
            }
        },
        @{
            id = "3"
            method = "POST"
            url = "/groups/{group-id-3}/members/`$ref"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/users/{user-id}"
            }
        }
    )
} | ConvertTo-Json -Depth 10

# Graph API BASE URI
$baseUrl = "https://graph.microsoft.com/v1.0"
$uri = "$baseUrl/batch"

# Sending the batch request
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeaders -Body $batchPayload

# Display the response
$response
```


#### Bulk update users
Right the last usecase i have listed here would be to bulk update users so updating one or more attributes on users at once.

```powershell
# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}

# Batch request payload to bulk update users
$batchPayload = @{
    requests = @(
        @{
            id = "1"
            method = "PATCH"
            url = "/users/{user-id-1}"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                jobTitle = "Senior Developer"
                department = "Engineering"
            }
        },
        @{
            id = "2"
            method = "PATCH"
            url = "/users/{user-id-2}"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                jobTitle = "Project Manager"
                department = "Project Management"
            }
        },
        @{
            id = "3"
            method = "PATCH"
            url = "/users/{user-id-3}"
            headers = @{
                "Content-Type" = "application/json"
            }
            body = @{
                jobTitle = "HR Specialist"
                department = "Human Resources"
            }
        }
    )
} | ConvertTo-Json -Depth 10

# Graph API BASE URI
$baseUrl = "https://graph.microsoft.com/v1.0"
$uri = "$baseUrl/batch"

# Sending the batch request
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeaders -Body $batchPayload

# Display the response
$response
```

## Conclusion
Batch requests in Microsoft Graph are a powerful way to optimize your application by reducing the number of network calls. By combining multiple requests into a single batch request, you can improve performance and simplify your code.

Reference/Documentation links
- Batch Requests: [https://learn.microsoft.com/en-us/graph/json-batching](https://learn.microsoft.com/en-us/graph/json-batching){:target="_blank"}

