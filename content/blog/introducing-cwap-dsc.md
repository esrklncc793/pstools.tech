---
title: "Introducing cWAP: DSC Resources for Web Application Proxy"
date: 2026-03-21
author: "baldator"
tags: ["dsc", "wap", "adfs", "infrastructure-as-code", "powershell"]
modules: ["cWAP"]
summary: "Manage Windows Server Web Application Proxy declaratively with DSC. cWAP provides resources to configure WAP and publish applications in a repeatable, idempotent way."
---

If you run **Web Application Proxy (WAP)** in production, you already know the pain points: manual setup steps, environment drift, and fragile runbooks that break during upgrades. **cWAP** addresses that with a simple goal: make WAP configuration declarative using PowerShell Desired State Configuration (DSC).

## What cWAP Solves

The module provides DSC resources to describe both core WAP setup and application publishing as code:

- `cWAPConfiguration` for server-level WAP and federation settings
- `cWAPWebsite` for published application entries

This means your WAP state can be versioned, reviewed, and applied repeatedly in dev, test, and production with consistent outcomes.

## Installation

```powershell
Install-Module -Name cWAP -Scope CurrentUser
Import-Module cWAP
```

## Declarative WAP Configuration

With cWAP, you define desired settings once and let DSC enforce them.

```powershell
Configuration WapBaseline {
    param(
        [PSCredential]$FederationCredential,
        [string]$FederationServiceName,
        [string]$CertificateThumbprint
    )

    Import-DscResource -ModuleName cWAP

    Node localhost {
        cWAPConfiguration WapConfig {
            Ensure                = "Present"
            FederationServiceName = $FederationServiceName
            Credential            = $FederationCredential
            CertificateThumbprint = $CertificateThumbprint
            HttpsPort             = 443
            TlsClientPort         = 49443
        }
    }
}
```

Instead of documenting this setup in a wiki page, you keep it in source control and apply it reliably through automation.

## Publish Applications as Code

Publishing apps behind WAP is often where inconsistency shows up. cWAP lets you define each app explicitly:

```powershell
Configuration PublishContosoApp {
    param(
        [string]$CertificateThumbprint
    )

    Import-DscResource -ModuleName cWAP

    Node localhost {
        cWAPWebsite ContosoPortal {
            Ensure                        = "Present"
            ApplicationName               = "Contoso Portal"
            BackendServerUrl              = "https://contoso-app.internal"
            ExternalCertificateThumbprint = $CertificateThumbprint
            ExternalUrl                   = "https://portal.contoso.com"
            ExternalPreauthentication     = "ADFS"
        }
    }
}
```

This gives you repeatable app publication and safer change management, especially across multiple WAP nodes.

## Why This Matters

cWAP is especially useful when you need:

- Predictable WAP builds for new environments
- Drift correction for long-lived servers
- Auditable infrastructure changes through pull requests
- Reusable blueprints for application publication

## Tip: Combine with CI/CD

Treat your DSC configurations as deployable artifacts. Validate them in pre-production first, then apply the same configuration in production. cWAP works best when it is part of a controlled release flow.

## Get Started

If your WAP configuration still depends on manual scripts and one-off steps, cWAP is a straightforward upgrade path toward infrastructure-as-code.

```powershell
Install-Module -Name cWAP
```

See the full docs on the [cWAP module page](/modules/cwap/) and source on [GitHub](https://github.com/baldator/cWAP).
