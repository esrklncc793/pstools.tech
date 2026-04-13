---
title: "Poshstache"
date: 2024-01-01
summary: "A PowerShell implementation of Mustache templates — render dynamic content from simple templates using hashtables and objects."
icon: "🧩"
version: "0.1.10"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2021-02-04"
github_url: "https://github.com/baldator/poshstache"
github_stars: 35
gallery_url: "https://www.powershellgallery.com/packages/Poshstache/"
issues_url: "https://github.com/baldator/poshstache/issues"
changelog_url: "https://github.com/baldator/poshstache/blob/master/CHANGELOG.md"
install_cmd: "Install-Module -Name Poshstache"
downloads: "179,584"
color: "#0f3460"
tags: ["templates", "mustache", "string", "rendering", "configuration"]
weight: 1
---

## Overview

**Poshstache** is a PowerShell module that implements the [Mustache](https://mustache.github.io/) logic-less template specification. It lets you render dynamic text content from simple `.mustache` (or any text) templates using PowerShell hashtables or objects.

Use Poshstache anywhere you need dynamic text generation: configuration files, HTML emails, deployment scripts, documentation, and more.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Poshstache/):

```powershell
# Install for current user
Install-Module -Name Poshstache -Scope CurrentUser

# Install system-wide (requires elevation)
Install-Module -Name Poshstache

# Import after installation
Import-Module Poshstache
```

---

## Quick Start

### Basic Template Rendering

```powershell
Import-Module Poshstache

# Define a template string
$template = "Hello, {{name}}! You have {{count}} new messages."

# Provide data as a hashtable
$data = @{
    name  = "Alice"
    count = 5
}

# Render the template
$result = ConvertTo-PoshstacheTemplate -InputString $template -ParametersObject ($data | ConvertTo-Json)
# Output: "Hello, Alice! You have 5 new messages."
Write-Host $result
```

### Rendering from a File

```powershell
# template.mustache
# Dear {{recipient}},
# Your order #{{order_id}} has been {{status}}.

$data = @{
    recipient = "Bob Smith"
    order_id  = "ORD-9821"
    status    = "shipped"
} | ConvertTo-Json

$result = ConvertTo-PoshstacheTemplate -InputFile "template.mustache" -ParametersObject $data
Write-Output $result
```

---

## Commands

### `ConvertTo-PoshstacheTemplate`

Renders a Mustache template with the provided parameters.

| Parameter | Type | Description |
|-----------|------|-------------|
| `-InputString` | `string` | Template content as a string |
| `-InputFile` | `string` | Path to a template file |
| `-ParametersObject` | `string` | JSON string with template variables |

---

## Template Syntax

| Syntax | Description |
|--------|-------------|
| `{{variable}}` | Renders the value of `variable` (HTML-escaped) |
| `{{{variable}}}` | Renders the value unescaped |
| `{{#section}}...{{/section}}` | Conditional/loop block |
| `{{^section}}...{{/section}}` | Inverted conditional (renders when falsy) |
| `{{! comment }}` | Comment (not rendered) |
| `{{> partial}}` | Partial template |

---

## Advanced Examples

### Lists and Loops

```powershell
$template = @"
Shopping list:
{{#items}}
- {{name}} ({{quantity}})
{{/items}}
"@

$data = @{
    items = @(
        @{ name = "Apples"; quantity = "6" }
        @{ name = "Bread";  quantity = "1 loaf" }
        @{ name = "Milk";   quantity = "2 liters" }
    )
} | ConvertTo-Json -Depth 5

$result = ConvertTo-PoshstacheTemplate -InputString $template -ParametersObject $data
```

### Config File Generation

```powershell
# appsettings.mustache
# {
#   "ConnectionString": "{{db_server}}/{{db_name}}",
#   "Environment": "{{env}}",
#   "LogLevel": "{{log_level}}"
# }

$config = @{
    db_server = "prod-sql.company.com"
    db_name   = "AppDatabase"
    env       = "Production"
    log_level = "Warning"
} | ConvertTo-Json

ConvertTo-PoshstacheTemplate -InputFile "appsettings.mustache" -ParametersObject $config |
    Out-File "appsettings.json" -Encoding utf8
```

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/poshstache) for details.

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## License

Poshstache is released under the [MIT License](https://github.com/baldator/poshstache/blob/master/LICENSE).
