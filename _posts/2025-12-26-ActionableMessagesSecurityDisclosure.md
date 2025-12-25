---
title: Security Disclosure - Secrets Exposure in Microsoft Actionable Messages Admin Portal
author: mynster
date: 2025-12-26 10:00:00 +0100
categories: [Security]
tags: [security, disclosure, adaptive cards, actionable messages]
description: Secrets exposure vulnerability in the Microsoft Actionable Messages admin portal
---

## Background

While developing a PowerShell module to enable sending Actionable Messages from PowerShell to Outlook, I discovered a significant information exposure issue in the Microsoft Actionable Messages admin portal. This post details the journey from initial discovery through disclosure to resolution.

## The Discovery

To send Actionable Messages, developers must register on the [Actionable Email Developer Dashboard](https://outlook.office.com/connectors/oam/publish){:target="_blank"}. Organizations can choose between two approval scopes:
- **Organization**: Requires approval from the organization's Exchange administrator
- **Global**: Requires approval from Microsoft

### The Vulnerability

The issue was found in the admin portal where administrators could search for Microsoft-approved providers:

[Actionable Email Developer Dashboard Admin site](https://outlook.office.com/connectors/oam/Admin?SearchProviderStatus=ApprovedbyMicrosoft&SearchKeyword=){:target="_blank"}

Any user with **Global Administrator** or **Exchange Administrator** permissions could view detailed information about all approved providers *Note that anyone could register their own tenant give themself the permission and see this.*, including:

- Friendly Name
- Provider ID (originator)
- Organization information (including Tenant ID)
- Email address of submitter (partially masked)
- Sender email address
- **Target URLs** (including full query parameters)
- Scope of submission
- Audit history

## The Problem

While most of this information is reasonable for administrators to see, the critical issue was the **Target URLs** field. This field exposed complete URLs including query parameters that often contained secrets such as API keys, SAS tokens, and signature values:

### Example: Logic App Credentials Exposed
```
Friendly Name: TimesheetsApproval
Provider Id: cd8aac59-1e1e-48f9-a9fc-5db88acf31d7
Target URL: https://prod-132.westeurope.logic.azure.com:443/workflows/
  cc2d84593b344d10bcf06fdfc24f28d8/triggers/manual/paths/invoke?
  api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&
  sig=A_SUPER_SECRET_KEY_WAS_WRITTEN_HERE
```

*The above is one example there were multiple available be it internally developed apps with secrets in the url or other Microsoft services other than logic apps*

The exposed signature keys (`sig` parameter) allowed anyone to:
- Send POST requests to these Logic Apps
- Potentially run up costs for the affected organizations
- Inject malicious payloads depending on Logic App implementation
- Trigger unintended workflows

Before 23.rd december:
![Full target url with exposed sig key](/assets/img/posts/2025-12-26-ActionableMessagesSecurityDisclosure-timesheetapproval.png)


After 23.rd december:
![Remediated only showing the host uri](/assets/img/posts/2025-12-26-ActionableMessagesSecurityDisclosure-timesheetapprovalAfter.png)

## Attack Vectors

The exposed secrets in target URLs enabled several attack vectors be it that some is more unlikely than others:

### 1. Cost Amplification
Attackers could repeatedly trigger Logic Apps to generate unexpected Azure costs for the affected organizations.

### 2. Workflow Manipulation
Depending on Logic App implementation, attackers could inject data that would be processed, potentially causing:
- Unauthorized actions
- Data manipulation
- Service disruptions

### 3. Unauthorized Access
Any service using secrets in the target URL could be accessed by anyone with administrator permissions in any Microsoft 365 tenant, bypassing intended access controls.

## Disclosure Timeline

### August 6, 2025 - Initial Report to MSRC
Submitted detailed report to Microsoft Security Response Center (MSRC) including:
- Description of the vulnerability
- Screenshot evidence
- Potential impact assessment
- List of affected providers

**MSRC Case: 100332**

### August 7, 2025 - Case Opened
MSRC acknowledged the report and opened an investigation.

### August 26, 2025 - MSRC Assessment
MSRC concluded:
"We consider this a moderate severity as there is a fairly limited attack scope and appears to be more of a privacy issue than a security issue."

The team forwarded the report to the product group for consideration of a future fix.

### August 27, 2025 - Disclosure Discussion
I inquired whether affected customers would be notified. *I never received an answer to this question*
MSRC confirmed I was free to disclose publicly and requested a draft for review.

### September 12, 2025 - Draft Submission
Submitted draft blog post and LinkedIn post with proposed disclosure date of September 23, 2025.

### September 23, 2025 - Postponement
After not receiving feedback, I postponed publication to allow MSRC additional review time.

### October 28, 2025 - Support Case Opened
Opened Microsoft support case **TrackingID#2510281420002121** to follow up on remediation efforts.

### October 30, 2025 - Product Team Engagement
Support engineer @Microsoft escalated the issue to **onboardoam@microsoft.com** (OAM Partner Onboarding Support team).

### November-December 2025 - Implementation
The OAM team developed and tested a fix through Microsoft's internal rings.

### December 10, 2025 - Fix Announced
Microsoft confirmed the fix was ready:
"We now only display the host URI of the target URL to the admins."

### December 23, 2025 - Rollout Complete
The fix was deployed to all customers. The admin portal now shows only the host portion of URLs:

```
Before: https://prod-132.westeurope.logic.azure.com:443/workflows/...?sig=SECRET
After:  https://prod-132.westeurope.logic.azure.com
```

## Impact Assessment

### Organizations Affected
- All organizations that registered global-scoped Actionable Message providers
- Specifically those using Logic apps, Powerapps, Webhooks or other services with API keys in URLs
- Organizations included Microsoft's internal teams and third-party partners

### Data Exposed
The primary concern was credentials embedded in target URLs:
- Logic App signature keys (SAS tokens)
- API keys and secrets in query parameters
- Complete endpoint URLs revealing internal architecture

While other information like organization names and sender emails were also visible, these were considered less sensitive as they served the legitimate purpose of helping administrators identify approved providers.

### Exposure Window
The vulnerability was present from an unknown date until December 23, 2025. The admin portal was accessible to any user with Global or Exchange Administrator permissions in any Microsoft 365 tenant.

## Key Takeaways

### For Developers
1. **Never include secrets in URLs**: Use authentication headers or POST body parameters
2. **Rotate exposed credentials**: If you submitted a provider with secrets in the URL, get in contact with the OAM team and rotate them as soon as possible *I heard in my case that it can take up to 14 days to get them rotated with them.*
3. **Review approval submissions**: Check what information is visible to administrators

### For Microsoft - My personal opinion
1. **Input validation**: The submission form should reject or warn when URLs contain common secret patterns (sig=, key=, token=, etc.)
2. **Customer notification**: Organizations with exposed credentials should have been proactively notified
3. **Documentation**: Submission guidelines should explicitly warn against including secrets in URLs and recommend authentication headers instead
4. **Display filtering**: Even if secrets are submitted, the admin portal should automatically redact query parameters

## Questions That Remain

### Customer Notification
Microsoft has not confirmed whether affected organizations were notified about the exposure. Organizations should proactively:
1. Review their Actionable Message provider submissions
2. Rotate any credentials that may have been exposed in collaboration with the OAM team.
3. Review Logic App or other apps exposed through actionable messages for unexpected traffic patterns

### Exposure Duration
The timeline of when this vulnerability was introduced remains unclear. Organizations should consider credentials potentially exposed since submission date.

## Recommendations

### For Affected Organizations

Get in contact with the OAM team **onboardoam@microsoft.com** and agree with them when, what, where you should rotate your secrets.


## Timeline Summary

| Date         | Event                            |
| ------------ | -------------------------------- |
| Aug 6, 2025  | Initial MSRC report submitted    |
| Aug 26, 2025 | MSRC classified as privacy issue |
| Aug 28, 2025 | Approved for public disclosure   |
| Oct 28, 2025 | Support case opened              |
| Oct 30, 2025 | Escalated to OAM team            |
| Dec 10, 2025 | Fix announced                    |
| Dec 23, 2025 | Fix deployed globally            |
| Dec 26, 2025 | Public disclosure                |

---


