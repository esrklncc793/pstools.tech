---
title: "PSSpinner"
date: 2024-01-03
summary: "A PowerShell module that adds animated CLI spinners and progress indicators to make your scripts more user-friendly and professional."
icon: "🌀"
version: "1.0.4"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-06-13"
github_url: "https://github.com/baldator/PSspinner"
github_stars: 3
gallery_url: "https://www.powershellgallery.com/packages/PSSpinner/1.0.4"
issues_url: "https://github.com/baldator/PSspinner/issues"
changelog_url: "https://github.com/baldator/PSspinner/blob/master/CHANGELOG.md"
install_cmd: "Install-Module -Name PSSpinner"
downloads: "699"
color: "#0d2137"
tags: ["cli", "spinner", "progress", "ux", "terminal", "animation"]
weight: 3
---

## Overview

**PSSpinner** is a PowerShell module that adds animated spinner and progress indicators to your CLI scripts. Stop showing static "please wait..." messages and give your users a real-time sense of progress with smooth, animated spinners.

PSSpinner is perfect for long-running operations: installations, API calls, file transfers, data processing, and more.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSSpinner/):

```powershell
# Install for current user
Install-Module -Name PSSpinner -Scope CurrentUser

# Import
Import-Module PSSpinner
```

---

## Quick Start

### Basic Spinner

```powershell
Import-Module PSSpinner

# Start a spinner with a message
$spinner = Start-Spinner -Message "Loading configuration..."

# Perform your long-running work
Start-Sleep -Seconds 3

# Stop the spinner with a success or failure message
Stop-Spinner -Spinner $spinner -Message "Configuration loaded!" -Success
```

### Auto-Stop with Script Block

```powershell
Invoke-WithSpinner -Message "Fetching data from API..." -ScriptBlock {
    Invoke-RestMethod -Uri "https://api.example.com/data"
}
```

---

## Commands

### `Start-Spinner`

Starts a spinner animation in the terminal.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Message` | `string` | `""` | Message displayed next to the spinner |
| `-SpinnerType` | `string` | `"Dots"` | Spinner animation style |
| `-Color` | `string` | `"Cyan"` | Spinner color |

### `Stop-Spinner`

Stops the spinner animation.

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Spinner` | `object` | Spinner object returned by `Start-Spinner` |
| `-Message` | `string` | Final message to display |
| `-Success` | `switch` | Show ✅ success indicator |
| `-Failure` | `switch` | Show ❌ failure indicator |

### `Invoke-WithSpinner`

Runs a script block with an automatic spinner.

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Message` | `string` | Message shown during execution |
| `-ScriptBlock` | `scriptblock` | Code to execute |
| `-SpinnerType` | `string` | Spinner animation style |

---

## Spinner Types

PSSpinner includes multiple animation styles:

| Name | Preview |
|------|---------|
| `Dots` | ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏ |
| `Line` | - \ \| / |
| `Star` | ✶ ✸ ✹ ✺ ✹ ✷ |
| `Bounce` | ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ |
| `Arrow` | ←↖↑↗→↘↓↙ |
| `Classic` | \| / - \\ |

---

## Examples

### Installation Script with Spinner

```powershell
Import-Module PSSpinner

Write-Host "🚀 Starting deployment`n"

# Step 1: Download
$s1 = Start-Spinner -Message "Downloading packages..." -SpinnerType Dots -Color Blue
Start-Sleep -Seconds 2  # simulate download
Stop-Spinner -Spinner $s1 -Message "Packages downloaded" -Success

# Step 2: Install
$s2 = Start-Spinner -Message "Installing dependencies..." -SpinnerType Line -Color Yellow
Start-Sleep -Seconds 3  # simulate install
Stop-Spinner -Spinner $s2 -Message "Dependencies installed" -Success

# Step 3: Configure (with error)
$s3 = Start-Spinner -Message "Configuring application..."
try {
    # ... configuration ...
    Stop-Spinner -Spinner $s3 -Message "Configuration complete" -Success
} catch {
    Stop-Spinner -Spinner $s3 -Message "Configuration failed: $_" -Failure
    exit 1
}

Write-Host "`n✅ Deployment complete!"
```

### Multiple Concurrent Spinners

```powershell
# Run multiple operations in parallel with spinners
$jobs = @(
    "Database migration"
    "Cache warm-up"
    "Index rebuild"
)

foreach ($job in $jobs) {
    Invoke-WithSpinner -Message $job -ScriptBlock {
        # Simulate work
        Start-Sleep -Milliseconds (Get-Random -Min 1000 -Max 3000)
    }
}
```

---

## Tips & Tricks

**Wrap any long operation:**
```powershell
$result = Invoke-WithSpinner -Message "Querying database..." -ScriptBlock {
    Get-SqlData -Server "prod-sql" -Query "SELECT * FROM Orders WHERE Status='Pending'"
}
```

**Use with try/catch for robust error handling:**
```powershell
$spinner = Start-Spinner -Message "Processing files..."
try {
    # ... your code ...
    Stop-Spinner -Spinner $spinner -Message "Done! Processed 1,234 files" -Success
} catch {
    Stop-Spinner -Spinner $spinner -Message $_.Exception.Message -Failure
}
```

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/PSspinner) for details.

---

## License

PSSpinner is released under the [MIT License](https://github.com/baldator/PSspinner/blob/master/LICENSE).
