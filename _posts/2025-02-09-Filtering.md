---
title: Filtering / Advanced Filtering in MS GRAPH
author: 1
date: 2025-02-09 21:45:00 +0100
categories: [Microsoft Graph, Filtering]
tags: [powershell, msgraph, speaker]
description: Demonstrating how to use $filter and advanced filters
---

# Prerequisites
- Token for msgraph
- Permissions on the endpoint you are using

## Understanding the options for filtering

- Reference: <br>
[https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#operators-and-functions-supported-in-filter-expressions](https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#operators-and-functions-supported-in-filter-expressions){:target="_blank"}

<table aria-label="Table 1" class="table-wrapper">
  <thead>
    <tr>
      <th>Operator type</th>
      <th>Operator</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Equality operators</td>
      <td>
        <ul>
          <li>Equals (eq)</li>
          <li>Not equals (ne)</li>
          <li>Logical negation (not)</li>
          <li>In (in)</li>
          <li>Has (has)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Relational operators</td>
      <td>
        <ul>
          <li>Less than (lt)</li>
          <li>Greater than (gt)</li>
          <li>Less than or equal to (le)</li>
          <li>Greater than or equal to (ge)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Lambda operators</td>
      <td>
        <ul>
          <li>Any (any)</li>
          <li>All (all)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Conditional operators</td>
      <td>
        <ul>
          <li>And (and)</li>
          <li>Or (or)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Functions</td>
      <td>
        <ul>
          <li>Starts with (startswith)</li>
          <li>Ends with (endswith)</li>
          <li>Contains (contains)</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>


Right as shown in the table we have quite a few operators available for us and just to give an example of each endpoint that could be hit you can use the below to have a look with an explanation for each one:

For all the below examples the variable $baseUrl will always be "https://graph.microsoft.com/v1.0"

### Equality operators

#### Equals (eq)

The Equals operator or "eq" will always evaluate to a boolean value so True/False in the below example we are hitting the /users endpoint and have set our $filter to look at the property accountEnabled and asks it to only return the users where the accountEnabled property is equals to true.

```powershell
$uri = $baseUrl/users?`$filter=accountEnabled eq true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

Now just because the equals operator will always evaluate to a boolean value does not mean that we can not use text for our filter the result of your query just needs to evaluate to a boolean value of True/False so in the below example:
We are looking at the same endpoint /Users but this time we are looking at the property "country" and evaluating to the value "Denmark" and that will return all users where that criteria is equals to True
```powershell
$uri = $baseUrl/users?`$filter=country eq 'Denmark'
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And just to provide an example of how it would look in normal powershell if you were working with something like services.
In the below example we are getting all services and then we are filtering the result by saying that we only want the services where the property "Name" is equal to "gpsvc"
```powershell
$services = Get-Service
$services | where-object {$_.Name -eq "gpsvc"}
```

#### Not equals (ne)

The NOT Equals operator or "ne" will always evaluate to a boolean value so True/False in the below example we are hitting the /users endpoint and have set our $filter to look at the property accountEnabled and asks it to only return the users where the accountEnabled property is NOT equals to true.


```powershell
$uri = $baseUrl/users?`$filter=accountEnabled ne true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

Now just because the not equals operator will always evaluate to a boolean value does not mean that we can not use text for our filter the result of your query just needs to evaluate to a boolean value of True/False so in the below example:
We are looking at the same endpoint /Users but this time we are looking at the property "country" and evaluating to the values that is not "Denmark" and that will return all users where that criteria is equals to True
```powershell
$uri = $baseUrl/users?`$filter=country ne 'Denmark'
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And just to provide an example of how it would look in normal powershell if you were working with something like services.
In the below example we are getting all services and then we are filtering the result by saying that we only want the services where the property "Name" is not equal to "gpsvc"
```powershell
$services = Get-Service
$services | where-object {$_.Name -ne "gpsvc"}
```

#### Logical negation (not)

Now for logical negation (not) in most cases you would use this with a combination of the other filters like startswith(), endswith() or even $count.

To provide an example of a use case for the NOT operator we could take a look at the below sample:
For this we are looking at the "users" endpoint and we are looking at the property "assignedLicenses" we are also using the any operator and the reason for this is that the property "assignedLicenses" is a object that can contain multiple entries the any operator basicly runs a foreach loop on the property.

So what we are actualy doing is we are requesting a list of all users, we are going through their licenses with a foreach and we are only returning the users that do not have a license with the skuID that is equal to "05e9a617-0261-4cee-bb44-138d3ef5d965" aka "SPE_E3" license

```powershell
# Your headers for this query will need to contain the header below and also contain the count = true in your query
# ConsistencyLevel = eventual
# More information about this header and count in future blog post on advanced filtering
$uri = $baseUrl/users?`$filter=NOT assignedLicenses/any(x:x/skuId eq 05e9a617-0261-4cee-bb44-138d3ef5d965)&`$count=true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To provide an example that is more like powershell we can take a look at the below sample using services:
First we are requesting the data. (/Users endpoint)
Then we are building our new ArrayList. (This is something we have to do in powershell this is handled automatically from Graph)
Then we are going over each service in services. (The any operator)
And if the Name of the Service is not equal to "gpsvc" then we are adding it to our ArrayList (The combination of the NOT and the property assinedLicenses)

```powershell
$services = Get-Service
$notServices = [System.Collections.ArrayList]@()
foreach ($service in $services) {
    if ($service.Name -ne "gpsvc") {
        $notServices.Add($service)
    }
}
```

- Now as a side note for this particular one we could also just not included the "NOT" operator and just changed our "eq" to "ne" but on some endpoints the "ne" is not supported which is where the "NOT" operator could come in handy


#### In (in)

For the "in" Equality operator it checks for pottential values that are in a property to show an example of this we could do something like shown below:
For this query we are filtering on the property "country" and we are only looking for the users that are either in Denmark, India, Germany or Sweden This will return a list of the users where their country is one of the supplied values

```powershell
$uri = $baseUrl/users?`$filter=country in ('Denmark', 'India', 'Germany', 'Sweden')
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To give an example of how the above query could look in a method you are properly more used too with get-service.
We are first defining the service names we want to look for, then we get all the services before we finaly filter our services to only show the ones we want.

```powershell
# Define the names you want to filter
$serviceNames = @('AppVClient', 'gpsvc', 'edgeupdate')
# Get all services
$services = Get-Service
# Filter services based on their names
$filteredServices = $services | Where-Object { $serviceNames -contains $_.Name }
# Display the filtered services
$filteredServices | Select-Object Name, Status
```

#### Has (has)

To be honest with you i have not been able to find an actual use case for Has further than that i have not been able to find any example except for the 1 example that Microsoft has in their own documentation and also i have not been able to find any documentationon exactly what the has operator actually does so i will not add anything for this part as of now at least.

### Relational operators

These relational operators will in most cases only be needed/used when you either need to evaluate a date or if you need to sort on a count property other than that i am not sure i personally see a usecase.

#### Less than (lt)

Please note that using the Relational operators will in almost all cases cause your query to become advanced filters where you in most cases will need to add the header
ConsistencyLevel:eventual and also include the $count=true property in your query format has to be 'yyyy-mm-ddThh:mm:ss('.'s+)?(zzzzzz)?' An easy way for you to do this would be something like this:

```powershell
$((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))
```

And some example code:
```powershell
$uri = $baseUrl/groups/?`$filter=createdDateTime lt 2025-02-02T08:14:23Z&`$count=true
# the anove time filter could also look like this:
$uri = $baseUrl/groups/?`$filter=createdDateTime lt $((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And to provide something similar in powershell that does not look at an api

```powershell
# Get the current date and time
$currentDateTime = Get-Date
# Define a date and time to compare against (e.g., processes started before 7 days ago)
$comparisonDateTime = $currentDateTime.AddDays(-7)
# Get all processes
$allProcesses = Get-Process
# Filter processes that were started before the comparison date and time
$filteredProcesses = $allProcesses | Where-Object { $_.StartTime -lt $comparisonDateTime }
# Display the filtered processes
$filteredProcesses | Select-Object Name, StartTime
```

#### Greater than (gt)

Please note that using the Relational operators will in almost all cases cause your query to become advanced filters where you in most cases will need to add the header
ConsistencyLevel:eventual and also include the $count=true property in your query format has to be 'yyyy-mm-ddThh:mm:ss('.'s+)?(zzzzzz)?' An easy way for you to do this would be something like this:

```powershell
$((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))
```

And some example code:
```powershell
$uri = $baseUrl/groups/?`$filter=createdDateTime gt 2025-02-02T08:14:23Z&`$count=true
# the anove time filter could also look like this:
$uri = $baseUrl/groups/?`$filter=createdDateTime gt $((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And to provide something similar in powershell that does not look at an api

```powershell
# Get the current date and time
$currentDateTime = Get-Date
# Define a date and time to compare against (e.g., processes started before 7 days ago)
$comparisonDateTime = $currentDateTime.AddDays(-7)
# Get all processes
$allProcesses = Get-Process
# Filter processes that were started before the comparison date and time
$filteredProcesses = $allProcesses | Where-Object { $_.StartTime -gt $comparisonDateTime }
# Display the filtered processes
$filteredProcesses | Select-Object Name, StartTime
```

#### Less than or equal to (le)

Please note that using the Relational operators will in almost all cases cause your query to become advanced filters where you in most cases will need to add the header
ConsistencyLevel:eventual and also include the $count=true property in your query format has to be 'yyyy-mm-ddThh:mm:ss('.'s+)?(zzzzzz)?' An easy way for you to do this would be something like this:

```powershell
$((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))
```

And some example code:
```powershell
$uri = $baseUrl/groups/?`$filter=createdDateTime le 2025-02-02T08:14:23Z&`$count=true
# the anove time filter could also look like this:
$uri = $baseUrl/groups/?`$filter=createdDateTime le $((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And to provide something similar in powershell that does not look at an api

```powershell
# Get the current date and time
$currentDateTime = Get-Date
# Define a date and time to compare against (e.g., processes started before 7 days ago)
$comparisonDateTime = $currentDateTime.AddDays(-7)
# Get all processes
$allProcesses = Get-Process
# Filter processes that were started before the comparison date and time
$filteredProcesses = $allProcesses | Where-Object { $_.StartTime -le $comparisonDateTime }
# Display the filtered processes
$filteredProcesses | Select-Object Name, StartTime
```

#### Greater than or equal to (ge)

Please note that using the Relational operators will in almost all cases cause your query to become advanced filters where you in most cases will need to add the header
ConsistencyLevel:eventual and also include the $count=true property in your query format has to be 'yyyy-mm-ddThh:mm:ss('.'s+)?(zzzzzz)?' An easy way for you to do this would be something like this:

```powershell
$((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))
```

And some example code:
```powershell
$uri = $baseUrl/groups/?`$filter=createdDateTime ge 2025-02-02T08:14:23Z&`$count=true
# the anove time filter could also look like this:
$uri = $baseUrl/groups/?`$filter=createdDateTime ge $((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

And to provide something similar in powershell that does not look at an api

```powershell
# Get the current date and time
$currentDateTime = Get-Date
# Define a date and time to compare against (e.g., processes started before 7 days ago)
$comparisonDateTime = $currentDateTime.AddDays(-7)
# Get all processes
$allProcesses = Get-Process
# Filter processes that were started before the comparison date and time
$filteredProcesses = $allProcesses | Where-Object { $_.StartTime -ge $comparisonDateTime }
# Display the filtered processes
$filteredProcesses | Select-Object Name, StartTime
```

### Lambda operators

#### Any (any)

The Any operator basicly makes a foreach on the give property that you are searching in this is usefull for when you need to look for users where a property could pottentially contain multiple values like f.eks. the proxyaddress.
In the below query we are looking for any users whose proxyAddress contains an email of "admin@contoso.com"
So lets say we have a user that has the following 3 proxyaddresses
admin@contoso.com
morten@contoso.com
mynster@contoso.com

The user will be returned


```powershell
$uri = "$baseUrl/users?`$filter=proxyAddresses/any(x:x eq 'admin@contoso.com')"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders

```

To provide an example that is more like powershell we can take a look at the below sample using services:
First we are requesting the data. (/Users endpoint)
Then we are building our new ArrayList. (This is something we have to do in powershell this is handled automatically from Graph)
Then we are going over each service in services. (The any operator)
And if the Name of the Service is equal to "gpsvc" then we are adding it to our ArrayList.

```powershell
$services = Get-Service
$trueServices = [System.Collections.ArrayList]@()
foreach ($service in $services) {
    if ($service.Name -eq "gpsvc") {
        $trueServices.Add($service)
    }
}
```

#### All (all)

The All operator is very similar to the Any operator the diffrence here lies in where the Any operator returns true if just 1 value in a collection of lets say 3 contains the value we are looking for.
Whereas the All operator only returns true is if all values in our collection is true.
In the below query we are looking for any users whose proxyAddress is equal to an email of "admin@contoso.com"

lets say a user has 2 values in proxyAddresses which is
admin@contoso.com
morten@contoso.com
Then our query will not return the user but if a user has 1 value in proxyAddresses which is
admin@contoso.com
The user would be returned

```powershell
$uri = "$baseUrl/users?`$filter=proxyAddresses/all(x:x eq 'admin@contoso.com')"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To provide an example that is more like powershell we can take a look at the below sample using services:
First we are requesting the data. (/Users endpoint)
Then we are building our new ArrayList. (This is something we have to do in powershell this is handled automatically from Graph)
Then we evaluating if our $services.Name is equal to "gpsvc" and adding it to our ArrayList.
For this case since $services is a collection of multiple values in Name we will not add anything to our ArrayList eventhough we have 1 service that is named "gpsvc" because the all operator evaluates on all values at once.

```powershell
$services = Get-Service
$trueServices = [System.Collections.ArrayList]@()
if ($services.Name -eq "gpsvc") {
    $trueServices.Add($service)
}

```

### Conditional operators

#### And (and)

The And operator lets you evaluate on 2 or more conditions that needs to return true so lets say you need to find all users that is in a given company and has a specific job title you can use the AND operator to say that the company needs to be contoso and their jobtitle needs to be specialist (This is not case sensitive)

```powershell
$uri = "$baseUrl/users?`$filter=companyName eq 'contoso a/s' and jobTitle eq 'specialist'&`$count=true"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To provide an example that is more like powershell we can take a look at the below sample using services:
The service name should be "gpsvc" and the service status should be "Running"
```powershell
# Get all services
$services = Get-Service
# Filter services based on the conditions
$filteredServices = $services | Where-Object { $_.Name -eq "gpsvc" -and $_.Status -eq "Running" }
# Display the filtered services
$filteredServices | Select-Object Name, Status
```

#### Or (or)

The or operator lets you evaluate on at least 1 of your properties needs to return true so lets say you need to find all users that is in a given company or has a specific job title you can use the OR operator to say that the company needs to be contoso OR their jobtitle needs to be specialist (This is not case sensitive)

```powershell
$uri = "$baseUrl/users?`$filter=companyName eq 'bestseller A/S' or jobTitle eq 'specialist'&`$count=true"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To provide an example that is more like powershell we can take a look at the below sample using services:
The service name should be "gpsvc" or the service status should be "Running"
```powershell
# Get all services
$services = Get-Service
# Filter services based on the conditions
$filteredServices = $services | Where-Object { $_.Name -eq "gpsvc" -or $_.Status -eq "Running" }
# Display the filtered services
$filteredServices | Select-Object Name, Status
```

### Functions

#### Starts with (startswith)

The startswith function does as it states it filters on the property that you suply in the below case we use "displayName" and then parameter "morten" which will return all users where their displayname starts with morten.

```powershell
$uri = "$baseUrl/users?`$filter=startswith(displayName,'morten')"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To give a powershell example of the above filter below you will see a filter on the get-service command the services it will return those whose name starts with 'gp'.

```powershell
# Get all services
$services = Get-Service
# Filter services where the name starts with 'Win'
$filteredServices = $services | Where-Object { $_.Name -like 'gp*' }
# Display the filtered services
$filteredServices | Select-Object Name, Status
```

#### Ends with (endswith)

The endswith function filters on the property that you supply. In the example below, we use "displayName" and the parameter "mynster", which will return all users where their display name ends with "mynster".

```powershell
$uri = "$baseUrl/users?`$filter=endswith(displayName,'mynster')"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
#### Contains (contains)
```

To give a powershell example of the above filter below you will see a filter on the get-service command the services it will return those whose name ends with 'gp'.

```powershell
# Get all services
$services = Get-Service
# Filter services where the name ends with 'svc'
$filteredServices = $services | Where-Object { $_.Name -like '*svc' }
# Display the filtered services
$filteredServices | Select-Object Name, Status
```

#### Contains (contains)

The `contains` function filters on the property that you supply. In the example below, we use "displayName" and the parameter "admin", which will return all users where their display name contains "admin".

```powershell
$uri = "$baseUrl/users?`$filter=contains(displayName,'admin')"
# Make the API call
Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
```

To give a PowerShell example of the above filter, below you will see a filter on the Get-Service command. The services it will return include those whose name contains 'svc'.

```powershell
# Get all services
$services = Get-Service
# Filter services where the name contains 'svc'
$filteredServices = $services | Where-Object { $_.Name -like '*svc*' }
# Display the filtered services
$filteredServices | Select-Object Name, Status
```



## Reference/Documentation links

- Filtering: [https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http](https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http){:target="_blank"}
- Advanced Filtering: [https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http](https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http){:target="_blank"}
