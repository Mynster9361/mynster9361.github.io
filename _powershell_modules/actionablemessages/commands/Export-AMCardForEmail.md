---
layout: page
title: Export-AMCardForEmail
permalink: /modules/actionablemessages/commands/Export-AMCardForEmail/
---

# Export-AMCardForEmail

## SYNOPSIS
Exports an Adaptive Card as HTML email content for Microsoft Graph API or other email systems.

## SYNTAX

```powershell
Export-AMCardForEmail [-Card] <Hashtable> [-Subject <String>] [-FallbackText <String>] [-ToRecipients <String[]>] [-CreateGraphParams <SwitchParameter>] [-SaveToSentItems <Boolean>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Export-AMCardForEmail` function prepares an Adaptive Card for sending via email by embedding it in HTML
with the proper format for Microsoft Graph API. The card is embedded as a JSON payload in a `<script>` tag
with the appropriate content type.

The function provides two main output options:
1. HTML content only - suitable for use with any email sending mechanism.
2. Complete Microsoft Graph API parameters object - ready to use with Graph API endpoints.

This enables seamless integration with either Microsoft Graph API or other email sending methods.

The function also supports fallback text for email clients that do not support Adaptive Cards, ensuring
compatibility across different email platforms.

## EXAMPLES

### EXAMPLE 1
```powershell
# Get HTML content for an email (for use with any email system)
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Hello World")
$htmlContent = Export-AMCardForEmail -Card $card
```

#### Example explanation
```powershell
# Send using standard Send-MailMessage cmdlet
Send-MailMessage -To "recipient@example.com" -From "sender@example.com" `
    -Subject "Adaptive Card Test" -Body $htmlContent -BodyAsHtml `
    -SmtpServer "smtp.office365.com"
```

### EXAMPLE 2
```powershell
# Get complete Graph API parameters for sending an email
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Hello World")
$params = Export-AMCardForEmail -Card $card -Subject "Important Notification" `
    -ToRecipients "user@example.com" -CreateGraphParams
```

#### Example explanation
```powershell
# Send via Microsoft Graph
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/me/sendMail" -Body $params
```

### EXAMPLE 3
```powershell
# Sending to multiple recipients with Graph API
$card = New-AMCard -OriginatorId "1234567890" -Version "1.2"
Add-AMElement -Card $card -Element (New-AMTextBlock -Text "Team Meeting Reminder" -Size "Large")
```

#### Example explanation
```powershell
# Add action buttons
$acceptAction = New-AMOpenUrlAction -Title "Accept" -Url "https://teams.microsoft.com/meeting/accept"
$declineAction = New-AMOpenUrlAction -Title "Decline" -Url "https://teams.microsoft.com/meeting/decline"
$actionSet = New-AMActionSet -Actions @($acceptAction, $declineAction)
Add-AMElement -Card $card -Element $actionSet

# Create and send email to multiple recipients
$recipients = @("team.member1@example.com", "team.member2@example.com", "team.lead@example.com")
$params = Export-AMCardForEmail -Card $card -Subject "Team Meeting - Action Required" `
    -ToRecipients $recipients -CreateGraphParams

# Send using Microsoft Graph SDK
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/me/sendMail" -Body $params
```
## PARAMETERS

### -CreateGraphParams
(Optional) If specified, returns a complete Microsoft Graph API parameters object instead of just the HTML content.
This object can be directly used with `Invoke-MgGraphRequest` or other Graph API methods.

```yaml
Type: Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FallbackText
(Optional) Text to show in email clients that don't support Adaptive Cards.
Default is "This email contains an Adaptive Card. Please use Outlook to view it."

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveToSentItems
(Optional) When used with `-CreateGraphParams`, controls whether the sent message is saved to Sent Items.
Default is `$true`.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subject
(Optional) The email subject line. Default is "Adaptive Card Notification".

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ToRecipients
(Optional) An array of email addresses to send the email to. Required if `-CreateGraphParams` is specified.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Card
The Adaptive Card object to embed in the email. This should be a hashtable created using `New-AMCard` and
populated with elements using `Add-AMElement`.

```yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### System.Collections.Hashtable
An Adaptive Card object created using `New-AMCard` and populated with elements.

## OUTPUTS
### System.String or System.Collections.Hashtable
- Returns HTML content as a string when `-CreateGraphParams` is not specified.
- Returns a Microsoft Graph API parameters object when `-CreateGraphParams` is specified.

## NOTES
- This function creates HTML that embeds an Adaptive Card for use with Microsoft Graph API or other email systems.
- For the Adaptive Card to render correctly, the recipient must be using Outlook (desktop, web, or mobile).
- Other email clients will display the fallback text instead of the Adaptive Card.
- When using Microsoft Graph API, ensure you have the appropriate permissions:
  - `Mail.Send` for sending from your own mailbox.
  - `Mail.Send.Shared` for sending from a shared or delegated mailbox.

## RELATED LINKS
- [https://docs.microsoft.com/en-us/outlook/actionable-messages/
https://docs.microsoft.com/en-us/graph/api/user-sendmail
https://adaptivecards.io/](https://docs.microsoft.com/en-us/outlook/actionable-messages/
https://docs.microsoft.com/en-us/graph/api/user-sendmail
https://adaptivecards.io/)
- https://docs.microsoft.com/en-us/outlook/actionable-messages/
https://docs.microsoft.com/en-us/graph/api/user-sendmail
https://adaptivecards.io/
