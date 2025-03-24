---
layout: page
title: New-AMExecuteAction
permalink: /modules/actionablemessages/commands/New-AMExecuteAction/
---

# New-AMExecuteAction

## SYNOPSIS
Creates an HTTP action for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates an HTTP action for an Adaptive Card.
.DESCRIPTION
Creates an Action.Http element that makes an HTTP request when the action button is clicked.
This action is used in Outlook Actionable Messages to trigger server-side operations like
approving requests, submitting data, or any other operation requiring a backend API call.
.PARAMETER Title
The text to display on the action button.
.PARAMETER Verb
The HTTP verb/method to use for the request (e.g., "POST", "GET", "PUT", "DELETE").
.PARAMETER Url
The URL endpoint that will receive the HTTP request when the button is clicked.
.PARAMETER Body
Optional JSON string containing the payload to send with the request.
You can include user-specific tokens like {{userEmail}} that will be replaced at runtime.
.PARAMETER Data
Optional data object (hashtable) to include with the request. This is an alternative to Body
for when you want to specify the data as a PowerShell object rather than a JSON string.
.PARAMETER Id
Optional unique identifier for the action. If not specified, an empty string is used.
.EXAMPLE
# Create a simple approval action
$approveAction = New-AMExecuteAction -Title "Approve" -Verb "POST" `
-Url "https://api.example.com/approve" `
-Body '{"requestId": "12345", "status": "approved"}'
.EXAMPLE
# Create an action with dynamic user data
$rejectAction = New-AMExecuteAction -Title "Reject" -Verb "POST" `
-Url "https://api.contoso.com/api/requests/reject" `
-Body '{"requestId": "ABC123", "rejectedBy": "{{userEmail}}", "timestamp": "{{utcNow}}"}'
.EXAMPLE
# Create an action with a PowerShell object as data
$data = @{
requestId = "REQ-789"
action = "complete"
comments = "Task completed successfully"
}
$completeAction = New-AMExecuteAction -Title "Mark Complete" -Verb "POST" `
-Url "https://tasks.example.org/api/complete" `
-Data $data
.INPUTS
None. You cannot pipe input to New-AMExecuteAction.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the Action.Http element.
.NOTES
In Actionable Messages, the correct action type is "Action.Http", not "Action.Execute".
Action.Http is used for making HTTP requests when the action is triggered.
For security reasons, the target URL must be registered with the Actionable Email Developer Dashboard
and associated with your Originator ID before it can be used in production environments.
.LINK
https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#actions
#>
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)]
[string]$Title,
[Parameter(Mandatory = $true)]
[string]$Verb,
[Parameter()]
[string]$Url,
[Parameter()]
[string]$Body,
[Parameter()]
[object]$Data,
[Parameter()]
[string]$Id
)
# Create the basic action object - Note type is Action.Http not Action.Execute for ActionableMessages
$action = [ordered]@{
'type' = 'Action.Http'
'title' = $Title
'method' = $Verb  # 'method' is the correct property name, not 'verb'
}
# Add optional properties
if ($Url) { $action.url = $Url }
if ($Body) { $action.body = $Body }
if ($Data) { $action.data = $Data }
if ($Id) { $action.id = $Id }
else { $action.id = "" }  # Empty ID to match the desired output
return $action

``r

## DESCRIPTION
Creates an Action.Http element that makes an HTTP request when the action button is clicked.
This action is used in Outlook Actionable Messages to trigger server-side operations like
approving requests, submitting data, or any other operation requiring a backend API call.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple approval action
$approveAction = New-AMExecuteAction -Title "Approve" -Verb "POST" `
    -Url "https://api.example.com/approve" `
    -Body '{"requestId": "12345", "status": "approved"}'
``r

    

### EXAMPLE 2
`powershell
# Create an action with dynamic user data
$rejectAction = New-AMExecuteAction -Title "Reject" -Verb "POST" `
    -Url "https://api.contoso.com/api/requests/reject" `
    -Body '{"requestId": "ABC123", "rejectedBy": "{{userEmail}}", "timestamp": "{{utcNow}}"}'
``r

    

### EXAMPLE 3
`powershell
# Create an action with a PowerShell object as data
$data = @{
    requestId = "REQ-789"
    action = "complete"
    comments = "Task completed successfully"
}
$completeAction = New-AMExecuteAction -Title "Mark Complete" -Verb "POST" `
    -Url "https://tasks.example.org/api/complete" `
    -Data $data
``r

    

## PARAMETERS

### -Debug


`yaml
Type: Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -ErrorAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -ErrorVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -InformationAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -InformationVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -OutBuffer


`yaml
Type: Int32
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -OutVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -PipelineVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -ProgressAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Verbose


`yaml
Type: Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -WarningAction


`yaml
Type: Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -WarningVariable


`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: -2147483648
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Title
The text to display on the action button.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Verb
The HTTP verb/method to use for the request (e.g., "POST", "GET", "PUT", "DELETE").

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Url
The URL endpoint that will receive the HTTP request when the button is clicked.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Body
Optional JSON string containing the payload to send with the request.
You can include user-specific tokens like {{userEmail}} that will be replaced at runtime.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Data
Optional data object (hashtable) to include with the request. This is an alternative to Body
for when you want to specify the data as a PowerShell object rather than a JSON string.

`yaml
Type: Object
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### -Id
Optional unique identifier for the action. If not specified, an empty string is used.

`yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
``r

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMExecuteAction.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Action.Http element.


## NOTES
In Actionable Messages, the correct action type is "Action.Http", not "Action.Execute".
Action.Http is used for making HTTP requests when the action is triggered.

For security reasons, the target URL must be registered with the Actionable Email Developer Dashboard
and associated with your Originator ID before it can be used in production environments.

## RELATED LINKS
[](https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#actions)

