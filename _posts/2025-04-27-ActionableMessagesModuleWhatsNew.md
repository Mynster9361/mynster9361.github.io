---
title: ActionableMessages PowerShell Module - New Prebuilt Cards in v1.0.4
author: mynster
date: 2025-04-27 21:15:00 +0100
categories: [PowerShell, Modules]
tags: [powershell, msgraph, mail, adaptive cards, actionable messages]
description: Explore the new prebuilt Adaptive Cards introduced in version 1.0.4 of the ActionableMessages PowerShell module.
---

## ActionableMessages PowerShell Module - New Prebuilt Cards in v1.0.4

Version 1.0.4 of the ActionableMessages PowerShell module introduces **8 new prebuilt Adaptive Cards** to simplify common workflows. These cards are designed to address frequent use cases like notifications, approvals, surveys, and monitoring, making it easier than ever to create interactive emails.

## What’s New?

Here’s a quick overview of the new cards:

- **`New-AMNotificationCard`**: Create system notifications with optional severity levels.
- **`New-AMServiceAlertCard`**: Notify users about service status changes with actionable options.
- **`New-AMServerMonitoringCard`**: Monitor server health and notify users about issues.
- **`New-AMServerPurposeSurveyCard`**: Collect information about server purpose and usage.
- **`New-AMITResourceRequestCard`**: Request IT resources with detailed input fields.
- **`New-AMApprovalCard`**: Streamline approval workflows with customizable actions.
- **`New-AMApplicationUsageSurveyCard`**: Gather feedback on application usage and importance.
- **`New-AMDiskSpaceAlertCard`**: Alert users about low disk space with actionable options.

Let’s explore some examples of these cards in action.

---

### `New-AMNotificationCard`

The `New-AMNotificationCard` is perfect for sending system notifications. You can customize the title, message, severity, and include a link for more details.

![New-AMNotificationCard](/assets/img/posts/New-AMNotificationCard.png)

```powershell
# Create a notification card
$notificationParams = @{
    OriginatorId = "system-notifications"
    Title        = "Backup Completed"
    Message      = "The nightly backup completed successfully."
    Severity     = "Good"
    Details      = "Backup completed at 02:00 AM. No errors were encountered."
    DetailsUrl   = "https://example.com/backup-report"
}

$notificationCard = New-AMNotificationCard @notificationParams
Export-AMCardForEmail -Card $notificationCard -Subject "System Notification" -ToRecipients "admin@example.com"
```

### `New-AMServiceAlertCard`
The `New-AMServiceAlertCard` notifies users about service status changes and provides actionable options that you determine like restarting the service or acknowledging the alert.

![New-AMServiceAlertCard](/assets/img/posts/New-AMServiceAlertCard.png)

```powershell
# Create a service alert card
$serviceAlertParams = @{
    OriginatorId       = "service-monitoring"
    Server             = "WEBSRV01"
    ServiceName        = "IIS"
    ServiceDisplayName = "Web Server"
    Status             = "Stopped"
    MonitoringUrl      = "https://monitoring.example.com/service-status"
    ActionUrl          = "https://monitoring.example.com/restart-service"
    ActionTitle        = "Restart Service"
}

$serviceAlertCard = New-AMServiceAlertCard @serviceAlertParams
Export-AMCardForEmail -Card $serviceAlertCard -Subject "Service Alert: IIS Stopped" -ToRecipients "admin@example.com"
```

### `New-AMServerMonitoringCard`
The `New-AMServerMonitoringCard` helps monitor server health and notify users about issues like degraded performance or offline status.

![New-AMServerMonitoringCard](/assets/img/posts/New-AMServerMonitoringCard.png)

```powershell
# Create a server monitoring card
$serverMonitoringParams = @{
    OriginatorId  = "server-monitoring"
    Server        = "DCSRV01"
    Status        = "Offline"
    MonitoringUrl = "https://monitoring.example.com/servers/DCSRV01"
    ActionUrl     = "https://monitoring.example.com/restart-server"
    ActionTitle   = "Restart Server"
}

$serverMonitoringCard = New-AMServerMonitoringCard @serverMonitoringParams
Export-AMCardForEmail -Card $serverMonitoringCard -Subject "Server Alert: DCSRV01 Offline" -ToRecipients "admin@example.com"
```

### `New-AMServerPurposeSurveyCard`
The `New-AMServerPurposeSurveyCard` collects information about a server’s purpose, criticality, and maintenance preferences.

![New-AMServerPurposeSurveyCard](/assets/img/posts/New-AMServerPurposeSurveyCard.png)

```powershell
# Create a server purpose survey card
$serverSurveyParams = @{
    OriginatorId       = "server-survey"
    ServerName         = "SVR-APP-001"
    OperatingSystem    = "Windows Server 2019"
    DetectedServices   = @("IIS", "SQL Server")
    PurposeChoices     = @{
        "application" = "Application Server"
        "database"    = "Database Server"
    }
    CriticalityChoices = @{
        "critical" = "Mission Critical"
        "high"     = "High"
    }
    MaintenanceChoices = @{
        "weekends" = "Weekends Only"
        "nights"   = "Weeknights"
    }
}

$serverSurveyCard = New-AMServerPurposeSurveyCard @serverSurveyParams
Export-AMCardForEmail -Card $serverSurveyCard -Subject "Server Purpose Survey" -ToRecipients "admin@example.com"
```

### `New-AMITResourceRequestCard`
The `New-AMITResourceRequestCard` simplifies IT resource requests with predefined fields for resource type, urgency, and justification.

![New-AMITResourceRequestCard](/assets/img/posts/New-AMITResourceRequestCard.png)

```powershell
# Create an IT resource request card
$resourceRequestParams = @{
    OriginatorId = "it-resource-requests"
    RequestHeader = "Request New Hardware"
    RequestDescription = "Use this form to request new hardware resources."
    UrgencyChoices = @{
        "critical" = "Critical"
        "high"     = "High"
        "medium"   = "Medium"
        "low"      = "Low"
    }
}

$resourceRequestCard = New-AMITResourceRequestCard @resourceRequestParams
Export-AMCardForEmail -Card $resourceRequestCard -Subject "IT Resource Request" -ToRecipients "admin@example.com"
```

### `New-AMApprovalCard`
The `New-AMApprovalCard` streamlines approval workflows with customizable actions for approving or rejecting requests.

![New-AMApprovalCard](/assets/img/posts/New-AMApprovalCard.png)

```powershell
# Create an approval card
$approvalParams = @{
    OriginatorId = "approval-system"
    Title        = "Leave Request Approval"
    RequestID    = "REQ-2023-002"
    Requester    = "Jane Smith"
    ApproveUrl   = "https://api.example.com/approve"
    RejectUrl    = "https://api.example.com/reject"
}

$approvalCard = New-AMApprovalCard @approvalParams
Export-AMCardForEmail -Card $approvalCard -Subject "Approval Request: Leave Request" -ToRecipients "manager@example.com"
```

### `New-AMApplicationUsageSurveyCard`
The `New-AMApplicationUsageSurveyCard` gathers feedback on application usage, importance, and improvement suggestions.

![New-AMApplicationUsageSurveyCard](/assets/img/posts/New-AMApplicationUsageSurveyCard.png)

```powershell
# Create an application usage survey card
$appSurveyParams = @{
    OriginatorId      = "app-survey"
    ApplicationName   = "Microsoft Excel"
    Version           = "2021"
    Department        = "Finance"
    FrequencyChoices  = @{
        "daily"   = "Daily"
        "weekly"  = "Weekly"
        "monthly" = "Monthly"
    }
}

$appSurveyCard = New-AMApplicationUsageSurveyCard @appSurveyParams
Export-AMCardForEmail -Card $appSurveyCard -Subject "Application Usage Survey" -ToRecipients "user@example.com"

```

### `New-AMDiskSpaceAlertCard`
The `New-AMDiskSpaceAlertCard` alerts users about low disk space and provides actionable options like cleanup or acknowledgment.

![New-AMDiskSpaceAlertCard](/assets/img/posts/New-AMDiskSpaceAlertCard.png)

```powershell
# Create a disk space alert card
$diskAlertParams = @{
    OriginatorId = "disk-monitoring"
    Server       = "SQLSRV01"
    Drive        = "C:"
    FreeSpace    = "5 GB"
    TotalSize    = "100 GB"
    ActionUrl    = "https://example.com/cleanup"
    ActionTitle  = "Clean Up Disk"
}

$diskAlertCard = New-AMDiskSpaceAlertCard @diskAlertParams
Export-AMCardForEmail -Card $diskAlertCard -Subject "Disk Space Alert: SQLSRV01" -ToRecipients "admin@example.com"
```

## Getting started with Actionable Messages and how to send it

### Setting up your provider for actionable messages

First off, before we are able to send an actionable message, we need to set up a Provider in the "Actionable Email Developer Dashboard"
- Actionable Email Developer Dashboard [https://outlook.office.com/connectors/oam/publish](https://outlook.office.com/connectors/oam/publish){:target="_blank"}
  - *Note you might have to have outlook on the web open first*
  - *Note that if you are not using "Test Users" either your Exchange Administrator or Global administrator has to approve this provider before you can use it*

![Actionable Email Developer Dashboard](/assets/img/posts/Actionable_Email_Developer_Dashboard.png)

Click the "New Provider"

Here you will need to setup the following as a minimum:
*None of these settings can be changed later, you will need to create a new provider if you need any changes made.*
- Friendly Name (Any name you would like to use for the provider, I would recommend calling it something that makes sense to what you are doing)
- Sender email address from which actionable emails will originate (This is the email that will be used to send your actionable message can be multiple emails)
- Who are you enabling this for? (If you are just testing then just chose Test Users) and set the emails in the *Test user email addresses seperated with ";" The test scenario will be auto-approved but can also only be used for the users that you specify.* For production use case use the `Organization`
- Checkmark in "I accept the terms and conditions of the"


![Provider Setup](/assets/img/posts/Provider_Setup.png)


After you have filled in minimum requirements press on save *If you have selected `Organization` you will need your exchange administrator or global administrator to approve it and the requst can be seen by them on the below url*

[https://outlook.office.com/connectors/oam/admin](https://outlook.office.com/connectors/oam/admin){:target="_blank"}

Once approved copy the `Provider Id (originator)` as we will need this for when we are sending our actionable messages


### Sample script to actually send a card

If you are unsure of how you can send an adaptive card using powershell you can add the following to a .ps1 file

```powershell
# Your originator id if you are unsure how to get one please have a look at this part:
#
$originatorId = "your-originator-id"

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = "your tenant id"
$clientId = "a client id for an app with access to send mails on your behalf"
$clientSecret = "the secret for the above appp"
$userToSendTo = "your own email address"

<#
    The card you would like to test goes below here please use the variable $card for your card
#>




<#
    The card you would like to test goes above here please use the variable $card for your card
#>


$graphParams = Export-AMCardForEmail -Card $card -Subject "System Notification" -ToRecipients $userToSendTo -CreateGraphParams -FallbackText "Your email client doesn't support Adaptive Cards"
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
$uri = "$graphApiUri/users/$userToSendTo/sendMail"
Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
```


## Conclusion
These new prebuilt cards make it easier than ever to create Adaptive Cards for common scenarios. Whether you’re notifying users, gathering feedback, or managing approvals, the ActionableMessages PowerShell module has you covered.


For more details, check out the [documentation](https://mynster9361.github.io/modules/actionablemessages/){:target="_blank"} or the [GitHub repository](https://github.com/Mynster9361/ActionableMessages){:target="_blank"}.
