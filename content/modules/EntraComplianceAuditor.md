---
title: "EntraComplianceAuditor"
date: 2026-04-16
summary: "Audit Microsoft Entra tenant configuration against compliance baselines from PowerShell."
icon: "🛡️"
version: "1.0.0"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-04-16"
github_url: "https://github.com/baldator/EntraComplianceAuditor"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/EntraComplianceAuditor/"
issues_url: "https://github.com/baldator/EntraComplianceAuditor/issues"
changelog_url: "https://github.com/baldator/EntraComplianceAuditor/releases"
install_cmd: "Install-Module -Name EntraComplianceAuditor"
downloads: "414"
color: "#0f3460"
tags: ["entra", "azure-ad", "compliance", "audit", "security", "microsoft-365"]
weight: 10
---

## Overview

**EntraComplianceAuditor** helps you assess Microsoft Entra configuration against security and compliance expectations. It is intended for administrators who want repeatable checks they can run from PowerShell in local workflows or CI/CD pipelines.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/EntraComplianceAuditor/):

```powershell
# Install for current user
Install-Module -Name EntraComplianceAuditor -Scope CurrentUser

# Import
Import-Module EntraComplianceAuditor
```

---

## Quick Start

```powershell
Import-Module EntraComplianceAuditor

# Discover available commands
Get-Command -Module EntraComplianceAuditor

# Read command help with examples
Get-Help -Name (Get-Command -Module EntraComplianceAuditor | Select-Object -First 1).Name -Detailed
```

---

## Typical Usage Pattern

1. Connect to your Microsoft Entra environment.
2. Run the module's audit commands for your tenant.
3. Review findings and recommended actions.
4. Track improvements by repeating checks regularly.

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/EntraComplianceAuditor) for details.

---

## License

EntraComplianceAuditor is released under the [MIT License](https://github.com/baldator/EntraComplianceAuditor/blob/main/LICENSE).
