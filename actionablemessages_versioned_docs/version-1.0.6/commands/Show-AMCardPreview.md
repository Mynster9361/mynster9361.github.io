---
title: Show-AMCardPreview
---

# Show-AMCardPreview

## SYNOPSIS
Displays an ASCII preview of an Adaptive Card in the terminal.

## SYNTAX

```
Show-AMCardPreview [-card] <Object> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The \`Show-AMCardPreview\` function takes an Adaptive Card object as input and renders an ASCII representation of the card in the terminal.
It dynamically adjusts the width of the preview based on the terminal size and supports nested containers, columns, and various card elements.

## EXAMPLES

### EXAMPLE 1
```
# Example 1: Render an application usage survey card
$appCardParams = @{
    OriginatorId      = "your-originator-id"
    ApplicationName   = "Adobe Creative Cloud"
    Version           = "2023"
    Vendor            = "Adobe"
    LicenseCount      = 50
    ActiveUserCount   = 32
    RenewalDate       = (Get-Date).AddMonths(3)
    Department        = "IT Software Asset Management"
    TicketNumber      = "SAM-2023-003"
    Description       = "The IT department is conducting a review of software licenses and usage. Please provide information about your use of this application to help us optimize licensing costs and ensure continued access for essential business functions."
    FrequencyChoices  = [ordered]@{
        "daily" = "Daily"
        "weekly" = "Several times per week"
        "monthly" = "Few times per month"
        "rarely" = "Rarely (a few times per year)"
        "never" = "Never"
    }
    ImportanceChoices = [ordered]@{
        "critical" = "Critical - Cannot perform job without it"
        "important" = "Important - Major impact if unavailable"
        "useful" = "Useful - Improves efficiency but have workarounds"
        "optional" = "Optional - Nice to have but not essential"
        "unnecessary" = "Unnecessary - Could work without it"
    }
    AlternativeQuestion = $true
    TeamMemberUsage    = $true
    Suggestion         = $true
    ResponseEndpoint   = "https://api.example.com/application-usage"
    ResponseBody       = "{`"ticketNumber`": `"$TicketNumber`", `"applicationName`": `"$ApplicationName`", `"version`": `"$Version`", `"usageFrequency`": `"{{usage-frequency.value}}`", `"businessFunction`": `"{{business-function.value}}`", `"usedFeatures`": `"{{used-features.value}}`", `"importanceRating`": `"{{importance-rating.value}}`", `"alternativesAware`": `"{{alternatives-aware.value}}`", `"alternativesDetails`": `"{{alternatives-details.value}}`", `"teamUsage`": `"{{team-usage.value}}`", `"improvementSuggestions`": `"{{improvement-suggestions.value}}`}"`
}
```

$card = New-AMApplicationUsageSurveyCard @appCardParams
$cardJson = Export-AMCard -Card $card
Show-CardPreview -Card $card

This example renders an application usage survey card with various input fields and options.

### EXAMPLE 2
```
# Example 2: Render a system notification card
$notificationParams = @{
    OriginatorId = "your-originator-id"
    Title        = "System Notification"
    Message      = "The nightly backup completed successfully."
    Severity     = "Good"
    Details      = "Backup completed at 02:00 AM. No errors were encountered."
    DetailsUrl   = "https://example.com/backup-report"
}
```

$notificationCard = New-AMNotificationCard @notificationParams
$cardJson = Export-AMCard -Card $notificationCard
Show-CardPreview -Card $notificationCard

This example renders a system notification card with a success message and a link to view details.

## PARAMETERS

### -card
The Adaptive Card object to be rendered.
This parameter is mandatory.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
- The function dynamically adjusts the width of the preview based on the terminal size.
- The card object must be in a format compatible with Adaptive Cards.

## RELATED LINKS

[https://adaptivecards.io](https://adaptivecards.io)


