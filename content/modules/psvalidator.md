---
title: "PSValidator"
date: 2024-01-05
summary: "A declarative schema validation engine for PowerShell hashtables and PSCustomObjects — inspired by Python's Pydantic and Node's Zod."
icon: "✅"
version: "1.0.0"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-03-15"
github_url: "https://github.com/esrklncc793/PSValidator"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/PSValidator/1.0.0"
issues_url: "https://github.com/esrklncc793/PSValidator/issues"
changelog_url: "https://github.com/esrklncc793/PSValidator/blob/main/CHANGELOG.md"
install_cmd: "Install-Module -Name PSValidator"
downloads: "0"
color: "#0a1628"
tags: ["validation", "schema", "pydantic", "zod", "hashtable", "PSCustomObject", "DevOps"]
weight: 5
---

## Overview

**PSValidator** is a declarative schema validation engine for PowerShell — inspired by Python's [Pydantic](https://docs.pydantic.dev/) and Node's [Zod](https://zod.dev/). Define a schema once, then validate any hashtable, `PSCustomObject`, or pipeline object against it with a single cmdlet call.

PSValidator is ideal for validating configuration files, API payloads, user input, CSV imports, and any data that enters your automation pipelines.

> **Note:** Schema validation is shallow — nested objects are validated at the top level only (v1.0). Validate nested objects with a separate schema.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSValidator/):

```powershell
# Install for current user
Install-Module -Name PSValidator -Scope CurrentUser

# Import
Import-Module PSValidator
```

---

## Quick Start

```powershell
Import-Module PSValidator

# 1. Define a schema
$userSchema = New-PSSchema -Fields @{
    Username = @{ Required = $true; Type = 'string'; MinLength = 3; MaxLength = 20; Pattern = '^[a-zA-Z0-9_]+$' }
    Age      = @{ Required = $true; Type = 'int';    Min = 13;      Max = 120 }
    Email    = @{ Required = $true; Type = 'string'; Pattern = '^[\w.+-]+@[\w-]+\.\w+$' }
    Role     = @{ Required = $false; AllowedValues = @('admin','user','moderator'); Default = 'user' }
    Bio      = @{ Required = $false; Nullable = $true; MaxLength = 500 }
} -Strict

# 2. Validate (throws on failure; -PassThru returns the enriched object)
$user = @{ Username = 'alice'; Age = 30; Email = 'alice@example.com' }
$validated = Invoke-PSValidate -InputObject $user -Schema $userSchema -PassThru
# $validated.Role == 'user'  (default injected)

# 3. Boolean check — never throws
if (Test-PSSchema -InputObject $user -Schema $userSchema) {
    Write-Host "Data is valid!"
}

# 4. Inspect errors without throwing
$errors = Get-PSValidationError -InputObject @{ Username = 'x'; Age = -5 } -Schema $userSchema
$errors | Format-Table Field, Rule, Message -AutoSize
```

---

## Commands

### `New-PSSchema`

Defines a validation schema.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Fields` | `hashtable` | ✅ | Keys are field names; values are rule hashtables |
| `-Strict` | `switch` | ❌ | Reject input keys not defined in the schema |

**Supported rule keys per field:**

| Rule Key | Type | Description |
|----------|------|-------------|
| `Type` | `string` | Expected .NET type name (`string`, `int`, `bool`, `datetime`, …) |
| `Required` | `bool` | Field must be present and non-null |
| `MinLength` | `int` | Minimum string/array length |
| `MaxLength` | `int` | Maximum string/array length |
| `Min` | `number` | Minimum numeric value (inclusive) |
| `Max` | `number` | Maximum numeric value (inclusive) |
| `Pattern` | `string` | Regex pattern the string value must match |
| `AllowedValues` | `array` | Value must be one of the listed options |
| `Custom` | `scriptblock` | Custom validator: receives `$value`, returns `$true`/`$false` or a string error message |
| `Nullable` | `bool` | `$null` passes even when `Required = $true` |
| `Default` | `object` | Value injected when field is absent (used with `-PassThru`) |

---

### `Invoke-PSValidate`

Validates one or more objects against a schema. **Throws** a terminating error on failure by default.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-InputObject` | `object` | ✅ | Object to validate; accepts pipeline input |
| `-Schema` | `[PSSchema]` | ✅ | Schema to validate against |
| `-PassThru` | `switch` | ❌ | Returns the default-enriched input object on success |
| `-Quiet` | `switch` | ❌ | Returns `$true`/`$false`; never throws |

```powershell
# Throws if invalid
Invoke-PSValidate -InputObject $data -Schema $schema

# Returns enriched object on success
$validated = Invoke-PSValidate -InputObject $data -Schema $schema -PassThru

# Pipeline — validates each object independently
$users | Invoke-PSValidate -Schema $schema -PassThru | Export-Csv ./valid-users.csv

# Non-throwing boolean
if (Invoke-PSValidate -InputObject $data -Schema $schema -Quiet) { ... }
```

---

### `Test-PSSchema`

Non-throwing boolean wrapper. Returns `$true` if valid, `$false` otherwise.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-InputObject` | `object` | ✅ | Object to test |
| `-Schema` | `[PSSchema]` | ✅ | Schema to test against |

```powershell
if (Test-PSSchema -InputObject $data -Schema $schema) {
    Write-Host "Valid!"
}

# Filter a collection
$valid = $items | Where-Object { Test-PSSchema -InputObject $_ -Schema $schema }
```

---

### `Get-PSValidationError`

Returns all `[PSValidationError]` objects for an input without throwing. Returns an empty array when valid.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-InputObject` | `object` | ✅ | Object to validate |
| `-Schema` | `[PSSchema]` | ✅ | Schema to check against |

```powershell
$errors = Get-PSValidationError -InputObject $data -Schema $schema
$errors | Format-Table Field, Rule, Message -AutoSize

# Each error exposes: Field, Rule, Message, ActualValue, ExpectedValue
$typeErrors = $errors | Where-Object Rule -eq 'Type'
```

---

## Error Messages

| Rule | Message |
|------|---------|
| `Required` | `Field '{name}' is required but was not found or is null.` |
| `Type` | `Field '{name}' expected type '{expected}' but got '{actual}'.` |
| `MinLength` | `Field '{name}' length {n} is below minimum {min}.` |
| `MaxLength` | `Field '{name}' length {n} exceeds maximum {max}.` |
| `Min` | `Field '{name}' value {n} is below minimum {min}.` |
| `Max` | `Field '{name}' value {n} exceeds maximum {max}.` |
| `Pattern` | `Field '{name}' value '{v}' does not match pattern '{p}'.` |
| `AllowedValues` | `Field '{name}' value '{v}' is not in allowed values: {list}.` |
| `Custom` | `Field '{name}' failed custom validation: {message}.` |
| `StrictMode` | `Unknown field '{name}' is not allowed in strict mode.` |

---

## Examples

### Validate API request payload

```powershell
Import-Module PSValidator

$requestSchema = New-PSSchema -Fields @{
    Action   = @{ Required = $true; AllowedValues = @('create','update','delete') }
    Resource = @{ Required = $true; Type = 'string'; Pattern = '^[a-z][a-z0-9/-]{2,63}$' }
    DryRun   = @{ Required = $false; Type = 'bool'; Default = $false }
} -Strict

$request = @{ Action = 'create'; Resource = 'projects/my-app' }

$validated = Invoke-PSValidate -InputObject $request -Schema $requestSchema -PassThru
# $validated.DryRun == $false  (default injected)
```

### Validate a CSV import

```powershell
Import-Module PSValidator

$rowSchema = New-PSSchema -Fields @{
    EmployeeId = @{ Required = $true; Type = 'string'; Pattern = '^EMP\d{5}$' }
    Department = @{ Required = $true; AllowedValues = @('Engineering','Sales','HR','Finance') }
    Salary     = @{ Required = $true; Type = 'double'; Min = 20000; Max = 500000 }
}

$rows    = Import-Csv ./employees.csv
$invalid = @()

foreach ($row in $rows) {
    $errors = Get-PSValidationError -InputObject $row -Schema $rowSchema
    if ($errors.Count -gt 0) {
        $invalid += [PSCustomObject]@{ Row = $row; Errors = $errors }
    }
}

Write-Host "$($invalid.Count) invalid rows found."
$invalid | ForEach-Object { $_.Errors | Format-Table Field, Rule, Message }
```

### Custom validation rule

```powershell
$schema = New-PSSchema -Fields @{
    Password = @{
        Required  = $true
        Type      = 'string'
        MinLength = 12
        Custom    = {
            param($v)
            if ($v -notmatch '[A-Z]') { return 'Password must contain at least one uppercase letter.' }
            if ($v -notmatch '[0-9]') { return 'Password must contain at least one digit.' }
            return $true
        }
    }
}

$errors = Get-PSValidationError -InputObject @{ Password = 'weakpassword' } -Schema $schema
$errors | Format-Table Field, Rule, Message
```

---

## Limitations (v1.0)

- **Shallow validation only** — nested objects are not recursively validated. Create a separate schema for each level and call `Invoke-PSValidate` or `Get-PSValidationError` on the nested object.
- **No type coercion** — if the value is a `string` `"42"` and the rule expects `int`, it fails. Cast your values before validation.

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/esrklncc793/PSValidator) for details.

---

## License

PSValidator is released under the [MIT License](https://github.com/esrklncc793/PSValidator/blob/main/LICENSE).
