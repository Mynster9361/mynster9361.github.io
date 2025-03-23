---
external help file: ActionableMessages-help.xml
Module Name: ActionableMessages
online version: https://adaptivecards.io/explorer/ColumnSet.html
schema: 2.0.0
---

# New-AMColumnSet

## SYNOPSIS
Creates a ColumnSet element for an Adaptive Card.

## SYNTAX

```
New-AMColumnSet [-Id] <String> [-Columns] <Array> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates a ColumnSet element that allows you to arrange content in multiple columns.
ColumnSets are one of the primary layout elements in Adaptive Cards and enable
side-by-side content arrangement.

A ColumnSet contains one or more Column objects, each created with the New-AMColumn
function.
Each column can contain its own set of elements (text, images, etc.).

## EXAMPLES

### EXAMPLE 1
```
# Create a simple two-column layout
$leftColumn = New-AMColumn -Width "1" -Items @(
    (New-AMTextBlock -Text "Left Column Content" -Wrap $true)
)
```

$rightColumn = New-AMColumn -Width "1" -Items @(
    (New-AMTextBlock -Text "Right Column Content" -Wrap $true)
)

$columnSet = New-AMColumnSet -Id "two-column-layout" -Columns @($leftColumn, $rightColumn)
Add-AMElement -Card $card -Element $columnSet

### EXAMPLE 2
```
# Create a profile card with image and info
$imageColumn = New-AMColumn -Width "auto" -Items @(
    (New-AMImage -Url "https://example.com/profile.jpg" -Size "Small")
)
```

$infoColumn = New-AMColumn -Width "stretch" -Items @(
    (New-AMTextBlock -Text "Jane Smith" -Size "Medium" -Weight "Bolder"),
    (New-AMTextBlock -Text "Senior Engineer" -Spacing "None"),
    (New-AMTextBlock -Text "Department: R&D" -Spacing "Small")
)

$profileLayout = New-AMColumnSet -Id "profile-card" -Columns @($imageColumn, $infoColumn)
Add-AMElement -Card $card -Element $profileLayout

### EXAMPLE 3
```
# Create a three-column layout with different widths
$col1 = New-AMColumn -Width "2" -Items @(
    (New-AMTextBlock -Text "Column 1 (Width 2)")
)
```

$col2 = New-AMColumn -Width "1" -Items @(
    (New-AMTextBlock -Text "Column 2 (Width 1)")
)

$col3 = New-AMColumn -Width "1" -Items @(
    (New-AMTextBlock -Text "Column 3 (Width 1)")
)

$threeColumnLayout = New-AMColumnSet -Id "proportional-columns" -Columns @($col1, $col2, $col3)
Add-AMElement -Card $card -Element $threeColumnLayout

## PARAMETERS

### -Id
A unique identifier for the ColumnSet.
This ID can be used to reference the ColumnSet
when adding elements to it, or when targeting it with visibility toggle actions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Columns
An array of Column objects created using the New-AMColumn function.
These columns
will be displayed side-by-side within the ColumnSet.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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

### None. You cannot pipe input to New-AMColumnSet.
## OUTPUTS

### System.Collections.Hashtable
### Returns a hashtable representing the ColumnSet element.
## NOTES
ColumnSets are powerful layout tools in Adaptive Cards.
Some key points:

- You can create responsive layouts by using proportional widths ("1", "2", etc.)
- Use "auto" width for columns that should be sized to their content
- Use "stretch" width for columns that should fill remaining space
- Each column can have its own vertical alignment

The resulting ColumnSet can be added directly to a card body or to another
container element using Add-AMElement.

## RELATED LINKS

[https://adaptivecards.io/explorer/ColumnSet.html](https://adaptivecards.io/explorer/ColumnSet.html)

