---
title: "Better CLI Scripts with PSSpinner: Progress Indicators for PowerShell"
date: 2024-03-05
author: "baldator"
tags: ["cli", "ux", "terminal", "powershell"]
modules: ["PSSpinner"]
summary: "Stop showing plain text 'please wait' messages. Learn how to add animated spinners and progress indicators to your PowerShell scripts with PSSpinner."
---

Nothing makes a CLI tool feel more polished than a well-placed spinner animation. When users run your scripts, they deserve feedback that something is actually happening — not a frozen terminal and a prayer.

**PSSpinner** adds beautiful, animated progress indicators to PowerShell scripts with just a few lines of code.

## The Problem with "Please Wait..."

We've all seen (and written) scripts like this:

```powershell
Write-Host "Installing dependencies, please wait..."
Install-AllTheThings
Write-Host "Done."
```

This works, but it's not very user-friendly. The user has no idea if the script is:
- Still running
- Hung
- 10% done or 90% done

A spinner solves this by providing continuous visual feedback during long operations.

## Getting Started with PSSpinner

```powershell
Install-Module -Name PSSpinner -Scope CurrentUser
Import-Module PSSpinner
```

### The Simplest Spinner

```powershell
$spinner = Start-Spinner -Message "Processing..."
Start-Sleep -Seconds 3  # your actual work here
Stop-Spinner -Spinner $spinner -Message "Done!" -Success
```

That's it! You'll see an animated spinner in the terminal while your code runs.

## Spinner Styles

PSSpinner ships with several animation styles:

```powershell
# Dots (default) — great all-around choice
Start-Spinner -Message "Loading..." -SpinnerType Dots

# Classic — familiar to Unix users
Start-Spinner -Message "Processing..." -SpinnerType Classic

# Star — distinctive and eye-catching
Start-Spinner -Message "Thinking..." -SpinnerType Star

# Arrow — directional feel
Start-Spinner -Message "Searching..." -SpinnerType Arrow
```

## The `Invoke-WithSpinner` Pattern

For the cleanest code, use `Invoke-WithSpinner` to wrap your operations:

```powershell
$result = Invoke-WithSpinner -Message "Fetching server inventory..." -ScriptBlock {
    Get-AzVM | Where-Object { $_.PowerState -eq 'Running' }
}

Write-Host "Found $($result.Count) running VMs"
```

The spinner automatically starts and stops, and if the script block throws an exception, the spinner stops with a failure indicator.

## Real-World Example: Deployment Script

Here's a complete deployment script using PSSpinner to provide step-by-step feedback:

```powershell
Import-Module PSSpinner

function Deploy-App {
    param(
        [string]$Environment,
        [string]$Version
    )

    Write-Host "`n🚀 Deploying $Version to $Environment`n"

    # Step 1: Pre-flight checks
    $preflight = Start-Spinner -Message "Running pre-flight checks..." -Color Cyan
    try {
        Test-NetworkConnectivity
        Test-DatabaseConnection
        Stop-Spinner -Spinner $preflight -Message "Pre-flight checks passed" -Success
    } catch {
        Stop-Spinner -Spinner $preflight -Message "Pre-flight check failed: $_" -Failure
        return $false
    }

    # Step 2: Pull artifacts
    $artifacts = Start-Spinner -Message "Downloading artifacts for v$Version..." -Color Blue
    try {
        Get-BuildArtifact -Version $Version -OutputPath "./deploy"
        Stop-Spinner -Spinner $artifacts -Message "Artifacts downloaded" -Success
    } catch {
        Stop-Spinner -Spinner $artifacts -Message "Failed to download artifacts" -Failure
        return $false
    }

    # Step 3: Migrate database
    $db = Start-Spinner -Message "Applying database migrations..." -Color Yellow
    try {
        Invoke-DatabaseMigration -Environment $Environment
        Stop-Spinner -Spinner $db -Message "Database migrations applied" -Success
    } catch {
        Stop-Spinner -Spinner $db -Message "Migration failed: $_" -Failure
        return $false
    }

    # Step 4: Deploy application
    $deploy = Start-Spinner -Message "Deploying application..." -SpinnerType Star
    try {
        Copy-DeploymentFiles -Source "./deploy" -Target "/var/app/$Environment"
        Restart-AppService -Name "MyApp-$Environment"
        Stop-Spinner -Spinner $deploy -Message "Application deployed" -Success
    } catch {
        Stop-Spinner -Spinner $deploy -Message "Deployment failed: $_" -Failure
        return $false
    }

    Write-Host "`n✅ Deployment of $Version to $Environment complete!`n"
    return $true
}

Deploy-App -Environment "production" -Version "2.5.0"
```

## Tips for Great CLI UX

1. **Be specific in your messages** — "Downloading 47 packages from PSGallery" beats "Loading..."
2. **Use colors semantically** — Cyan for info, Yellow for work in progress, Green for success, Red for errors
3. **Always call `Stop-Spinner`** — Use `try/finally` to ensure the spinner is always stopped
4. **Group related operations** — Each logical step should have its own spinner

## Handling Errors Gracefully

Always wrap spinners in `try/finally`:

```powershell
$spinner = Start-Spinner -Message "Doing important work..."
try {
    Invoke-RiskyOperation
    Stop-Spinner -Spinner $spinner -Message "Operation succeeded" -Success
} catch {
    Stop-Spinner -Spinner $spinner -Message "Error: $($_.Exception.Message)" -Failure
    # Re-throw or handle as needed
    throw
}
```

## Conclusion

PSSpinner is a tiny quality-of-life improvement that makes your scripts noticeably more professional. Your users — and your future self debugging at 2 AM — will thank you.

```powershell
Install-Module -Name PSSpinner -Scope CurrentUser
```

Full source code: [GitHub](https://github.com/baldator/PSspinner) | [PowerShell Gallery](https://www.powershellgallery.com/packages/PSSpinner/1.0.4)
