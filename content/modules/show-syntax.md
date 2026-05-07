---
title: "show-syntax"
date: 2026-03-30
summary: "A PowerShell cat-with-syntax-highlighting module inspired by bat — displays file contents with ANSI colour-coded highlighting, optional line numbers, and pipeline support."
icon: "🎨"
version: "1.0.0"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-03-30"
github_url: "https://github.com/baldator/show-syntax"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/show-syntax/"
issues_url: "https://github.com/baldator/show-syntax/issues"
changelog_url: "https://github.com/baldator/show-syntax/releases"
install_cmd: "Install-Module -Name show-syntax"
downloads: "263"
color: "#1a1a2e"
tags: ["syntax-highlighting", "bat", "ansi", "terminal", "cli", "color"]
weight: 9
---

## Overview

**show-syntax** is a PowerShell module inspired by the popular Rust CLI tool [bat](https://github.com/sharkdp/bat) — a `cat` clone with ANSI syntax highlighting. It reads files and outputs their contents to the console with colour-coded highlighting based on file extension, plus optional line numbers and full pipeline support.

Whether you're reviewing a config file, scanning a script, or paging through log output, `show-syntax` makes the terminal a much more readable place.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/show-syntax/):

```powershell
# Install for current user
Install-Module -Name show-syntax -Scope CurrentUser

# Import
Import-Module show-syntax
```

> **Requirements:** PowerShell 5.1 or later (Windows PowerShell 5.1 and PowerShell 7+).

---

## Quick Start

```powershell
# Display a PowerShell script with syntax highlighting
Show-Syntax -Path .\Deploy.ps1

# Display a JSON file with line numbers
Show-Syntax -Path .\appsettings.json -ShowLineNumbers

# Pipe multiple files from Get-ChildItem
Get-ChildItem -Path .\src -Filter *.ps1 -Recurse | Show-Syntax -ShowLineNumbers
```

---

## Features

- 🎨 **ANSI syntax highlighting** for PowerShell, JSON, XML, Markdown, Python, JavaScript/TypeScript, YAML, Shell scripts, CSS, HTML, CSV, and log files
- 🔢 **Optional line numbers** with `-ShowLineNumbers`
- 🔧 **Language override** with `-Language` when auto-detection isn't enough
- 📥 **Pipeline support** — pipe paths or `FileInfo` objects directly
- 🛡️ **Graceful error handling** for missing or invalid paths
- ⚡ **Efficient streaming** — reads files line-by-line via `StreamReader` to handle large files without loading everything into memory

---

## Commands

### `Show-Syntax`

Displays the contents of one or more files with ANSI syntax highlighting.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Path` | `string[]` | ✅ | One or more file paths. Accepts pipeline input by value or by property name (`FullName`, `FilePath`). |
| `-ShowLineNumbers` | `switch` | ❌ | Prepends each output line with its 1-based line number. |
| `-Language` | `string` | ❌ | Overrides auto-detection. See supported language keys below. |

---

## Supported Language Keys

| Key(s) | File types |
|--------|------------|
| `ps1`, `powershell` | PowerShell (`.ps1`, `.psm1`, `.psd1`) |
| `json` | JSON |
| `xml` | XML |
| `md`, `markdown` | Markdown |
| `py`, `python` | Python |
| `js`, `javascript`, `ts`, `typescript` | JavaScript / TypeScript |
| `yaml` | YAML |
| `sh`, `bash` | Shell / Bash |
| `css` | CSS / SCSS / Less |
| `html` | HTML |
| `csv` | CSV |
| `log` | Log files |
| `txt` | Plain text (no highlighting) |

---

## Examples

### Display a PowerShell script

```powershell
Show-Syntax -Path .\Deploy.ps1
```

Automatically detects the `.ps1` extension and applies PowerShell highlighting — keywords, variables, strings, comments, and cmdlet names are all coloured.

### Display a JSON file with line numbers

```powershell
Show-Syntax -Path .\appsettings.json -ShowLineNumbers
```

Displays the file with JSON highlighting (keys, values, booleans, numbers) and prepends each line with its line number.

### Pipe multiple files recursively

```powershell
Get-ChildItem -Path .\src -Filter *.ps1 -Recurse | Show-Syntax -ShowLineNumbers
```

Pipes all `.ps1` files found recursively under `.\src` into `Show-Syntax`, displaying each with a header banner, PowerShell highlighting, and line numbers.

### Override language detection

```powershell
Show-Syntax -Path .\Dockerfile -Language sh
```

Forces Shell/Bash highlighting on a file whose extension is unknown to the auto-detector.

### Pipe a single path string

```powershell
'.\README.md' | Show-Syntax
```

Passes a file path string through the pipeline and displays it with Markdown highlighting.

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/show-syntax) for details.

---

## License

show-syntax is released under the [MIT License](https://github.com/baldator/show-syntax/blob/main/LICENSE).
