---
title: "PSwatchdog"
date: 2024-01-05
summary: "A PowerShell watchdog module for monitoring and automatically restarting processes, services, or script jobs — keep your automation running reliably."
icon: "🐕"
version: "1.0.1"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-03-15"
github_url: "https://github.com/baldator/PSwatchdog"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/PSwatchdog/"
issues_url: "https://github.com/baldator/PSwatchdog/issues"
changelog_url: "https://github.com/baldator/PSwatchdog/blob/main/CHANGELOG.md"
install_cmd: "Install-Module -Name PSwatchdog"
downloads: "678"
color: "#0d2137"
tags: ["watchdog", "monitoring", "process", "reliability", "automation"]
weight: 5
---

## Overview

**PSwatchdog** is a PowerShell module that monitors processes, services, or script jobs and automatically restarts them when they stop or become unresponsive. It helps keep your long-running automation tasks and critical services reliably running without manual intervention.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSwatchdog/):

```powershell
# Install for current user
Install-Module -Name PSwatchdog -Scope CurrentUser

# Import
Import-Module PSwatchdog
```

---

## Quick Start

```powershell
Import-Module PSwatchdog

# Start watching a process and restart it if it stops
Start-Watchdog -ProcessName "myapp" -Command "C:\apps\myapp.exe"

# Watch a Windows service and restart it if it stops
Watch-Service -Name "MySvc" -RestartDelay 5
```

---

## Commands

### `Start-Watchdog`

Monitors a process by name and restarts it using the provided command if it stops.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ProcessName` | `string` | *(required)* | Name of the process to monitor |
| `-Command` | `string` | *(required)* | Command used to start the process |
| `-Arguments` | `string` | `""` | Optional arguments to pass to the command |
| `-RestartDelay` | `int` | `5` | Seconds to wait before restarting |
| `-MaxRestarts` | `int` | `0` | Maximum restart attempts (0 = unlimited) |

### `Stop-Watchdog`

Stops an active watchdog monitor.

| Parameter | Type | Description |
|-----------|------|-------------|
| `-WatchdogId` | `string` | ID of the watchdog returned by `Start-Watchdog` |

### `Get-Watchdog`

Lists all active watchdog monitors and their status.

### `Watch-Service`

Monitors a Windows service and restarts it if it enters a stopped state.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Name` | `string` | *(required)* | Service name to monitor |
| `-RestartDelay` | `int` | `5` | Seconds to wait before restarting |

---

## Examples

### Monitor a background process

```powershell
Import-Module PSwatchdog

# Start a watchdog that keeps "worker.exe" running
$wd = Start-Watchdog -ProcessName "worker" `
                     -Command "C:\workers\worker.exe" `
                     -Arguments "--config prod.json" `
                     -RestartDelay 10

Write-Host "Watchdog started with ID: $($wd.Id)"
```

### Monitor a Windows service

```powershell
Import-Module PSwatchdog

# Ensure the "DataIngestSvc" service stays running
Watch-Service -Name "DataIngestSvc" -RestartDelay 15

# List active watchdogs
Get-Watchdog
```

### Limit restart attempts

```powershell
# Restart at most 3 times, then give up
Start-Watchdog -ProcessName "flaky-app" `
               -Command "C:\apps\flaky-app.exe" `
               -MaxRestarts 3
```

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/PSwatchdog) for details.

---

## License

PSwatchdog is released under the [MIT License](https://github.com/baldator/PSwatchdog/blob/main/LICENSE).
