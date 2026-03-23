#!/usr/bin/env pwsh
# Fetches live stats (GitHub stars, PSGallery version and downloads) for all modules
# listed in modules.json and updates their Hugo content front matter.

param(
    [string]$ConfigFile = "modules.json"
)

$ErrorActionPreference = "Stop"

# Resolve paths relative to the repository root (one level up from this script)
$repoRoot = Split-Path $PSScriptRoot -Parent
if (-not [System.IO.Path]::IsPathRooted($ConfigFile)) {
    $ConfigFile = Join-Path $repoRoot $ConfigFile
}

if (-not (Test-Path $ConfigFile)) {
    Write-Error "Config file not found: $ConfigFile"
    exit 1
}

$config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json

$githubHeaders = @{
    "Accept"     = "application/vnd.github+json"
    "User-Agent" = "pstools.tech-stats-updater"
}
if ($env:GITHUB_TOKEN) {
    $githubHeaders["Authorization"] = "Bearer $env:GITHUB_TOKEN"
}

foreach ($module in $config.modules) {
    Write-Host "Updating $($module.name)..."

    $stars       = $null
    $version     = $null
    $downloads   = $null
    $publishedAt = $null

    # --- GitHub stars ---
    try {
        $githubData = Invoke-RestMethod `
            -Uri "https://api.github.com/repos/$($module.github_repo)" `
            -Headers $githubHeaders `
            -ErrorAction Stop
        $stars = $githubData.stargazers_count
        Write-Host "  Stars: $stars"
    }
    catch {
        Write-Warning "  Failed to get GitHub stars for $($module.github_repo): $_"
    }

    # --- PowerShell Gallery version and downloads ---
    try {
        $galleryUri = "https://www.powershellgallery.com/api/v2/FindPackagesById()" +
                      "?id='$($module.gallery_name)'&`$filter=IsLatestVersion"
        $response = Invoke-WebRequest -Uri $galleryUri -UseBasicParsing -ErrorAction Stop
        [xml]$xml = $response.Content

        $nsManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $nsManager.AddNamespace("d", "http://schemas.microsoft.com/ado/2007/08/dataservices")
        $nsManager.AddNamespace("m", "http://schemas.microsoft.com/ado/2007/08/dataservices/metadata")

        $versionNode   = $xml.SelectSingleNode("//d:Version", $nsManager)
        $downloadsNode = $xml.SelectSingleNode("//d:DownloadCount", $nsManager)
        $publishedNode = $xml.SelectSingleNode("//d:Published", $nsManager)

        if ($versionNode)   { $version   = $versionNode.InnerText }
        if ($downloadsNode) { $downloads = [int]$downloadsNode.InnerText }
        if ($publishedNode) {
            $publishedAt = ([datetime]$publishedNode.InnerText).ToString("yyyy-MM-dd")
        }

        Write-Host "  Version: $version, Downloads: $downloads, Published: $publishedAt"
    }
    catch {
        Write-Warning "  Failed to get PSGallery data for $($module.gallery_name): $_"
    }

    # --- Update front matter in the content file ---
    $contentPath = Join-Path $repoRoot $module.content_file
    if (-not (Test-Path $contentPath)) {
        Write-Warning "  Content file not found: $contentPath"
        continue
    }

    $content = Get-Content -Path $contentPath -Raw

    if ($null -ne $stars) {
        $content = $content -replace '(?m)^github_stars:.*$', "github_stars: $stars"
    }

    if ($version) {
        $content = $content -replace '(?m)^version:.*$', "version: `"$version`""
    }

    if ($null -ne $downloads) {
        $formatted = $downloads.ToString("N0")
        $content = $content -replace '(?m)^downloads:.*$', "downloads: `"$formatted`""
    }

    $lastUpdated = $publishedAt ?? (Get-Date -Format "yyyy-MM-dd")
    $content = $content -replace '(?m)^last_updated:.*$', "last_updated: `"$lastUpdated`""

    Set-Content -Path $contentPath -Value $content -Encoding utf8 -NoNewline
    Write-Host "  ✓ Updated $($module.content_file)"
}

Write-Host "Done."
