---
title: "Introducing Poshstache: Mustache Templates for PowerShell"
date: 2024-01-15
author: "baldator"
tags: ["templates", "configuration", "automation"]
modules: ["Poshstache"]
summary: "Learn how to use Mustache templates in your PowerShell scripts with Poshstache — the most flexible way to generate dynamic text content."
---

Generating dynamic text content in PowerShell has traditionally involved string concatenation, here-strings, or calling external tools. With **Poshstache**, you can use the power of [Mustache](https://mustache.github.io/) — the popular logic-less template language — right from your PowerShell scripts.

## What Is Mustache?

Mustache is a "logic-less" template language because it has no explicit control flow statements. Instead, it uses simple tags that are replaced with values from a data object. This makes templates clean, readable, and language-agnostic.

```
Hello, {{name}}!
You have {{count}} unread messages.
```

## Why Poshstache?

Before Poshstache, generating configuration files or HTML from PowerShell required messy string interpolation or complex here-strings. Poshstache brings a clean separation between your **data** and your **presentation**.

## Getting Started

Install it from the PowerShell Gallery:

```powershell
Install-Module -Name Poshstache -Scope CurrentUser
Import-Module Poshstache
```

## Real-World Use Case: Generating Config Files

One of the most common use cases is generating environment-specific configuration files during a deployment pipeline.

Create a template `appsettings.mustache`:

```json
{
  "Database": {
    "Server": "{{db_server}}",
    "Name": "{{db_name}}",
    "Port": {{db_port}}
  },
  "Logging": {
    "Level": "{{log_level}}"
  },
  "Environment": "{{environment}}"
}
```

Then render it with environment-specific values:

```powershell
$data = @{
    db_server   = "prod-sql.company.internal"
    db_name     = "ProductionDB"
    db_port     = 1433
    log_level   = "Warning"
    environment = "Production"
} | ConvertTo-Json

ConvertTo-PoshstacheTemplate -InputFile "appsettings.mustache" -ParametersObject $data |
    Out-File "appsettings.json" -Encoding utf8
```

## Generating HTML Reports

Poshstache is also great for generating HTML reports from PowerShell data:

```powershell
$template = @"
<!DOCTYPE html>
<html>
<body>
  <h1>Server Status Report</h1>
  <table>
    <tr><th>Server</th><th>Status</th><th>CPU</th></tr>
    {{#servers}}
    <tr>
      <td>{{name}}</td>
      <td class="{{#online}}ok{{/online}}{{^online}}error{{/online}}">
        {{#online}}Online{{/online}}{{^online}}Offline{{/online}}
      </td>
      <td>{{cpu}}%</td>
    </tr>
    {{/servers}}
  </table>
</body>
</html>
"@

$report = @{
    servers = @(
        @{ name = "WEB-01"; online = $true;  cpu = 45 }
        @{ name = "WEB-02"; online = $true;  cpu = 62 }
        @{ name = "DB-01";  online = $false; cpu = 0  }
    )
} | ConvertTo-Json -Depth 5

ConvertTo-PoshstacheTemplate -InputString $template -ParametersObject $report |
    Out-File "server-report.html"
```

## Tips

- **Use `{{{triple braces}}}` for unescaped HTML** — Poshstache HTML-escapes by default.
- **Sections work for both conditionals and loops** — if the value is an array, the section loops; if it's a boolean, it acts as a conditional.
- **Keep templates in files** for larger templates; use `-InputString` for quick inline cases.

## Conclusion

Poshstache is a simple but powerful addition to any PowerShell automation toolkit. Whether you're generating config files, HTML reports, or any other text-based output, it keeps your code clean and your templates reusable.

Get started today:

```powershell
Install-Module -Name Poshstache -Scope CurrentUser
```

Check out the full documentation and source code on [GitHub](https://github.com/baldator/poshstache).
