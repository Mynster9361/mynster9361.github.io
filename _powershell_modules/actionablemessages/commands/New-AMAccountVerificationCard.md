---
layout: page
title: New-AMAccountVerificationCard
permalink: /modules/actionablemessages/commands/New-AMAccountVerificationCard/
---

# New-AMAccountVerificationCard

## SYNOPSIS
Creates an Adaptive Card for account verification.

## SYNTAX

```powershell
New-AMAccountVerificationCard [-OriginatorId <String>] [-Username] <String> [-AccountOwner <String>] [-Department <String>] [-LastLoginDate <DateTime>] [-InactiveDays <Int32>] [-AccessibleSystems <String[]>] [-TicketNumber <String>] [-DisableDate <DateTime>] [-DisableText <String>] [-statusChoices <Object>] [-ResponseEndpoint <String>] [-ResponseBody <String>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-AMAccountVerificationCard` function generates an Adaptive Card to notify users about an account that requires verification.
The card includes details about the account, its owner, department, last login, and systems the account has access to.
It also provides options for the user to confirm, disable, or transfer the account, along with a comment field for additional input.

## EXAMPLES

### EXAMPLE 1
```powershell
# Example 1: Create an account verification card using splatting
$accountCardParams = @{
    OriginatorId       = "your-originator-id"
    Username           = "jsmith"
    AccountOwner       = "John Smith"
    Department         = "Marketing"
    LastLoginDate      = (Get-Date).AddDays(-120)
    InactiveDays       = 120
    AccessibleSystems  = @("CRM System", "Marketing Automation", "Document Repository")
    TicketNumber       = "ACC-2023-001"
    DisableDate        = (Get-Date).AddDays(14)
    DisableText        = "This account has been identified as inactive."
    StatusChoices      = @{
        "keep" = "Account is still needed and actively used"
        "keep-infrequent" = "Account is needed but used infrequently"
        "disable" = "Account can be disabled"
        "transfer" = "Account needs to be transferred to another user"
        "unknown" = "I don't know / Need more information"
    }
    ResponseEndpoint   = "https://api.example.com/account-verification"
    ResponseBody       = "{`"ticketNumber`": `"$TicketNumber`", `"username`": `"$Username`", `"accountStatus`": `"{{account-status.value}}`", `"comment`": `"{{comment.value}}`", `"transferTo`": `"{{transfer-to.value}}`}"
}
```

#### Example explanation
```powershell
$accountCard = New-AMAccountVerificationCard @accountCardParams
```

### EXAMPLE 2
```powershell
# Example 2: Create a simple account verification card using splatting
$simpleAccountCardParams = @{
    OriginatorId       = "account-verification-system"
    Username           = "asmith"
    AccountOwner       = "Alice Smith"
    LastLoginDate      = (Get-Date).AddDays(-60)
    InactiveDays       = 60
    ResponseEndpoint   = "https://api.example.com/account-verification"
    ResponseBody       = "{`"ticketNumber`": `"$TicketNumber`", `"username`": `"$Username`", `"accountStatus`": `"{{account-status.value}}`", `"comment`": `"{{comment.value}}`", `"transferTo`": `"{{transfer-to.value}}`}"
}
```

#### Example explanation
```powershell
$accountCard = New-AMAccountVerificationCard @simpleAccountCardParams
```
## PARAMETERS

### -OriginatorId
The originator ID of the card. This is used to identify the source of the card. Defaults to "your-originator-id".

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
The username of the account being verified.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccountOwner
(Optional) The name of the account owner.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Department
(Optional) The department associated with the account.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastLoginDate
(Optional) The date and time of the last login for the account.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InactiveDays
(Optional) The number of days the account has been inactive. Defaults to 90 days.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessibleSystems
(Optional) A list of systems the account has access to.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: None

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TicketNumber
(Optional) The ticket number associated with the account verification request.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableDate
(Optional) The date when the account will be disabled if no response is received.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: None

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableText
(Optional) The text displayed to describe the reason for the account verification. Defaults to a predefined message.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -statusChoices
(Optional) A hashtable of status choices for the account. Each key-value pair represents an option and its description.
Defaults to:
    @{
        "keep" = "Account is still needed and actively used"
        "keep-infrequent" = "Account is needed but used infrequently"
        "disable" = "Account can be disabled"
        "transfer" = "Account needs to be transferred to another user"
        "unknown" = "I don't know / Need more information"
    }

```yaml
Type: Object
Parameter Sets: (All)
Aliases: None

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResponseEndpoint
(Optional) The URL where the response will be sent. Defaults to "https://api.example.com/account-verification".

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResponseBody
(Optional) The body of the POST request sent to the `ResponseEndpoint`.
This is a JSON string that includes placeholders for dynamic values such as the ticket number, username, account status, comments, and transfer details.
Defaults to:
    "{`"ticketNumber`": `"$TicketNumber`", `"username`": `"$Username`", `"accountStatus`": `"{{account-status.value}}`", `"comment`": `"{{comment.value}}`", `"transferTo`": `"{{transfer-to.value}}`}"

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None

## OUTPUTS
### None

## NOTES
This function is part of the Actionable Messages module and is used to create Adaptive Cards for account verification.
The card can be exported and sent via email or other communication channels.
