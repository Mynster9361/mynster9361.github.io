---
layout: page
title: New-AMExecuteAction
permalink: /modules/actionablemessages/commands/New-AMExecuteAction/
---

# New-AMExecuteAction

## SYNOPSIS
Creates an HTTP action for an Adaptive Card.

## SYNTAX

```powershell
New-AMExecuteAction [-Title] <String> [-Verb] <String> [-Url <String>] [-Body <String>] [-Data <Object>] [-Id <String>] [-IsPrimary <Object>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-AMExecuteAction` function generates an `Action.Http` element for an Adaptive Card.
This action allows you to make HTTP requests when the action button is clicked.
It is commonly used in Outlook Actionable Messages to trigger server-side operations such as
approving requests, submitting data, or performing other backend API calls.

Note: In Actionable Messages, the correct action type is `Action.Http`, not `Action.Execute`.

## EXAMPLES

### EXAMPLE 1
```powershell
# Create a simple approval action
$approveAction = New-AMExecuteAction -Title "Approve" -Verb "POST" `
    -Url "https://api.example.com/approve" `
    -Body '{"requestId": "12345", "status": "approved"}'
```


### EXAMPLE 2
```powershell
# Create an action with dynamic user data
$rejectAction = New-AMExecuteAction -Title "Reject" -Verb "POST" `
    -Url "https://api.contoso.com/api/requests/reject" `
    -Body '{"requestId": "ABC123", "rejectedBy": "{{userEmail}}", "timestamp": "{{utcNow}}"}'
```


### EXAMPLE 3
```powershell
# Create an action with a PowerShell object as data
$data = @{
    requestId = "REQ-789"
    action = "complete"
    comments = "Task completed successfully"
}
$completeAction = New-AMExecuteAction -Title "Mark Complete" -Verb "POST" `
    -Url "https://tasks.example.org/api/complete" `
    -Data $data
```


### EXAMPLE 4
```powershell
# Create a primary action button
$primaryAction = New-AMExecuteAction -Title "Submit" -Verb "POST" `
    -Url "https://api.example.com/submit" -IsPrimary $true
```

## PARAMETERS

### -Title
The text to display on the action button.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Verb
The HTTP verb/method to use for the request (e.g., "POST", "GET", "PUT", "DELETE").

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

### -Url
(Optional) The URL endpoint that will receive the HTTP request when the button is clicked.

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

### -Body
(Optional) A JSON string containing the payload to send with the request.
You can include user-specific tokens like `{{userEmail}}` or `{{utcNow}}` that will be replaced at runtime.

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

### -Data
(Optional) A data object (hashtable) to include with the request. This is an alternative to `Body`
for when you want to specify the data as a PowerShell object rather than a JSON string.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
(Optional) A unique identifier for the action. If not specified, an empty string is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsPrimary
(Optional) Indicates whether this action is the primary action. If set to `$true`, the button style
will be set to "positive" to visually indicate its importance.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: None

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to `New-AMExecuteAction`.

## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the `Action.Http` element.

## NOTES
- In Actionable Messages, the correct action type is `Action.Http`, not `Action.Execute`.
- For security reasons, the target URL must be registered with the Actionable Email Developer Dashboard
  and associated with your Originator ID before it can be used in production environments.
- The `method` property is used to specify the HTTP verb (e.g., "POST"), not `verb`.

## RELATED LINKS
- [https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#actions](https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#actions)
