---
title: "Introducing PSInquirer: Interactive CLI Prompts for PowerShell"
date: 2026-03-15
author: "baldator"
tags: ["cli", "interactive", "prompts", "ux", "terminal", "powershell"]
modules: ["PSInquirer"]
summary: "Stop hardcoding values and reading plain Read-Host strings. PSInquirer brings Inquirer.js-style interactive prompts — lists, checkboxes, confirmations, and more — to PowerShell."
---

Every PowerShell script eventually needs user input. And for years the answer has been the same: `Read-Host`. It works, but it's a blunt instrument — no validation, no choices, no multi-select, no conditional logic. **PSInquirer** changes that by bringing [Inquirer.js](https://github.com/SBoudrias/Inquirer.js)-style interactive prompts to PowerShell.

## The Problem with Read-Host

The classic pattern looks like this:

```powershell
$env = Read-Host "Deploy to which environment? (dev/staging/production)"
```

This is fragile. The user might type "Dev", "DEV", "devv", or just press Enter and leave `$env` empty. You end up writing a lot of defensive code before you even start the actual work.

PSInquirer replaces that with structured, validated, user-friendly prompts.

## Installation

```powershell
Install-Module -Name PSInquirer -Scope CurrentUser
Import-Module PSInquirer
```

## Your First Interactive Prompt

```powershell
Import-Module PSInquirer

$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Input   -Name "name"    -Message "What is your name?"
    New-PSIQuestion -Type List    -Name "env"     -Message "Target environment?" `
                    -Choices @("dev", "staging", "production")
    New-PSIQuestion -Type Confirm -Name "proceed" -Message "Ready to deploy?" -Default $true
)

Write-Host "Hello $($answers.name)! Deploying to $($answers.env)..."
```

The user navigates the list with arrow keys, presses Enter to confirm, and the answers come back as a clean hashtable. No parsing, no trimming, no case normalisation.

## Question Types

PSInquirer ships five question types that cover virtually every interactive scenario.

### Text Input

```powershell
New-PSIQuestion -Type Input -Name "appName" -Message "Application name:"
```

### Yes/No Confirmation

```powershell
New-PSIQuestion -Type Confirm -Name "overwrite" -Message "Overwrite existing config?" -Default $false
```

### Single-Choice List

The user selects exactly one option with arrow keys:

```powershell
New-PSIQuestion -Type List -Name "region" -Message "Deploy to which region?" `
    -Choices @("us-east-1", "eu-west-1", "ap-southeast-1")
```

### Multi-Select Checkbox

The user toggles any number of options with Space, then confirms with Enter:

```powershell
New-PSIQuestion -Type Checkbox -Name "features" -Message "Enable optional features:" `
    -Choices @("Logging", "Metrics", "Tracing", "Alerting")
```

### Password (Masked Input)

Input is hidden as the user types:

```powershell
New-PSIQuestion -Type Password -Name "apiKey" -Message "Enter your API key:"
```

## Built-In Validation

Attach a `-Validate` scriptblock to any question. Return `$true` to accept the value, or return an error string to reject it and prompt again:

```powershell
New-PSIQuestion -Type Input -Name "port" -Message "Port number:" -Validate {
    param($value)
    $n = [int]$value
    if ($n -ge 1 -and $n -le 65535) { return $true }
    return "Please enter a value between 1 and 65535."
}
```

The prompt loops until the user provides a valid value — no extra loop code required.

## Conditional Questions

Use `-When` to show a question only when a previous answer satisfies some condition. This lets you build branching wizards without messy if/else blocks:

```powershell
$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Confirm -Name "useTLS"   -Message "Enable TLS?"
    New-PSIQuestion -Type Input   -Name "certPath" -Message "Path to certificate:" -When {
        param($a) $a.useTLS -eq $true
    }
    New-PSIQuestion -Type Input   -Name "certPass"  -Message "Certificate password:" -When {
        param($a) $a.useTLS -eq $true
    }
)
```

If the user answers `No` to "Enable TLS?", the certificate questions are skipped entirely.

## Real-World Example: Deployment Wizard

Here is a complete interactive deployment wizard that collects everything it needs before touching any infrastructure:

```powershell
Import-Module PSInquirer

$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Input    -Name "appName"  -Message "Application name:" -Validate {
        param($v) if ($v.Trim()) { $true } else { "Application name cannot be empty." }
    }
    New-PSIQuestion -Type List     -Name "env"      -Message "Target environment?" `
                    -Choices @("dev", "staging", "production") -Default "dev"
    New-PSIQuestion -Type Checkbox -Name "steps"    -Message "Steps to include:" `
                    -Choices @("Build", "Unit Tests", "Migrate DB", "Deploy", "Smoke Tests")
    New-PSIQuestion -Type Confirm  -Name "dryRun"   -Message "Run as dry-run (no changes)?" `
                    -Default $true
    New-PSIQuestion -Type Confirm  -Name "confirm"  -Message "Everything looks good — proceed?" `
                    -Default $false
)

if (-not $answers.confirm) {
    Write-Host "Deployment cancelled."
    exit 0
}

$mode = if ($answers.dryRun) { "[DRY RUN] " } else { "" }
Write-Host "`n${mode}Deploying $($answers.appName) to $($answers.env)`n"

foreach ($step in $answers.steps) {
    Write-Host "  → Running: $step"
    # ... actual step logic here ...
}

Write-Host "`n✅ Deployment complete!"
```

## Combining PSInquirer with Other PSTools Modules

PSInquirer pairs naturally with other modules in the PSTools ecosystem. For example, pair it with **PSSpinner** to collect input up front and then show progress during execution:

```powershell
Import-Module PSInquirer
Import-Module PSSpinner

# Gather all user choices first
$answers = Invoke-PSInquirer @(
    New-PSIQuestion -Type Input   -Name "server"  -Message "Server hostname:"
    New-PSIQuestion -Type Confirm -Name "restart" -Message "Restart after deploy?" -Default $true
)

# Execute with visual feedback
Invoke-WithSpinner -Message "Deploying to $($answers.server)..." -ScriptBlock {
    Start-Sleep -Seconds 3  # your actual deploy logic
}
```

## Tips for Great Interactive Scripts

1. **Order questions logically** — ask for the most important decisions first so the user can bail early with Ctrl+C if needed.
2. **Use sensible defaults** — set `-Default` on every question so power users can hit Enter quickly through a wizard they run often.
3. **Validate eagerly** — use `-Validate` to catch bad input immediately rather than failing later in the script.
4. **Group with `-When`** — use conditional questions instead of building branching logic around the answers after the fact.
5. **Confirm before irreversible actions** — always finish with a summary and a `Confirm` question before any destructive operation.

## Conclusion

PSInquirer gives PowerShell scripts the same polished, interactive feel that Node.js CLI tools have enjoyed for years. It's a small module with a focused job: replace every `Read-Host` with something your users will actually enjoy.

```powershell
Install-Module -Name PSInquirer -Scope CurrentUser
```

Explore the full command reference on the [PSInquirer module page](/modules/psinquirer/) and browse the source on [GitHub](https://github.com/baldator/PSInquirer).
