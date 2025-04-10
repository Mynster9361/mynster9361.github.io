---
layout: page
title: ActionableMessages PowerShell Module
permalink: /modules/actionablemessages/
---

# ActionableMessages PowerShell Module

A powerful PowerShell module for creating interactive Actionable Messages for Microsoft Outlook and other Microsoft 365 applications. This module allows you to easily build rich, interactive content that enables recipients to take action directly from within their email client.

## Key Features

* Create rich, interactive cards with minimal code
* Support for all Adaptive Card elements and actions
* Send interactive emails through Graph API or Exchange
* Design forms, approvals, notifications, and more
* Simple PowerShell syntax for complex card layouts

## Installation

Install directly from the PowerShell Gallery:

```powershell
Install-Module -Name ActionableMessages -Scope CurrentUser
```

## Quick Start Guide

### Basic Notification Card

```powershell
# Create a new card
$card = New-AMCard -OriginatorId "your-originator-id" -Version "1.0"

# Add a header
$header = New-AMTextBlock -Text "Important Notification" -Size "Large" -Weight "Bolder"
Add-AMElement -Card $card -Element $header

# Add content
$message = New-AMTextBlock -Text "This is an important notification that requires your attention." -Wrap $true
Add-AMElement -Card $card -Element $message

# Add an action button
$action = New-AMOpenUrlAction -Title "View Details" -Url "https://example.com/details"
$actionSet = New-AMActionSet -Actions @($action)
Add-AMElement -Card $card -Element $actionSet

# Export the card to JSON
$jsonCard = Export-AMCard -Card $card

# For email delivery
$emailParams = Export-AMCardForEmail -Card $card -Subject "Important Notification" -ToRecipients "user@example.com"
```

### Interactive Approval Form

```powershell
# Create approval card
$card = New-AMCard -OriginatorId "your-originator-id" -Version "1.0"

# Add header
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Approval Request" -Size "Large" -Weight "Bolder")

# Add request details with facts
$facts = @(
    New-AMFact -Title "Requester" -Value "Jane Smith"
    New-AMFact -Title "Request #" -Value "REQ-2023-0789"
    New-AMFact -Title "Amount" -Value "`$1,250.00"
    New-AMFact -Title "Purpose" -Value "New Equipment"
)
$factSet = New-AMFactSet -Facts $facts
Add-AMElement -Card $card -Element $factSet

# Add comment field
$comment = New-AMTextInput -Id "comment" -Label "Comments:" -IsMultiline $true
Add-AMElement -Card $card -Element $comment

# Add approve/reject buttons
$approveParams = @{
    "Title"    = "Approve"
    "Verb"     = "POST"
    "Url"      = "https://api.example.com/approve"
    "Body"     = @{
        "requestId" = "REQ-2023-0789"
        "action"    = "approve"
        "comment"   = "{{comment.value}}"
    }
}
$rejectParams = @{
    "Title"    = "Reject"
    "Verb"     = "POST"
    "Url"      = "https://api.example.com/reject"
    "Body"     = @{
        "requestId" = "REQ-2023-0789"
        "action"    = "reject"
        "comment"   = "{{comment.value}}"
    }
}
$approveAction = New-AMExecuteAction @approveParams
$rejectAction = New-AMExecuteAction @rejectParams

$actionSet = New-AMActionSet -Actions @($approveAction, $rejectAction)
Add-AMElement -Card $card -Element $actionSet
```

## Module Structure

The module is organized into logical function categories:

* **Core Functions**: Card creation, manipulation, and export
* **Element Functions**: Visual components like text, images, and containers
* **Action Functions**: Interactive buttons and links
* **Input Functions**: Form elements for collecting user input

## Use Cases

* Approval workflows (expenses, time off, document publishing)
* IT service management (support tickets, incident response)
* Feedback collection and surveys
* Meeting and event RSVPs
* System notifications with actionable responses
* Status updates with quick actions
* Interactive reports

## Best Practices

* Register your originator ID before using in production
* Keep cards focused on a single task or information set
* Test cards across different Outlook clients (desktop, web, mobile)
* Provide fallback text for non-supporting email clients

## Resources

* [Adaptive Cards Documentation](https://adaptivecards.io/)
* [Outlook Actionable Messages Documentation](https://learn.microsoft.com/en-us/outlook/actionable-messages/)
* [Adaptive Cards Designer](https://adaptivecards.io/designer/)
* [Register Originator ID](https://aka.ms/publishactionableemails)
* [ActionableMessages PowerShell Module - Building Interactive Emails Made Easy](https://mynster9361.github.io/posts/ActionableMessagesModule/)

## Doing it withoout the module

* [Adaptive Cards to Email through MS Graph (Actionable messages)](https://mynster9361.github.io/posts/ActionableMessages/)
* [Adaptive Cards to Email through MS Graph (Actionable messages) Part 2](https://mynster9361.github.io/posts/ActionableMessagesPart2/)

## Command Reference

* [`Add-AMElement`](commands/Add-AMElement/)
* [`ConvertFrom-AMJson`](commands/ConvertFrom-AMJson/)
* [`Export-AMCard`](commands/Export-AMCard/)
* [`Export-AMCardForEmail`](commands/Export-AMCardForEmail/)
* [`New-AMActionSet`](commands/New-AMActionSet/)
* [`New-AMCard`](commands/New-AMCard/)
* [`New-AMChoice`](commands/New-AMChoice/)
* [`New-AMChoiceSetInput`](commands/New-AMChoiceSetInput/)
* [`New-AMColumn`](commands/New-AMColumn/)
* [`New-AMColumnSet`](commands/New-AMColumnSet/)
* [`New-AMContainer`](commands/New-AMContainer/)
* [`New-AMDateInput`](commands/New-AMDateInput/)
* [`New-AMExecuteAction`](commands/New-AMExecuteAction/)
* [`New-AMFact`](commands/New-AMFact/)
* [`New-AMFactSet`](commands/New-AMFactSet/)
* [`New-AMImage`](commands/New-AMImage/)
* [`New-AMImageSet`](commands/New-AMImageSet/)
* [`New-AMNumberInput`](commands/New-AMNumberInput/)
* [`New-AMOpenUrlAction`](commands/New-AMOpenUrlAction/)
* [`New-AMShowCardAction`](commands/New-AMShowCardAction/)
* [`New-AMTextBlock`](commands/New-AMTextBlock/)
* [`New-AMTextInput`](commands/New-AMTextInput/)
* [`New-AMTimeInput`](commands/New-AMTimeInput/)
* [`New-AMToggleInput`](commands/New-AMToggleInput/)
* [`New-AMToggleVisibilityAction`](commands/New-AMToggleVisibilityAction/)