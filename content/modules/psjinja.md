---
title: "PSJinja"
date: 2024-01-07
summary: "A PowerShell module that brings Jinja2 templating to your scripts — render dynamic content with variables, conditionals, loops, and filters."
icon: "🐍"
version: "1.0.0"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-03-16"
github_url: "https://github.com/baldator/PSJinja"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/PSJinja/"
issues_url: "https://github.com/baldator/PSJinja/issues"
changelog_url: "https://github.com/baldator/PSJinja/blob/main/CHANGELOG.md"
install_cmd: "Install-Module -Name PSJinja"
downloads: "367"
color: "#1a0a3c"
tags: ["templates", "jinja2", "rendering", "configuration", "automation"]
weight: 7
---

## Overview

**PSJinja** is a PowerShell module that brings the power of [Jinja2](https://jinja.palletsprojects.com/) templating to your scripts. Unlike logic-less Mustache templates, Jinja2 supports a rich set of control structures — conditionals, loops, filters, and macros — making it the go-to templating language for complex dynamic content generation.

Use PSJinja anywhere you need expressive, data-driven text output: infrastructure-as-code configs, deployment manifests, HTML reports, email bodies, and more.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSJinja/):

```powershell
# Install for current user
Install-Module -Name PSJinja -Scope CurrentUser

# Install system-wide (requires elevation)
Install-Module -Name PSJinja

# Import after installation
Import-Module PSJinja
```

---

## Quick Start

### Basic Template Rendering

```powershell
Import-Module PSJinja

# Define a Jinja2 template string
$template = "Hello, {{ name }}! You have {{ count }} new messages."

# Provide data as a hashtable
$data = @{
    name  = "Alice"
    count = 5
}

# Render the template
$result = Invoke-PSJinjaTemplate -Template $template -Data $data
# Output: "Hello, Alice! You have 5 new messages."
Write-Host $result
```

### Rendering from a File

```powershell
# template.j2
# Dear {{ recipient }},
# Your order #{{ order_id }} has been {{ status }}.

$data = @{
    recipient = "Bob Smith"
    order_id  = "ORD-9821"
    status    = "shipped"
}

$result = Invoke-PSJinjaTemplate -TemplatePath "template.j2" -Data $data
Write-Output $result
```

---

## Commands

### `Invoke-PSJinjaTemplate`

Renders a Jinja2 template with the provided data.

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Template` | `string` | Template content as a string |
| `-TemplatePath` | `string` | Path to a `.j2` or other template file |
| `-Data` | `hashtable` | Variables to pass into the template |
| `-TemplateDir` | `string` | Directory to search for included/extended templates |

---

## Template Syntax

### Variables

```jinja
{{ variable }}
{{ user.name }}
{{ items[0] }}
```

### Filters

Apply transformations to values using the pipe `|` operator:

| Filter | Example | Description |
|--------|---------|-------------|
| `upper` | `{{ name | upper }}` | Converts to uppercase |
| `lower` | `{{ name | lower }}` | Converts to lowercase |
| `default` | `{{ value | default('N/A') }}` | Fallback if value is undefined |
| `length` | `{{ items | length }}` | Returns length of a list or string |
| `join` | `{{ list | join(', ') }}` | Joins list items with a separator |
| `replace` | `{{ text | replace('old', 'new') }}` | Replaces substring |
| `trim` | `{{ text | trim }}` | Strips leading/trailing whitespace |

### Conditionals

```jinja
{% if environment == "production" %}
  Log level: Warning
{% elif environment == "staging" %}
  Log level: Info
{% else %}
  Log level: Debug
{% endif %}
```

### Loops

```jinja
{% for server in servers %}
  - {{ server.name }}: {{ server.ip }}
{% endfor %}
```

### Comments

```jinja
{# This is a comment and will not appear in the output #}
```

---

## Advanced Examples

### Generating a Kubernetes ConfigMap

```powershell
Import-Module PSJinja

$template = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ app_name }}-config
  namespace: {{ namespace }}
data:
{% for key, value in config.items() %}
  {{ key }}: "{{ value }}"
{% endfor %}
"@

$data = @{
    app_name  = "my-api"
    namespace = "production"
    config    = @{
        DB_HOST     = "prod-db.internal"
        DB_PORT     = "5432"
        LOG_LEVEL   = "warning"
        CACHE_TTL   = "3600"
    }
}

$result = Invoke-PSJinjaTemplate -Template $template -Data $data
$result | Out-File "configmap.yaml" -Encoding utf8
```

### Environment-Specific Configuration Files

```powershell
# appsettings.j2
# {
#   "ConnectionStrings": {
#     "Default": "Server={{ db_server }};Database={{ db_name }}"
#   },
#   "Logging": {
#     "LogLevel": {
#       "Default": "{{ log_level }}"
#     }
#   },
#   "FeatureFlags": {
#     {% for flag, enabled in features.items() %}
#     "{{ flag }}": {{ enabled | lower }}{% if not loop.last %},{% endif %}
#     {% endfor %}
#   }
# }

$data = @{
    db_server = "prod-sql.company.com"
    db_name   = "AppDatabase"
    log_level = "Warning"
    features  = @{
        DarkMode      = $true
        BetaFeatures  = $false
        Analytics     = $true
    }
}

Invoke-PSJinjaTemplate -TemplatePath "appsettings.j2" -Data $data |
    Out-File "appsettings.json" -Encoding utf8
```

### HTML Report Generation

```powershell
$template = @"
<!DOCTYPE html>
<html>
<head><title>{{ title }}</title></head>
<body>
  <h1>{{ title }}</h1>
  <p>Generated: {{ generated_at }}</p>
  <table>
    <tr><th>Server</th><th>Status</th><th>CPU %</th></tr>
    {% for server in servers %}
    <tr class="{{ 'ok' if server.online else 'error' }}">
      <td>{{ server.name }}</td>
      <td>{{ 'Online' if server.online else 'Offline' }}</td>
      <td>{{ server.cpu }}</td>
    </tr>
    {% endfor %}
  </table>
</body>
</html>
"@

$data = @{
    title        = "Server Status Report"
    generated_at = (Get-Date -Format "yyyy-MM-dd HH:mm")
    servers      = @(
        @{ name = "WEB-01"; online = $true;  cpu = 45 }
        @{ name = "WEB-02"; online = $true;  cpu = 62 }
        @{ name = "DB-01";  online = $false; cpu = 0  }
    )
}

Invoke-PSJinjaTemplate -Template $template -Data $data | Out-File "report.html"
```

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/PSJinja) for details.

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## License

PSJinja is released under the [MIT License](https://github.com/baldator/PSJinja/blob/main/LICENSE).
