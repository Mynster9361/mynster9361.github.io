---
title: Delta endpoints in MSGraph fastest data change fetcher
authors: mynster
date: 2026-06-07
tags: [powershell, msgraph]
description: Delta endpoints can be used to gather a complete set of data first and then subsequiently all changes over time
---

## Intro

If you have ever written a script that fetches all users, all groups, or all devices from Microsoft Graph on a schedule, you already know the pain: even with `$select` trimming down the properties and `$filter` narrowing the result set along with ´batching´, you are still re-downloading data that has not changed since the last run.
Delta endpoints are the answer to that problem.
They let you do one full sync to get a baseline, and from that point forward only receive the objects that were **added, updated, or deleted** since your last call.

>NOTE: the below result is of a tenant with 25k users

LinkedIn:
[Morten Mynster](https://www.linkedin.com/in/mortenmynster/)

Discord:
[Morten (Mynster)](https://discord.com/users/159029828748574720)

## What do Delta endpoints do?

A delta endpoint works in two phases:

1. **Initial sync** – You call the endpoint without a delta token. Graph pages through the full result set exactly like a normal request, but at the very end of the last page it returns a `@odata.deltaLink` instead of a `@odata.nextLink`.
2. **Incremental sync** – You store that delta link (or the token embedded in it) and use it on your next run. Graph now returns **only** the objects that changed since the token was issued, along with a fresh delta link for the next cycle.

Deleted objects are included too — they come back as stub objects with a `@removed` annotation so you know to remove them from your local copy.

The net effect is dramatic: a tenant with 50k users might return thousands of objects on the first call, but only a handful on subsequent runs when activity has been low.

### The token under the hood

The delta link URL looks like this:

```txt
https://graph.microsoft.com/v1.0/users/delta?$deltatoken=<opaque-string>
```

The opaque token encodes a server-side cursor. You do not need to understand its contents — just store it and hand it back on the next request.

Two important expiry behaviours to be aware of:

- **Token expiry** — For directory objects (users, groups, devices, service principals, etc.) delta tokens are valid for **7 days**. For Outlook entities (messages, mail folders, events, contacts, etc.) the limit is not fixed — it depends on the size of the internal delta token cache. When a token expires, Graph returns a `40X` error with code `syncStateNotFound`. That is your signal to restart with a full sync.
- **Synchronisation reset** — Separately, Graph can return `410 Gone` with a `Location` header pointing to an empty `$deltatoken`. This happens due to internal maintenance or tenant migration and also requires a fresh full sync.

## So when would a use case for this occur?

Think about any recurring automation that keeps a local copy of directory data in sync:

- **Nightly user sync to a database or SIEM** — Instead of re-importing 80k rows every night, only process the 30 accounts that were created, changed, or deleted since yesterday.
- **Group membership cache** — Keep a local hashtable of group members up to date without hammering the groups endpoint every few minutes.
- **Device compliance dashboard** — Track which devices moved in or out of compliance since the last poll.
- **Licence reconciliation** — Detect newly onboarded or offboarded users without a full tenant export each time.
- **Teams channel message sync** — Archive only new messages rather than fetching entire conversation histories.

Any scenario where you need *what changed* rather than *everything that exists* is a candidate for a delta endpoint.

## Benchmarking: full fetch vs delta

### Using Invoke-RestMethod (raw approach)

To understand what is happening under the hood, here is the full implementation using plain `Invoke-RestMethod`.

**First run — full sync, delta link captured**

```powershell
$clientId = ''
$clientSecret = ''
$tenantId = ''

$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

$headers = @{
    Authorization  = "Bearer $($tokenResponse.access_token)"
    'Content-Type' = 'application/json'
}

Measure-Command {
    $users = [System.Collections.Generic.List[object]]::new()
    $t = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/delta" -Headers $headers -Method GET

    do {
        $t.value | ForEach-Object { $users.Add($_) }
        if ($t.'@odata.nextLink') {
            $t = Invoke-RestMethod -Uri $t.'@odata.nextLink' -Headers $headers -Method GET
        }
    } while ($t.'@odata.nextLink')

    # At this point $t.'@odata.deltaLink' holds the cursor for the next run
    $deltaLink = $t.'@odata.deltaLink'
    $deltaLink | Set-Content -Path "delta_link.txt" -Encoding utf8

    $users | ConvertTo-Json -Depth 10 | Out-File -FilePath "delta_users_full.json" -Encoding utf8
}
<#
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 44
Milliseconds      : 18
Ticks             : 440184726
TotalDays         : 0,0005094730625
TotalHours        : 0,0122273535
TotalMinutes      : 0,73364121
TotalSeconds      : 44,0184726
TotalMilliseconds : 44018,4726
#>
```

Notice the loop condition: while a `@odata.nextLink` exists we keep paging.
When there are no more pages Graph replaces it with `@odata.deltaLink` — that URL is your cursor and must be saved before the script exits.

**Subsequent runs — only changes**

```powershell
$deltaLink = Get-Content -Path "delta_link.txt" -Raw

Measure-Command {
    $changes = [System.Collections.Generic.List[object]]::new()
    $t = Invoke-RestMethod -Uri $deltaLink -Headers $headers -Method GET

    do {
        $t.value | ForEach-Object { $changes.Add($_) }
        if ($t.'@odata.nextLink') {
            $t = Invoke-RestMethod -Uri $t.'@odata.nextLink' -Headers $headers -Method GET
        }
    } while ($t.'@odata.nextLink')

    # Save the new delta link for the next run
    $t.'@odata.deltaLink' | Set-Content -Path "delta_link.txt" -Encoding utf8

    $changes | ConvertTo-Json -Depth 10 | Out-File -FilePath "delta_users_changes.json" -Encoding utf8
}
<#
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 135
Ticks             : 1359807
TotalDays         : 1,57385069444444E-06
TotalHours        : 3,77724166666667E-05
TotalMinutes      : 0,002266345
TotalSeconds      : 0,1359807
TotalMilliseconds : 135,9807
#>
```

This works, but as you can see there is quite a bit of boilerplate: manual pagination, manually detecting which link type came back on the last page, and manually persisting the cursor.
Also note that i had 0 changes between these two but instead of having to gather all the data again and basicly wasting 44 seconds we were just told no changes since last request so in this instance it is the very least amount of time to execute.

---

### Using EntraAuth (simplified approach)

The [EntraAuth](https://github.com/FriedrichWeinmann/EntraAuth) module wraps all of the above into a single parameter.

**First run — full sync, baseline stored**

>NOTE: The time result will be the same just a lot less code

```powershell
Connect-EntraService -Service "Graph" -ClientID $clientId -TenantID $tenantId -ClientSecret $clientSecret

$delta = @{}

Measure-Command {
    $users = Invoke-EntraRequest -Path 'users/delta' -DeltaSession $delta
    $users | ConvertTo-Json -Depth 10 | Out-File -FilePath "delta_users_full.json" -Encoding utf8
}
```

This will page through every user in the tenant and write the full set to disk.
The `$delta` hashtable is populated in-place by the module with the delta token, ready for the next run.

**Subsequent runs — only changes**

```powershell
Measure-Command {
    $changes = Invoke-EntraRequest -Path 'users/delta' -DeltaSession $delta
    $changes | ConvertTo-Json -Depth 10 | Out-File -FilePath "delta_users_with_delta_session.json" -Encoding utf8
}
```

On the second call the `-DeltaSession` parameter makes `Invoke-EntraRequest` automatically append the stored delta token to the request URL.
In a quiet tenant the response is near-instant because almost nothing has changed.

### Why the `-DeltaSession` parameter is so convenient

Compare the two approaches side by side. With raw `Invoke-RestMethod` you must:

1. Detect whether the last page returned `@odata.deltaLink` or `@odata.nextLink`.
2. Extract the delta link from the final response yourself.
3. Persist the link to disk between runs and restore it on the next invocation.
4. Remember to update the saved link after every run.

With `-DeltaSession` you pass a plain `[hashtable]` reference and the module handles all of that bookkeeping for you. The hashtable is updated in-place so the same variable is ready to use on the next iteration.

### Persisting the EntraAuth delta session between script runs

Because `$delta` is just a hashtable, serialising and restoring it is trivial:

```powershell
# Save token to disk after each run
$delta | ConvertTo-Json | Set-Content -Path "delta_token.json" -Encoding utf8

# Restore on next run
$delta = Get-Content -Path "delta_token.json" -Raw | ConvertFrom-Json -AsHashtable
```

Now your script can be run in a scheduled task and pick up exactly where it left off every time.

## Handling deleted objects

Delta responses include deletions as lightweight stub objects. When processing changes, check for the `@removed` key:

```powershell
foreach ($user in $changes) {
    if ($user.'@removed') {
        switch ($user.'@removed'.reason) {
            'changed' {
                # Soft-deleted — still restorable via the deletedItems API
                Write-Host "Soft-deleted (restorable): $($user.id)"
            }
            'deleted' {
                # Permanently deleted — cannot be restored
                Write-Host "Permanently deleted: $($user.id)"
            }
        }
    } else {
        # Object was added or updated
        Write-Host "Changed: $($user.displayName)"
    }
}
```

The `reason` value matters if your downstream system needs to distinguish between a recoverable deletion (`changed`) and a hard delete (`deleted`).

## Available Delta endpoints currently

```txt
# Directory / identity
/administrativeunits/delta
/applications/delta
/contacts/delta           # organisational contacts
/devices/delta
/directoryroles/delta
/directoryobjects/delta
/oauth2permissiongrants/delta
/serviceprincipals/delta
/users/delta

# Groups
/groups/delta
/groups/{id}/calendar/calendarview/delta
/groups/{id}/calendar/events/delta
/groups/{id}/calendarview/delta
/groups/{id}/drive/root/delta
/groups/{id}/events/delta
/groups/{id}/planner/plans/delta

# OneDrive / SharePoint
/drives/{id}/root/delta
/sites/delta
/sites/{id}/drive/root/delta
/sites/{id}/lists/{id}/items/delta

# Planner
/planner/plans/{id}/buckets/delta
/planner/rosters/{id}/plans/delta
/planner/tasks/delta

# Teams
/teams/{id}/channels/{id}/messages/delta

# Per-user: calendar / mail / contacts
/users/{id}/calendar/events/delta
/users/{id}/calendargroups/{id}/calendars/{id}/events/delta
/users/{id}/calendars/delta
/users/{id}/calendars/{id}/calendarview/delta
/users/{id}/calendars/{id}/events/delta
/users/{id}/calendarview/delta
/users/{id}/contactfolders/delta
/users/{id}/contactfolders/{id}/contacts/delta
/users/{id}/events/delta
/users/{id}/mailfolders/delta
/users/{id}/mailfolders/{id}/messages/delta
/users/{id}/mailboxfolders/delta      # mailboxFolder resource
/users/{id}/mailboxitems/delta        # mailboxItem resource

# Per-user: drive / Planner / To Do
/users/{id}/drive/root/delta
/users/{id}/planner/all/delta
/users/{id}/planner/tasks/delta
/users/{id}/tasks/lists/delta
/users/{id}/tasks/lists/{id}/tasks/delta
/users/{id}/todo/lists/delta
/users/{id}/todo/lists/{id}/tasks/delta

# Education
/education/classes/delta
/education/schools/delta
/education/users/delta
/education/classes/{id}/assignments/delta

# Calls / recordings (beta only)
/communications/callRecords/{id}/sessions/delta
/teams/{id}/channels/{id}/messages/{id}/replies/delta
```

Reference: [Microsoft Graph delta query overview](https://learn.microsoft.com/en-us/graph/delta-query-overview)
