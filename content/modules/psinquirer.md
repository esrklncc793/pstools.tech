---
title: "PSInquirer"
date: 2024-01-06
summary: "A PowerShell port of Inquirer.js — add interactive CLI prompts (text input, confirmations, lists, checkboxes) to your scripts."
icon: "❓"
version: "1.0.1"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-03-25"
github_url: "https://github.com/baldator/PSInquirer"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/PSInquirer/"
issues_url: "https://github.com/baldator/PSInquirer/issues"
changelog_url: "https://github.com/baldator/PSInquirer/blob/main/CHANGELOG.md"
install_cmd: "Install-Module -Name PSInquirer"
downloads: "7"
color: "#16213e"
tags: ["cli", "prompts", "interactive", "ux", "terminal", "input"]
weight: 6
---

## Overview

**PSInquirer** is a PowerShell port of [Inquirer.js](https://github.com/SBoudrias/Inquirer.js) — the popular Node.js library for interactive command-line prompts. It lets you build rich, user-friendly CLI wizards and scripts that gather input through a variety of question types: free-text input, yes/no confirmations, single-choice lists, multi-choice checkboxes, and more.

PSInquirer is ideal for interactive setup scripts, deployment wizards, configuration generators, and any scenario where you need structured input from a user at the terminal.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSInquirer/):

```powershell
# Install for current user
Install-Module -Name PSInquirer -Scope CurrentUser

# Import
Import-Module PSInquirer
```

---

## Quick Start

```powershell
Import-Module PSInquirer

$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Input    -Name "name"    -Message "What is your name?"
    New-PSIQuestion -Type Confirm  -Name "proceed" -Message "Continue with deployment?" -Default $true
    New-PSIQuestion -Type List     -Name "env"     -Message "Target environment?" -Choices @("dev", "staging", "production")
)

Write-Host "Hello, $($answers.name)! Deploying to $($answers.env)."
```

---

## Question Types

### `Input` — free text

```powershell
New-PSIQuestion -Type Input -Name "appName" -Message "Application name:"
```

### `Confirm` — yes/no

```powershell
New-PSIQuestion -Type Confirm -Name "overwrite" -Message "Overwrite existing files?" -Default $false
```

### `List` — single choice from a list

```powershell
New-PSIQuestion -Type List -Name "region" -Message "Deploy to which region?" `
    -Choices @("us-east-1", "eu-west-1", "ap-southeast-1")
```

### `Checkbox` — multiple selections

```powershell
New-PSIQuestion -Type Checkbox -Name "features" -Message "Enable features:" `
    -Choices @("Logging", "Metrics", "Tracing", "Alerting")
```

### `Password` — masked input

```powershell
New-PSIQuestion -Type Password -Name "apiKey" -Message "Enter your API key:"
```

---

## Commands

### `New-PSIQuestion`

Creates a question definition to pass to `Invoke-PSInquirer`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Type` | `string` | *(required)* | Question type: `Input`, `Confirm`, `List`, `Checkbox`, `Password` |
| `-Name` | `string` | *(required)* | Key used to store the answer in the result object |
| `-Message` | `string` | *(required)* | Prompt text displayed to the user |
| `-Default` | `object` | `$null` | Default value used when the user presses Enter |
| `-Choices` | `string[]` | `@()` | Options for `List` and `Checkbox` types |
| `-Validate` | `scriptblock` | `$null` | Validation function; return `$true` to accept, an error string to reject |
| `-When` | `scriptblock` | `$null` | Condition function; question is only shown when this returns `$true` |

### `Invoke-PSInquirer`

Runs a list of questions and returns a single hashtable of answers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Questions` | `object[]` | Array of question objects created by `New-PSIQuestion` |

---

## Validation

Use the `-Validate` parameter to enforce input rules:

```powershell
New-PSIQuestion -Type Input -Name "port" -Message "Port number (1-65535):" -Validate {
    param($value)
    $n = [int]$value
    if ($n -ge 1 -and $n -le 65535) { return $true }
    return "Please enter a valid port number between 1 and 65535."
}
```

---

## Conditional Questions

Use `-When` to show a question only when a previous answer satisfies a condition:

```powershell
$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Confirm -Name "useTLS" -Message "Enable TLS?"
    New-PSIQuestion -Type Input   -Name "certPath" -Message "Path to certificate:" -When {
        param($answers) $answers.useTLS -eq $true
    }
)
```

---

## Examples

### Interactive deployment wizard

```powershell
Import-Module PSInquirer

$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Input    -Name "appName" -Message "Application name:"
    New-PSIQuestion -Type List     -Name "env"     -Message "Target environment?" `
                    -Choices @("dev", "staging", "production") -Default "dev"
    New-PSIQuestion -Type Checkbox -Name "steps"   -Message "Deployment steps to run:" `
                    -Choices @("Build", "Test", "Migrate DB", "Deploy", "Smoke Test")
    New-PSIQuestion -Type Confirm  -Name "confirm"  -Message "Proceed with deployment?" -Default $false
)

if (-not $answers.confirm) {
    Write-Host "Deployment cancelled."
    exit 0
}

Write-Host "Deploying $($answers.appName) to $($answers.env)..."
foreach ($step in $answers.steps) {
    Write-Host "  → $step"
}
```

### Collecting credentials interactively

```powershell
Import-Module PSInquirer

$creds = Invoke-PSInquirer @(
    New-PSIQuestion -Type Input    -Name "username" -Message "Username:"
    New-PSIQuestion -Type Password -Name "password" -Message "Password:"
)

$securePass = ConvertTo-SecureString $creds.password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($creds.username, $securePass)
Connect-MyService -Credential $credential
```

### Dynamic questions based on previous answers

```powershell
Import-Module PSInquirer

$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type List    -Name "dbType"   -Message "Database type?" `
                    -Choices @("SQL Server", "PostgreSQL", "MySQL", "SQLite")
    New-PSIQuestion -Type Input   -Name "host"     -Message "Database host:" `
                    -When { param($a) $a.dbType -ne "SQLite" }
    New-PSIQuestion -Type Input   -Name "dbFile"   -Message "SQLite file path:" `
                    -When { param($a) $a.dbType -eq "SQLite" }
    New-PSIQuestion -Type Confirm -Name "useSSL"   -Message "Use SSL/TLS?" `
                    -When { param($a) $a.dbType -ne "SQLite" }
)

Write-Host "Configuring $($answers.dbType) connection..."
```

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/PSInquirer) for details.

---

## License

PSInquirer is released under the [MIT License](https://github.com/baldator/PSInquirer/blob/main/LICENSE).
