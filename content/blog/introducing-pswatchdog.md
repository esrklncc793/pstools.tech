---
title: "Introducing PSwatchdog: Keep Your PowerShell Processes Running"
date: 2026-03-15
author: "baldator"
tags: ["watchdog", "monitoring", "process", "reliability", "automation"]
modules: ["PSwatchdog"]
summary: "Long-running PowerShell processes crash. PSwatchdog watches them and brings them back automatically — no babysitting required."
---

Production automation is great — right up until a process silently dies at 3 AM and nobody notices until morning. **PSwatchdog** solves that by monitoring your processes, services, and script jobs and restarting them automatically whenever they stop.

## The Problem: Unattended Processes Die

Long-running PowerShell jobs are everywhere: background workers, scheduled data pipelines, local API proxies, file watchers. They all share one flaw — they eventually crash, and without something watching over them, they stay dead until a human notices.

The old-school workaround looks something like this:

```powershell
while ($true) {
    Start-Process "C:\workers\ingest.exe"
    Wait-Process -Name "ingest"
    Write-Host "Process died — restarting..."
    Start-Sleep -Seconds 5
}
```

It works, but it ties up a shell window, offers no visibility, and falls apart the moment you need to manage more than one process. PSwatchdog gives you a proper solution.

## Installation

```powershell
Install-Module -Name PSwatchdog -Scope CurrentUser
Import-Module PSwatchdog
```

## Watching Your First Process

```powershell
Import-Module PSwatchdog

# Start a watchdog that restarts "worker.exe" whenever it stops
$wd = Start-Watchdog -ProcessName "worker" `
                     -Command "C:\workers\worker.exe" `
                     -Arguments "--config prod.json" `
                     -RestartDelay 10

Write-Host "Watchdog running with ID: $($wd.Id)"
```

PSwatchdog monitors the process in the background. If `worker.exe` exits for any reason — crash, OOM kill, unhandled exception — it waits 10 seconds and starts it again automatically.

## Watching a Windows Service

For Windows services you don't even need the command path. Just tell PSwatchdog the service name:

```powershell
# Keep the "DataIngestSvc" service alive
Watch-Service -Name "DataIngestSvc" -RestartDelay 15
```

Every 15 seconds after the service enters a stopped state, PSwatchdog will attempt to restart it — far faster than waiting for an on-call engineer to wake up.

## Visibility: See What's Being Watched

```powershell
Get-Watchdog
```

This lists all active watchdog monitors and their current status so you always know what's being protected.

## Limiting Restart Attempts

Sometimes a process is crashing for a good reason — a bad config, a missing dependency, a downstream service that's fully down. Endlessly restarting it just masks the real problem. Use `-MaxRestarts` to cap the attempts:

```powershell
Start-Watchdog -ProcessName "flaky-app" `
               -Command "C:\apps\flaky-app.exe" `
               -MaxRestarts 3
```

After three unsuccessful restarts PSwatchdog gives up, letting your alerting system surface the real issue rather than hiding it under a restart loop.

## Stopping a Watchdog

When you no longer need a monitor, shut it down cleanly:

```powershell
Stop-Watchdog -WatchdogId $wd.Id
```

## Real-World Use Cases

**CI / CD agent resilience** — keep a self-hosted build agent running without relying on the host OS's service recovery settings.

**Local dev proxies** — restart a local reverse proxy or mock API server the moment it crashes, so you don't lose your development flow.

**Data pipeline workers** — ensure background jobs that ingest, transform, or export data keep running even if they hit transient errors.

**Edge / IoT deployments** — on machines where there is no ops team watching dashboards, PSwatchdog gives your scripts the same restart behaviour you'd expect from a proper service manager.

## Conclusion

PSwatchdog is a small module with a focused job: make sure your PowerShell processes don't stay dead. Whether you're running background workers, Windows services, or long-lived scripts, it keeps things running without any manual intervention.

```powershell
Install-Module -Name PSwatchdog -Scope CurrentUser
```

Explore the source and contribute on [GitHub](https://github.com/baldator/PSwatchdog) and read the full command reference on the [PSwatchdog module page](/modules/pswatchdog/).
