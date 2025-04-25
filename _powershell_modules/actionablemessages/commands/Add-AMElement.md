---
layout: page
title: Add-AMElement
permalink: /modules/actionablemessages/commands/Add-AMElement/
---

# Add-AMElement

## SYNOPSIS
Adds an element to an Adaptive Card.

## SYNTAX

```powershell
Add-AMElement [-Card] <Hashtable> [-Element] <Hashtable> [-ContainerId <String>] [-ColumnId <String>] [-Verbose <SwitchParameter>] [-Debug <SwitchParameter>] [-ErrorAction <ActionPreference>] [-WarningAction <ActionPreference>] [-InformationAction <ActionPreference>] [-ProgressAction <ActionPreference>] [-ErrorVariable <String>] [-WarningVariable <String>] [-InformationVariable <String>] [-OutVariable <String>] [-OutBuffer <Int32>] [-PipelineVariable <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Add-AMElement` function adds an element to an Adaptive Card. The element can be added directly
to the card body or to a specific container within the card. This function modifies the card in-place,
so there is no need to reassign the result.

The function supports adding elements to:
- The main card body
- Inside a container (by specifying `ContainerId`)
- Inside a specific column in a ColumnSet (future functionality)

If the card body does not exist, it will be created automatically. However, containers must already
exist when referencing them by `ContainerId`.

## EXAMPLES

### EXAMPLE 1
```powershell
# Add a text block directly to the card body
$title = New-AMTextBlock -Text "Hello World" -Size "Large" -Weight "Bolder"
Add-AMElement -Card $card -Element $title
```


### EXAMPLE 2
```powershell
# Add a text block to a container
$text = New-AMTextBlock -Text "This text is inside a container" -Wrap $true
Add-AMElement -Card $card -Element $text -ContainerId "details-container"
```


### EXAMPLE 3
```powershell
# Create a container and add multiple elements to it
$container = New-AMContainer -Id "info-section" -Style "emphasis"
Add-AMElement -Card $card -Element $container
```

#### Example explanation
```powershell
# Now add elements to the container
$header = New-AMTextBlock -Text "Important Information" -Size "Medium" -Weight "Bolder"
Add-AMElement -Card $card -Element $header -ContainerId "info-section"

$content = New-AMTextBlock -Text "Here are the details you requested..." -Wrap $true
Add-AMElement -Card $card -Element $content -ContainerId "info-section"

$factSet = New-AMFactSet -Facts @(
    (New-AMFact -Title "Status" -Value "Active"),
    (New-AMFact -Title "Priority" -Value "High")
)
Add-AMElement -Card $card -Element $factSet -ContainerId "info-section"
```

### EXAMPLE 4
```powershell
# Add an image to the card body
$image = New-AMImage -Url "https://example.com/image.png" -AltText "Example Image"
Add-AMElement -Card $card -Element $image
```

## PARAMETERS

### -ColumnId
(Optional) The ID of a column within a container to add the element to. Only applicable
when `ContainerId` is also specified. (Future functionality)

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

### -ContainerId
(Optional) The ID of a container to add the element to. If specified, the element
will be added to the container's `items` collection rather than directly to the card body.

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

### -Card
The Adaptive Card hashtable to which the element will be added.

```yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Element
The element to add to the card. This should be a hashtable created by one of the
`New-AM*` functions such as `New-AMTextBlock`, `New-AMImage`, `New-AMContainer`, etc.

```yaml
Type: Collections.Hashtable
Parameter Sets: (All)
Aliases: None

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## INPUTS
### System.Collections.Hashtable
The `Card` and `Element` parameters must be hashtables.

## OUTPUTS
### None. The function modifies the card directly.

## NOTES
- This function modifies the card directly. It uses `ArrayList` operations to ensure
  changes are reflected in the original card variable.
- When adding elements to containers, ensure the container exists and has the
  correct ID; otherwise, an error will be thrown.
- The function automatically creates the `body` array if it doesn't exist, but it
  expects containers to already be present when referencing them by `ContainerId`.

## RELATED LINKS
- [https://adaptivecards.io/explorer/](https://adaptivecards.io/explorer/)
