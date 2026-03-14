---
title: "Introducing PSFaker: Realistic Fake Data for PowerShell"
date: 2026-03-10
author: "baldator"
tags: ["testing", "data-generation", "mock", "automation"]
modules: ["PSFaker"]
summary: "Stop hand-crafting test data. PSFaker generates realistic names, addresses, emails, payments, and much more — all from PowerShell."
---

Test suites full of `"John Doe"`, `"test@example.com"`, and `"123 Main St"` get the job done, but they rarely catch the kind of edge cases you'll encounter in production. **PSFaker** brings the battle-tested [Faker](https://github.com/fzaninotto/Faker) library to PowerShell — giving you a rich, realistic dataset at your fingertips for testing, database seeding, and data anonymisation.

## Why Fake Data Matters

Realistic fake data makes your tests more robust and your demos more convincing. Real-looking names surface encoding issues. Varied address formats catch parsing bugs. Plausible credit card numbers reveal validation logic gaps. With PSFaker you replace contrived placeholders with data that actually exercises your code.

## Installation

```powershell
Install-Module -Name PSFaker -Scope CurrentUser
Import-Module PSFaker
```

## Generating Your First Fakes

```powershell
# Optional: seed the RNG for reproducible output
New-Faker -Seed 42

Get-FakeName             # 'Dr. Zane Stroman'
Get-FakeEmail            # 'wade55@wolff.net'
Get-FakeAddress          # '439 Karley Loaf, West Judge, OH 45577'
Get-FakePhoneNumber      # '201-886-0269 x3767'
Get-FakeCompany          # 'Bogan-Treutel'
Get-FakeCreditCardNumber # '4485480221084675'
Get-FakeUuid             # '7e57d004-2b97-4e7a-b45f-5387367791cd'
```

No configuration required — just install, import, and call.

## What PSFaker Can Generate

PSFaker ships with 16+ providers covering virtually every kind of test data you'll need:

| Provider | Sample Output |
|----------|---------------|
| **Person** | `Get-FakeName` → `'Mrs. Elsa Runolfsdottir'` |
| **Internet** | `Get-FakeEmail` → `'maxime.jacobs@gmail.com'` |
| **Address** | `Get-FakeCity` → `'Port Kasandra'` |
| **Company** | `Get-FakeJobTitle` → `'Senior Data Strategist'` |
| **Payment** | `Get-FakeIban` → `'GB29 NWBK 6016 1331 9268 19'` |
| **DateTime** | `Get-FakeDateTimeBetween` → a `DateTime` in a given range |
| **Lorem** | `Get-FakeParagraph` → several sentences of Lorem Ipsum |
| **Color** | `Get-FakeHexColor` → `'#79B8C3'` |
| **UUID** | `Get-FakeUuid` → a RFC 4122 UUID |
| **Misc** | `Get-FakeSha256`, `Get-FakeEmoji`, `Get-FakeBoolean` |

## Real-World Use Case: Seeding a Test Database

Instead of inserting the same five rows by hand, generate a hundred realistic records:

```powershell
Import-Module PSFaker

New-Faker -Seed 1234

$users = 1..100 | ForEach-Object {
    [PSCustomObject]@{
        Id        = Get-FakeUuid
        FirstName = Get-FakeFirstName
        LastName  = Get-FakeLastName
        Email     = Get-FakeEmail
        Phone     = Get-FakePhoneNumber
        Company   = Get-FakeCompany
        JobTitle  = Get-FakeJobTitle
        Address   = Get-FakeAddress
        CreatedAt = Get-FakeDateTimeThisYear
    }
}

$users | Export-Csv -Path "seed_users.csv" -NoTypeInformation
Write-Host "Seeded $($users.Count) users"
```

Because the seed is fixed, every CI run generates the exact same dataset — so tests stay deterministic while data stays realistic.

## Real-World Use Case: Anonymising Production Data

When you need a production-shaped dataset for development but can't use real PII, PSFaker lets you swap sensitive fields while keeping the overall structure intact:

```powershell
Import-Module PSFaker

$prodExport = Import-Csv "prod_users.csv"

$safe = $prodExport | ForEach-Object {
    $_ | Add-Member -NotePropertyName FirstName -NotePropertyValue (Get-FakeFirstName) -Force -PassThru |
         Add-Member -NotePropertyName LastName  -NotePropertyValue (Get-FakeLastName)  -Force -PassThru |
         Add-Member -NotePropertyName Email     -NotePropertyValue (Get-FakeEmail)     -Force -PassThru |
         Add-Member -NotePropertyName Phone     -NotePropertyValue (Get-FakePhoneNumber) -Force -PassThru
}

$safe | Export-Csv "dev_users.csv" -NoTypeInformation
Write-Host "Anonymised $($safe.Count) records"
```

## Modifiers: Unique, Optional, and Valid

Three built-in modifiers give you fine-grained control over generated values.

### Never repeat a value

```powershell
# Generate 9 unique digits — no duplicates
0..8 | ForEach-Object {
    Get-FakeUnique -Generator { Get-FakeRandomDigit }
}
# → 4, 1, 8, 5, 0, 2, 6, 9, 7

Reset-FakeUnique  # clear the cache when you're done
```

### Sometimes return null

```powershell
# 30% chance of $null — great for nullable fields
Get-FakeOptional -Generator { Get-FakeRandomDigit } -Weight 0.7

# Provide a custom default instead of $null
Get-FakeOptional -Generator { Get-FakeWord } -Weight 0.5 -Default 'N/A'
```

### Only accept values matching a predicate

```powershell
# Always an even number
Get-FakeValid -Generator { Get-FakeRandomDigit } -Validator { param($n) $n % 2 -eq 0 }
```

## Reproducible Tests with Seeding

Pin a seed at the start of your test file and every run will generate identical data, keeping your assertions stable:

```powershell
BeforeAll {
    Import-Module PSFaker
    New-Faker -Seed 99
}

It "creates a valid user record" {
    $user = [PSCustomObject]@{
        Name  = Get-FakeName
        Email = Get-FakeEmail
    }
    $user.Email | Should -Match '@'
    $user.Name  | Should -Not -BeNullOrEmpty
}
```

## Conclusion

PSFaker removes the friction from test data entirely. Whether you're seeding a local database, anonymising a production dump, or writing Pester tests, a single `Get-Fake*` call replaces every `"John Doe"` placeholder with something that actually looks real.

```powershell
Install-Module -Name PSFaker -Scope CurrentUser
```

Explore all providers and examples on [GitHub](https://github.com/baldator/PSFaker) and browse the full module reference on the [PSFaker module page](/modules/psfaker/).
