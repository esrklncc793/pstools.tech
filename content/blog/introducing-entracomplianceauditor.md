---
title: "Introducing EntraComplianceAuditor: Compliance Auditing for Microsoft Entra"
date: 2026-04-16
author: "baldator"
tags: ["entra", "azure-ad", "compliance", "audit", "security", "powershell"]
modules: ["EntraComplianceAuditor"]
summary: "EntraComplianceAuditor helps you run repeatable Microsoft Entra compliance checks from PowerShell and turn findings into actionable remediation work."
---

Keeping Microsoft Entra secure is not a one-time task. New policies, role assignments, app registrations, and tenant settings appear over time, and each change can affect your compliance posture. **EntraComplianceAuditor** is built to make those checks repeatable and scriptable.

## Why this module

Many teams still validate Entra settings manually in the portal. That is slow, hard to standardize, and difficult to run regularly. EntraComplianceAuditor gives you a PowerShell-first approach so checks can be repeated consistently and included in operational workflows.

## Installation

```powershell
Install-Module -Name EntraComplianceAuditor -Scope CurrentUser
Import-Module EntraComplianceAuditor
```

## Get started in minutes

Start by discovering what commands are available in your installed version:

```powershell
Import-Module EntraComplianceAuditor
Get-Command -Module EntraComplianceAuditor
```

Then inspect built-in help to understand parameters and examples:

```powershell
Get-Help -Name (Get-Command -Module EntraComplianceAuditor | Select-Object -First 1).Name -Detailed
```

## A practical workflow

1. Run checks against your Entra tenant.
2. Export or review findings.
3. Prioritize remediation items by risk.
4. Re-run audits on a schedule to confirm drift has been addressed.

This process helps security and platform teams move from ad-hoc reviews to continuous verification.

## Conclusion

If you manage Microsoft Entra and want dependable compliance visibility from the command line, EntraComplianceAuditor is a strong addition to your toolkit.

```powershell
Install-Module -Name EntraComplianceAuditor -Scope CurrentUser
```

See the full documentation on the [EntraComplianceAuditor module page](/modules/entracomplianceauditor/) and source code on [GitHub](https://github.com/baldator/EntraComplianceAuditor).
