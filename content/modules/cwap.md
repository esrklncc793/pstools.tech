---
title: "cWAP"
date: 2026-03-21
summary: "DSC resources for managing Windows Server Web Application Proxy (WAP) and publishing applications with declarative PowerShell configurations."
icon: "🛡️"
version: "0.4.0"
author: "Marco Torello"
license: "MIT"
powershell_version: "5.0"
last_updated: "2026-04-17"
github_url: "https://github.com/baldator/cWAP"
github_stars: 3
gallery_url: "https://www.powershellgallery.com/packages/cWAP/"
issues_url: "https://github.com/baldator/cWAP/issues"
changelog_url: "https://github.com/baldator/cWAP/releases"
install_cmd: "Install-Module -Name cWAP"
downloads: "1,031"
color: "#133b5c"
tags: ["dsc", "wap", "web-application-proxy", "adfs", "infrastructure-as-code"]
weight: 8
---

## Overview

**cWAP** is a PowerShell DSC module for configuring and managing **Windows Server Web Application Proxy (WAP)**.
It lets you describe WAP setup and published applications declaratively, then enforce that desired state consistently across environments.

The module exports two DSC resources:

- `cWAPConfiguration` for WAP server and federation settings
- `cWAPWebsite` for published application definitions

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/cWAP/):

```powershell
# Install for current user
Install-Module -Name cWAP -Scope CurrentUser

# Import
Import-Module cWAP
```

---

## Quick Start

Use cWAP in a DSC configuration to install and configure WAP, then publish applications.

```powershell
Configuration ConfigureWap {
    param(
        [PSCredential]$FederationCredential,
        [string]$FederationServiceName,
        [string]$CertificateThumbprint,
        [string]$ExternalUrl,
        [string]$BackendServerUrl
    )

    Import-DscResource -ModuleName cWAP

    Node localhost {
        cWAPConfiguration WapBaseConfig {
            Ensure                = "Present"
            FederationServiceName = $FederationServiceName
            Credential            = $FederationCredential
            CertificateThumbprint = $CertificateThumbprint
            HttpsPort             = 443
            TlsClientPort         = 49443
        }

        cWAPWebsite PublishedApp {
            Ensure                        = "Present"
            ApplicationName               = "Contoso App"
            BackendServerUrl              = $BackendServerUrl
            ExternalCertificateThumbprint = $CertificateThumbprint
            ExternalUrl                   = $ExternalUrl
            ExternalPreauthentication     = "ADFS"
            DependsOn                     = "[cWAPConfiguration]WapBaseConfig"
        }
    }
}
```

---

## DSC Resources

### `cWAPConfiguration`

Configures the Web Application Proxy role connection to ADFS and related WAP settings.

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `Ensure` | `Present/Absent` | No | Whether WAP configuration should exist |
| `FederationServiceName` | `string` | Yes (key) | ADFS service name (for example `adfs.contoso.com`) |
| `Credential` | `PSCredential` | Yes | Domain admin credential used to register WAP |
| `CertificateThumbprint` | `string` | Yes | Certificate thumbprint bound to the federation service |
| `ForwardProxy` | `string` | No | Optional outbound proxy in `FQDN:Port` format |
| `HttpsPort` | `int` | No | HTTPS listener port, default `443` |
| `TlsClientPort` | `int` | No | TLS client auth port, default `49443` |
| `ADFSTokenAcceptanceDurationSec` | `int` | No | Optional ADFS token acceptance duration |
| `UserIdleTimeoutSec` | `int` | No | Optional user idle timeout |
| `UserIdleTimeoutAction` | `string` | No | Idle timeout action, for example `Signout` |

### `cWAPWebsite`

Defines and maintains published applications behind WAP.

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `Ensure` | `Present/Absent` | Yes | Whether the published app should exist |
| `ApplicationName` | `string` | Yes | Display name for the WAP application |
| `BackendServerUrl` | `string` | Yes (key) | Internal URL of the backend application |
| `ExternalCertificateThumbprint` | `string` | Yes | External certificate thumbprint |
| `ExternalUrl` | `string` | Yes | Public URL for client access |
| `ExternalPreauthentication` | `string` | No | Pre-auth mode, defaults to `ADFS` |
| `ADFSRelyingPartyName` | `string` | No | Relying party name when using ADFS |
| `BackendServerAuthenticationMode` | `string` | No | Backend auth mode |
| `EnableHTTPRedirect` | `bool` | No | Enable HTTP to HTTPS redirect |

---

## Validation Helper

The module also exposes `Test-sslBinding`, a helper function used to validate certificate binding state.

```powershell
Import-Module cWAP

$ok = Test-sslBinding -port 443 -certificateThumbprint "0123456789ABCDEF0123456789ABCDEF01234567"
if ($ok) {
    Write-Host "SSL binding is configured correctly"
}
```

---

## When to Use cWAP

- You manage WAP infrastructure with DSC and want repeatable configuration.
- You need idempotent publishing of multiple ADFS pre-authenticated applications.
- You want WAP settings to be source-controlled and deployable through CI/CD.

---

## Contributing

Contributions are welcome. See the [GitHub repository](https://github.com/baldator/cWAP) for source, issues, and pull requests.

---

## License

cWAP is released under the [MIT License](https://github.com/baldator/cWAP/blob/master/LICENSE).
