---
title: Advanced Filtering in MS GRAPH
author: mynster
date: 2025-02-17 21:30:00 +0100
categories: [Microsoft Graph, Filtering]
tags: [powershell, msgraph, speaker]
description: Demonstrating how to use advanced filters in MS Graph
---

# Prerequisites
- Token for msgraph
- Permissions on the endpoint you are using
- If you have not already seen the post and have trouble with filtering look at my previous post [https://mynster9361.github.io/posts/Filtering/](https://mynster9361.github.io/posts/Filtering/){:target="_blank"}

For all the below examples the variable $baseUrl will always be "https://graph.microsoft.com/v1.0"

Further than that for all advanced queries you will need to include the following in your headers
ConsistencyLevel = eventual
And also end your query with $count=true except for when using search


### Nice to know

#### What is ConsistencyLevel = eventual

Right to give a very simpel explanation of the combination of the ConsistencyLevel = eventual and the $count in your queries is that Microsoft host loads of data across multiple countrys, regions, continents for that matter now all of the servers spread out arround the world will need to have the data between them replicated which will include some latency from one location to the next.

So lets say you are a global company you have locations both in Europe, America, Asia and so on. If somebody changes some data in Europe at 07:00:00 and you request data from the same source that the person just changed something lets say you request it at 07:00:03 then you might not get the latest version of the data if you are not using ConsistencyLevel = eventual as the ConsistencyLevel header makes sure that the data is accurate and up to date.


### What can i filter on?

To find out what you can filter on you can go to the root section of the given object you would like to look at for an easy example lets look at the /Users endpoint.

All the properties we have available is listed in the root section so for Users see the below link:
[https://learn.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0#properties](https://learn.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0#properties){:target="_blank"}

As shown in the table we have quite a lot of properties that we are able to filter on.
And each property has its own supported filtering option so if we try and look on a simple property like "country" in most cases you would imagine since it is a simple string that we would be able to use $orderby on that property but if we try it we get the following response:
`        "message": "An unsupported property was specified.",`

And if we look in the properties section under country we can see that it only supports the following:
"Returned only on $select. Supports $filter (eq, ne, not, ge, le, in, startsWith, and eq on null values)."

So what we can get out of that small piece of information is that this property can be filtered but it can only be filtered with the operations (eq, ne, not, ge, le, in, startsWith, and eq on null values) `For more information about filtering please see my last blog post linked in the prerequisites section`


Right so now that we know which properties we can get but also what kind of operator we can use on each property we are ready to make an example of an advanced filter query.

### Example code with advanced filter

Right for our advanced filter lets setup some criteria first in order to know what we actually want to do.

- Lets say we want all users that has the value "Denmark" in the property country.
- We are only looking for active users
- Their job title has to start with TECH
- And we are only looking at users that comes from our onprem environment
- And we only need the properties: id, displayname, userprincipalname, and the groups they are a member of

Right just to split it up a bit we will take the query bit by bit.
1. $filter=country eq 'Denmark'
2. $filter=accountEnabled eq true
3. $filter=startswith(jobTitle, 'TECH')
4. $filter=onPremisesSyncEnabled eq true
5. $select=id,displayname,userprincipalname
6. $expand=memberOf

Now that we have our filtration laid out we will need to put them together so we can get our final list of users we actually want to work with

So our complete URL would look something like this:
`https://graph.microsoft.com/v1.0/users?$filter=country eq 'Denmark' and accountEnabled eq true and startswith(jobTitle, 'TECH') and onPremisesSyncEnabled eq true&$select=id,displayName,userPrincipalName&$expand=memberOf&$count=true`

```powershell
# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
    "ConsistencyLevel" = "eventual" # This header is needed when using advanced filters in Microsoft Graph
}
# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users?`$filter=country eq 'Denmark' and accountEnabled eq true and startswith(jobTitle, 'TECH') and onPremisesSyncEnabled eq true&`$select=id,displayName,userPrincipalName&`$expand=memberOf&`$count=true"
$request = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And your result would look something like this:

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(id,displayName,userPrincipalName,memberOf())",
    "value": [
        {
            "id": "132",
            "displayName": "user number 1",
            "userPrincipalName": "usernumber1@example.com",
            "memberOf": [
                {
                    "@odata.type": "#microsoft.graph.group",
                    "id": "4321",
                    "deletedDateTime": null,
                    "classification": null,
                    "createdDateTime": null,
                    "creationOptions": [],
                    "description": "Group that contains all",
                    "displayName": "1",
                    "expirationDateTime": null,
                    "groupTypes": [],
                    "isAssignableToRole": null,
                    "mail": "1@example.com",
                    "mailEnabled": true,
                    "mailNickname": "1",
                    "membershipRule": null,
                    "membershipRuleProcessingState": null,
                    "onPremisesDomainName": "example.net",
                    "onPremisesLastSyncDateTime": "2025-02-14T05:16:13Z",
                    "onPremisesNetBiosName": "EXAMPLE",
                    "onPremisesSamAccountName": "1",
                    "onPremisesSecurityIdentifier": "1234",
                    "onPremisesSyncEnabled": true,
                    "preferredDataLocation": null,
                    "preferredLanguage": null,
                    "proxyAddresses": [
                        "smtp:1@example.onmicrosoft.com",
                        "smtp:2@example.mail.onmicrosoft.com",
                        "SMTP:3@example.com"
                    ],
                    "renewedDateTime": null,
                    "resourceBehaviorOptions": [],
                    "resourceProvisioningOptions": [],
                    "securityEnabled": true,
                    "securityIdentifier": "4321",
                    "theme": null,
                    "uniqueName": null,
                    "visibility": null,
                    "onPremisesProvisioningErrors": [],
                    "serviceProvisioningErrors": []
                },
                {
                    "@odata.type": "#microsoft.graph.group",
                    "id": "",
                    "deletedDateTime": null,
                    "classification": null,
                    "createdDateTime": "2019-12-12T11:18:53Z",
                    "creationOptions": [],
                    "description": null,
                    "displayName": "Access-For-Something",
                    "expirationDateTime": null,
                    "groupTypes": [],
                    "isAssignableToRole": null,
                    "mail": null,
                    "mailEnabled": false,
                    "mailNickname": "1234",
                    "membershipRule": null,
                    "membershipRuleProcessingState": null,
                    "onPremisesDomainName": null,
                    "onPremisesLastSyncDateTime": null,
                    "onPremisesNetBiosName": null,
                    "onPremisesSamAccountName": null,
                    "onPremisesSecurityIdentifier": null,
                    "onPremisesSyncEnabled": null,
                    "preferredDataLocation": null,
                    "preferredLanguage": null,
                    "proxyAddresses": [],
                    "renewedDateTime": "2019-12-12T11:18:53Z",
                    "resourceBehaviorOptions": [],
                    "resourceProvisioningOptions": [],
                    "securityEnabled": true,
                    "securityIdentifier": "1234",
                    "theme": null,
                    "uniqueName": null,
                    "visibility": null,
                    "onPremisesProvisioningErrors": [],
                    "serviceProvisioningErrors": []
                }
            ]
        }
    ]
}

```



Right now that we have tried that lets try and filter on a collection instead.
Lets try with the same thing except for this one we will not be using $expand=memberOf since we cannot use the expand together with a any operation.
So our criteria will look like this:
- All users that has the value "Denmark" in the property country.
- We are only looking for active users
- Their job title has to start with TECH
- And we are only looking at users that comes from our onprem environment
- And the user needs to have a license let's say it needs to be `Microsoft 365 E3` (in order to filter on a specific license we need to do it on the SKU ID you can look at the below link for reference to the SKUID so in our instance the SKU ID would be: `05e9a617-0261-4cee-bb44-138d3ef5d965`)
[https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference](https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference){:target="_blank"}
- And we only need the properties: id, displayname, userprincipalname, assignedLicenses


Right just to split it up a bit we will take the query bit by bit.
1. $filter=country eq 'Denmark'
2. $filter=accountEnabled eq true
3. $filter=startswith(jobTitle, 'TECH')
4. $filter=onPremisesSyncEnabled eq true
5. $filter=assignedLicenses/any(u:u/skuid eq 05e9a617-0261-4cee-bb44-138d3ef5d965)
6. $select=id,displayName,userPrincipalName,assignedLicenses

```powershell
# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
    "ConsistencyLevel" = "eventual" # This header is needed when using advanced filters in Microsoft Graph
}
# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users?`$filter=country eq 'Denmark' and accountEnabled eq true and startswith(jobTitle, 'TECH') and onPremisesSyncEnabled eq true and assignedLicenses/any(u:u/skuid eq 05e9a617-0261-4cee-bb44-138d3ef5d965)&`$select=id,displayName,userPrincipalName,assignedLicenses&`$count=true"
$request = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And your result would look something like this:

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(id,displayName,userPrincipalName)",
    "@odata.count": 9,
    "value": [
        {
            "id": "3a2f1b4c-8d5e-4f6b-9e2d-1a2b3c4d5e6f",
            "displayName": "User One",
            "userPrincipalName": "user.one@example.com",
            "assignedLicenses": [
                {
                    "disabledPlans": [],
                    "skuId": "3dd6cf57-d688-4eed-ba52-9e40b5468c3e"
                },
                {
                    "disabledPlans": [],
                    "skuId": "639dec6b-bb19-468b-871c-c5c441c4b0cb"
                },
                {
                    "disabledPlans": [],
                    "skuId": "05e9a617-0261-4cee-bb44-138d3ef5d965"
                },
                {
                    "disabledPlans": [],
                    "skuId": "f30db892-07e9-47e9-837c-80727f46fd3d"
                }
            ]
        },
        {
            "id": "4b3c2d5e-7f8a-4b6c-9d1e-2a3b4c5d6e7f",
            "displayName": "User Two",
            "userPrincipalName": "user.two@example.com",
            "assignedLicenses": [
                {
                    "disabledPlans": [],
                    "skuId": "3dd6cf57-d688-4eed-ba52-9e40b5468c3e"
                },
                {
                    "disabledPlans": [],
                    "skuId": "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235"
                },
                {
                    "disabledPlans": [],
                    "skuId": "e43b5b99-8dfb-405f-9987-dc307f34bcbd"
                },
                {
                    "disabledPlans": [
                        "0feaeb32-d00e-4d66-bd5a-43b5b83db82c"
                    ],
                    "skuId": "05e9a617-0261-4cee-bb44-138d3ef5d965"
                },
                {
                    "disabledPlans": [],
                    "skuId": "f30db892-07e9-47e9-837c-80727f46fd3d"
                }
            ]
        },
        {
            "id": "5c4d3e6f-9a8b-4c7d-1e2f-3a4b5c6d7e8f",
            "displayName": "User Three",
            "userPrincipalName": "user.three@example.com",
            "assignedLicenses": [
                {
                    "disabledPlans": [],
                    "skuId": "3dd6cf57-d688-4eed-ba52-9e40b5468c3e"
                },
                {
                    "disabledPlans": [],
                    "skuId": "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235"
                },
                {
                    "disabledPlans": [],
                    "skuId": "f30db892-07e9-47e9-837c-80727f46fd3d"
                },
                {
                    "disabledPlans": [
                        "0feaeb32-d00e-4d66-bd5a-43b5b83db82c"
                    ],
                    "skuId": "05e9a617-0261-4cee-bb44-138d3ef5d965"
                }
            ]
        },
        {
            "id": "6d5e4f7g-0h1i-2j3k-4l5m-6n7o8p9q0r1s",
            "displayName": "User Four",
            "userPrincipalName": "user.four@example.com",
            "assignedLicenses": [
                {
                    "disabledPlans": [],
                    "skuId": "3dd6cf57-d688-4eed-ba52-9e40b5468c3e"
                },
                {
                    "disabledPlans": [
                        "0feaeb32-d00e-4d66-bd5a-43b5b83db82c"
                    ],
                    "skuId": "05e9a617-0261-4cee-bb44-138d3ef5d965"
                }
            ]
        }
    ]
}
```

As you can see in this query it does not matter how many licenses a given user has with the `any` property it will query over each one and return true if just one of the values is true.
If you needed the ones where they only had one licenses you could use the `all` instead of `any` as that evaluates on all properties and only returns true if all of them is true


## Reference/Documentation links

- Filtering: [https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http](https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http){:target="_blank"}
- Advanced Filtering: [https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http](https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http){:target="_blank"}
