---
title: msgraphProxy 1.1.1 released
authors: mynster
date: 2026-10-10
tags: [powershell, release, msgraphproxy]
description: msgraphProxy 1.1.1 is now available on the PowerShell Gallery.
---

msgraphProxy 1.1.1 is now available on the PowerShell Gallery.

<!-- truncate -->

## What's new

https://github.com/Mynster9361/msgraphProxy/blob/main/changelog.md

Fixed the minimal permissions graph recording as a change from Microsoft backend changed late June.

Updated the backend devproxy to correspond with the latest release from devproxy

The devproxy backend now expects a token for communication that has been added to the module so it can get ready status and shut the proxy down properly

```powershell
Install-Module -Name msgraphProxy -Scope CurrentUser -Force
```

See the [module docs](/docs/modules/msgraphproxy) and [command reference](/docs/modules/msgraphproxy/commands) for details, or [view it on the PowerShell Gallery](https://www.powershellgallery.com/packages/msgraphProxy/1.1.1).
