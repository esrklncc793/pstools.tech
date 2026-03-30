---
title: "Introducing show-syntax: A bat-inspired Syntax Highlighter for PowerShell"
date: 2026-03-30
author: "baldator"
tags: ["syntax-highlighting", "bat", "ansi", "terminal", "cli", "powershell"]
modules: ["show-syntax"]
summary: "Tired of reading raw file dumps in the terminal? show-syntax brings bat-style ANSI syntax highlighting to PowerShell — colour-coded output for PS1, JSON, YAML, Markdown, and more, with line numbers and full pipeline support."
---

If you've ever used [bat](https://github.com/sharkdp/bat) on Linux or macOS, you know how much nicer it makes reading files in the terminal. Syntax-highlighted output, line numbers, a clear file header — it turns a plain `cat` into something genuinely useful. Now you can have the same experience in PowerShell with **show-syntax**.

## The Problem with `Get-Content`

`Get-Content` gets the job done, but its output is a wall of monochrome text. Scanning a 300-line PowerShell script or a deeply nested JSON config is tedious and error-prone. You end up reaching for an editor just to read a file.

```powershell
# You get everything as identical-looking strings
Get-Content .\appsettings.json
```

`show-syntax` fixes this by colouring the output before it hits your eyes.

## Installation

```powershell
Install-Module -Name show-syntax -Scope CurrentUser
Import-Module show-syntax
```

> Requires PowerShell 5.1 or later.

## Your First Highlighted File

```powershell
Show-Syntax -Path .\Deploy.ps1
```

That's it. `show-syntax` auto-detects the `.ps1` extension and applies PowerShell-aware highlighting: keywords (`function`, `param`, `foreach`, `return`) get one colour, variables (`$name`, `$env:PATH`) another, strings yet another, and comments are dimmed so they don't compete with code.

## Add Line Numbers

Line numbers make it easy to cross-reference output with error messages or code reviews:

```powershell
Show-Syntax -Path .\appsettings.json -ShowLineNumbers
```

Each line is prefixed with its 1-based number, padded for alignment. Combine this with JSON highlighting (keys, values, booleans, numbers each in a distinct colour) and large config files become scannable at a glance.

## Pipeline Support

`show-syntax` is a proper PowerShell citizen — it accepts pipeline input by value and by property name (`FullName`, `FilePath`), so it drops straight into your existing `Get-ChildItem` pipelines:

```powershell
# Highlight every PowerShell file under .\src, with line numbers
Get-ChildItem -Path .\src -Filter *.ps1 -Recurse | Show-Syntax -ShowLineNumbers

# Highlight a file path passed as a string
'.\README.md' | Show-Syntax
```

When you pipe multiple files, each one gets a header banner showing its path so you always know where you are in the output.

## Override Auto-Detection

Auto-detection works on file extension. For files that don't have a recognisable extension — `Dockerfile`, `Makefile`, `Jenkinsfile` — use `-Language` to tell `show-syntax` how to colour the file:

```powershell
Show-Syntax -Path .\Dockerfile -Language sh
```

## Supported File Types

`show-syntax` ships with built-in highlighting for the most common file types encountered in a PowerShell workflow:

| Language | Extensions / Keys |
|----------|-------------------|
| PowerShell | `.ps1`, `.psm1`, `.psd1` |
| JSON | `.json` |
| XML | `.xml` |
| Markdown | `.md` |
| Python | `.py` |
| JavaScript / TypeScript | `.js`, `.ts` |
| YAML | `.yaml`, `.yml` |
| Shell / Bash | `.sh` |
| CSS | `.css`, `.scss` |
| HTML | `.html` |
| CSV | `.csv` |
| Log files | `.log` |
| Plain text | `.txt` |

Unknown extensions get plain text output — no error, just no colouring.

## Efficient for Large Files

Under the hood, `show-syntax` reads files line-by-line via `StreamReader` rather than loading the entire file into memory first. This means you can pipe a 50 MB log file through it without worrying about memory pressure:

```powershell
Show-Syntax -Path .\application.log -ShowLineNumbers
```

## A Practical Day-to-Day Workflow

Here are a few patterns that slot naturally into a PowerShell session:

```powershell
# Quickly review what a config looks like before deploying
Show-Syntax -Path .\config\prod.yaml

# Compare two script versions side-by-side (in split terminal)
Show-Syntax -Path .\v1\Deploy.ps1 -ShowLineNumbers
Show-Syntax -Path .\v2\Deploy.ps1 -ShowLineNumbers

# Audit all module manifests in a repo
Get-ChildItem -Recurse -Filter *.psd1 | Show-Syntax
```

## Conclusion

`show-syntax` is a small, focused module with a clear job: make reading files in the PowerShell terminal as pleasant as using `bat`. ANSI highlighting, line numbers, pipeline support, and graceful handling of unknown file types — everything you need, nothing you don't.

```powershell
Install-Module -Name show-syntax -Scope CurrentUser
```

Explore the full command reference on the [show-syntax module page](/modules/show-syntax/) and browse the source on [GitHub](https://github.com/baldator/show-syntax).
