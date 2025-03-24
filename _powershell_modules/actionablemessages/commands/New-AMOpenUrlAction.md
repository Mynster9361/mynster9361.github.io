---
layout: page
title: New-AMOpenUrlAction
permalink: /modules/actionablemessages/commands/New-AMOpenUrlAction/
---

# New-AMOpenUrlAction

## SYNOPSIS
Creates an OpenUrl Action for an Adaptive Card.

## SYNTAX

`powershell
<#
.SYNOPSIS
Creates an OpenUrl Action for an Adaptive Card.
.DESCRIPTION
Creates an Action.OpenUrl element that opens a URL in a web browser when clicked.
This action is commonly used to provide links to external resources, documentation,
or related web pages from within your Adaptive Card.
.PARAMETER Title
The title text to display on the action button.
.PARAMETER Url
The URL to open when the button is clicked. This must be a valid URL including
the protocol (e.g., "https://").
.PARAMETER Id
Optional unique identifier for the action. If not specified, a new GUID will be
generated automatically. The ID can be useful when you need to reference this
action programmatically.
.PARAMETER Tooltip
Optional tooltip text to display when the user hovers over the button.
Use this to provide additional context about what will happen when clicked.
.EXAMPLE
# Create a simple "Learn More" button
$learnMoreAction = New-AMOpenUrlAction -Title "Learn More" -Url "https://example.com"
Add-AMElement -Card $card -Element (New-AMActionSet -Actions @($learnMoreAction))
.EXAMPLE
# Create a button with custom ID and tooltip
$docsButton = New-AMOpenUrlAction -Title "View Documentation" `
-Url "https://docs.contoso.com/project" `
-Id "docs-button" `
-Tooltip "Open the project documentation in a new browser window"
.EXAMPLE
# Creating multiple URL actions in an ActionSet
$actions = @(
(New-AMOpenUrlAction -Title "Product Page" -Url "https://contoso.com/products"),
(New-AMOpenUrlAction -Title "Support" -Url "https://contoso.com/support")
)
$actionSet = New-AMActionSet -Id "links" -Actions $actions
.INPUTS
None. You cannot pipe input to New-AMOpenUrlAction.
.OUTPUTS
System.Collections.Hashtable
Returns a hashtable representing the Action.OpenUrl element.
.NOTES
Action.OpenUrl is one of the most commonly used action types in Adaptive Cards.
Unlike other action types, Action.OpenUrl doesn't require any special permissions
or registrations since it simply opens a URL in the user's browser.
In Outlook, the URL will typically open in the user's default web browser.
.LINK
https://adaptivecards.io/explorer/Action.OpenUrl.html
#>
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)]
[string]$Title,
[Parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[string]$Url,
[Parameter()]
[string]$Id = [guid]::NewGuid().ToString(),
[Parameter()]
[string]$Tooltip
)
$action = [ordered]@{
'type' = 'Action.OpenUrl'
'id' = $Id
'title' = $Title
'url' = $Url
}
if ($Tooltip) {
$action.tooltip = $Tooltip
}
return $action

``r

## DESCRIPTION
Creates an Action.OpenUrl element that opens a URL in a web browser when clicked.
This action is commonly used to provide links to external resources, documentation,
or related web pages from within your Adaptive Card.

## EXAMPLES

### EXAMPLE 1
`powershell
# Create a simple "Learn More" button
$learnMoreAction = New-AMOpenUrlAction -Title "Learn More" -Url "https://example.com"
Add-AMElement -Card $card -Element (New-AMActionSet -Actions @($learnMoreAction))
``r

    

### EXAMPLE 2
`powershell
# Create a button with custom ID and tooltip
$docsButton = New-AMOpenUrlAction -Title "View Documentation" `
    -Url "https://docs.contoso.com/project" `
    -Id "docs-button" `
    -Tooltip "Open the project documentation in a new browser window"
``r

    

### EXAMPLE 3
`powershell
# Creating multiple URL actions in an ActionSet
$actions = @(
    (New-AMOpenUrlAction -Title "Product Page" -Url "https://contoso.com/products"),
    (New-AMOpenUrlAction -Title "Support" -Url "https://contoso.com/support")
)
$actionSet = New-AMActionSet -Id "links" -Actions $actions
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
The title text to display on the action button.

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

### -Url
The URL to open when the button is clicked. This must be a valid URL including
the protocol (e.g., "https://").

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

### -Id
Optional unique identifier for the action. If not specified, a new GUID will be
generated automatically. The ID can be useful when you need to reference this
action programmatically.

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

### -Tooltip
Optional tooltip text to display when the user hovers over the button.
Use this to provide additional context about what will happen when clicked.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### None. You cannot pipe input to New-AMOpenUrlAction.


## OUTPUTS
### System.Collections.Hashtable
Returns a hashtable representing the Action.OpenUrl element.


## NOTES
Action.OpenUrl is one of the most commonly used action types in Adaptive Cards.
Unlike other action types, Action.OpenUrl doesn't require any special permissions
or registrations since it simply opens a URL in the user's browser.

In Outlook, the URL will typically open in the user's default web browser.

## RELATED LINKS
[](https://adaptivecards.io/explorer/Action.OpenUrl.html)

