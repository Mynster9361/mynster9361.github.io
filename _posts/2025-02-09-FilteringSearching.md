---
title: Filtering/searching/AdvancedFiltering in MSGRAPH
author: <1>
date: 2026-02-09 14:00:00 +0100
categories: [Microsoft Graph, Filter]
tags: [powershell, msgraph, speaker]
description: Demonstrating how to use $filter, $search and advanced filters
---

# Prerequisites
- Token for msgraph
- Permissions on the endpoint you are using

## Understanding the options for filtering

- Reference: <br>
[https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#operators-and-functions-supported-in-filter-expressions](https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#operators-and-functions-supported-in-filter-expressions){:target="_blank"}

<table aria-label="Table 1" class="table-wrapper">
  <thead>
    <tr>
      <th>Operator type</th>
      <th>Operator</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Equality operators</td>
      <td>
        <ul>
          <li>Equals (eq)</li>
          <li>Not equals (ne)</li>
          <li>Logical negation (not)</li>
          <li>In (in)</li>
          <li>Has (has)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Relational operators</td>
      <td>
        <ul>
          <li>Less than (lt)</li>
          <li>Greater than (gt)</li>
          <li>Less than or equal to (le)</li>
          <li>Greater than or equal to (ge)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Lambda operators</td>
      <td>
        <ul>
          <li>Any (any)</li>
          <li>All (all)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Conditional operators</td>
      <td>
        <ul>
          <li>And (and)</li>
          <li>Or (or)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Functions</td>
      <td>
        <ul>
          <li>Starts with (startswith)</li>
          <li>Ends with (endswith)</li>
          <li>Contains (contains)</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>


Right as shown in the table we have quite a few operators available for us and just to give an example of each endpoint that could be hit you can use the below to have a look with an explanation for each one:

### Equality operators

#### Equals (eq)

```powershell

```

#### Not equals (ne)

```powershell

```

#### Logical negation (not)

```powershell

```

#### In (in)

```powershell

```

#### Has (has)

```powershell

```

### Relational operators

#### Less than (lt)

```powershell

```

#### Greater than (gt)

```powershell

```

#### Less than or equal to (le)

```powershell

```

#### Greater than or equal to (ge)

```powershell

```

### Lambda operators

#### Any (any)

```powershell

```

#### All (all)

```powershell

```

### Conditional operators

#### And (and)

```powershell

```

#### Or (or)

```powershell

```

### Functions

#### Starts with (startswith)

```powershell

```

#### Ends with (endswith)

```powershell

```

#### Contains (contains)

```powershell

```


## Reference/Documentation links

- Filtering: [https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http](https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http)
- Searching: [https://learn.microsoft.com/en-us/graph/search-query-parameter?tabs=http](https://learn.microsoft.com/en-us/graph/search-query-parameter?tabs=http)
- Advanced Filtering: [https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http](https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http)

