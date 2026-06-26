---
title: "PSFaker"
date: 2024-01-04
summary: "A PowerShell port of Faker — generates realistic fake data for testing, database seeding, and data anonymisation."
icon: "🎭"
version: "1.0.0"
author: "baldator"
license: "MIT"
powershell_version: "5.1"
last_updated: "2026-06-26"
github_url: "https://github.com/baldator/PSFaker"
github_stars: 0
gallery_url: "https://www.powershellgallery.com/packages/PSFaker/"
issues_url: "https://github.com/baldator/PSFaker/issues"
changelog_url: "https://github.com/baldator/PSFaker/blob/main/CHANGELOG.md"
install_cmd: "Install-Module -Name PSFaker"
downloads: "719"
color: "#16213e"
tags: ["faker", "testing", "data-generation", "mock", "seeding"]
weight: 4
---

## Overview

**PSFaker** is a PowerShell port of [fzaninotto/Faker](https://github.com/fzaninotto/Faker) that generates realistic fake data for testing, database seeding, and data anonymisation. With providers covering names, addresses, internet data, payments, dates, and much more, PSFaker gives you everything you need to fill your test environments with believable data.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSFaker/):

```powershell
# Install for current user
Install-Module -Name PSFaker -Scope CurrentUser

# Import after installation
Import-Module PSFaker
```

---

## Quick Start

```powershell
Import-Module PSFaker

# Optionally seed the RNG for reproducible output
New-Faker -Seed 1234

# Generate data
Get-FakeName             # 'Dr. Zane Stroman'
Get-FakeEmail            # 'wade55@wolff.net'
Get-FakeAddress          # '439 Karley Loaf, West Judge, OH 45577'
Get-FakePhoneNumber      # '201-886-0269 x3767'
Get-FakeCompany          # 'Bogan-Treutel'
Get-FakeCreditCardNumber # '4485480221084675'
Get-FakeUuid             # '7e57d004-2b97-4e7a-b45f-5387367791cd'
```

---

## Providers

| Provider | Key Functions |
|----------|---------------|
| **Base** | `Get-FakeRandomDigit`, `Get-FakeNumberBetween`, `Format-FakeNumerify`, `Format-FakeRegexify`, … |
| **Lorem** | `Get-FakeWord`, `Get-FakeSentence`, `Get-FakeParagraph`, `Get-FakeText` |
| **Person** | `Get-FakeName`, `Get-FakeFirstName`, `Get-FakeLastName`, `Get-FakeTitle` |
| **Address** | `Get-FakeAddress`, `Get-FakeCity`, `Get-FakeState`, `Get-FakeLatitude` |
| **PhoneNumber** | `Get-FakePhoneNumber`, `Get-FakeTollFreePhoneNumber`, `Get-FakeE164PhoneNumber` |
| **Company** | `Get-FakeCompany`, `Get-FakeCatchPhrase`, `Get-FakeBS`, `Get-FakeJobTitle` |
| **Internet** | `Get-FakeEmail`, `Get-FakeUrl`, `Get-FakeIPv4`, `Get-FakeMacAddress` |
| **DateTime** | `Get-FakeDateTime`, `Get-FakeDate`, `Get-FakeDateTimeBetween` |
| **Payment** | `Get-FakeCreditCardNumber`, `Get-FakeIban`, `Get-FakeSwiftBic` |
| **Color** | `Get-FakeHexColor`, `Get-FakeRgbColor`, `Get-FakeColorName` |
| **UUID** | `Get-FakeUuid` |
| **Barcode** | `Get-FakeEan13`, `Get-FakeEan8`, `Get-FakeIsbn13`, `Get-FakeIsbn10` |
| **Misc** | `Get-FakeBoolean`, `Get-FakeMd5`, `Get-FakeSha256`, `Get-FakeEmoji` |
| **UserAgent** | `Get-FakeUserAgent`, `Get-FakeChromeAgent`, `Get-FakeFirefoxAgent` |
| **Biased** | `Get-FakeBiasedNumberBetween` |
| **HtmlLorem** | `Get-FakeHtmlLorem` |
| **RealText** | `Get-FakeRealText` |

---

## Modifiers

### `Get-FakeUnique` — never repeat values

```powershell
0..8 | ForEach-Object { Get-FakeUnique -Generator { Get-FakeRandomDigit } }
# → [4, 1, 8, 5, 0, 2, 6, 9, 7]

# Reset the unique cache when you need to start over
Reset-FakeUnique
```

### `Get-FakeOptional` — sometimes returns `$null`

```powershell
# 30% chance of $null
Get-FakeOptional -Generator { Get-FakeRandomDigit } -Weight 0.7

# With a custom default instead of $null
Get-FakeOptional -Generator { Get-FakeWord } -Weight 0.5 -Default 'N/A'
```

### `Get-FakeValid` — only returns values that pass a predicate

```powershell
# Always returns an even digit
Get-FakeValid -Generator { Get-FakeRandomDigit } -Validator { param($n) $n % 2 -eq 0 }
```

---

## Seeding

```powershell
# Seed the RNG for reproducible results across runs
New-Faker -Seed 1234
Get-FakeName   # Same result every run with seed 1234
```

---

## Examples

### Seed a test database

```powershell
Import-Module PSFaker

New-Faker -Seed 42

1..100 | ForEach-Object {
    [PSCustomObject]@{
        Id       = Get-FakeUuid
        Name     = Get-FakeName
        Email    = Get-FakeEmail
        Company  = Get-FakeCompany
        Phone    = Get-FakePhoneNumber
        Address  = Get-FakeAddress
    }
} | Export-Csv -Path "users.csv" -NoTypeInformation
```

### Anonymise production data

```powershell
Import-Module PSFaker

$prodUsers = Import-Csv "prod_export.csv"

$anonymised = $prodUsers | ForEach-Object {
    $_ | Add-Member -NotePropertyName "Name"  -NotePropertyValue (Get-FakeName)  -Force -PassThru |
         Add-Member -NotePropertyName "Email" -NotePropertyValue (Get-FakeEmail) -Force -PassThru
}

$anonymised | Export-Csv "anonymised_users.csv" -NoTypeInformation
```

### Generate realistic Lorem Ipsum

```powershell
# One paragraph of fake text
Get-FakeParagraph

# Five sentences
Get-FakeSentences -Count 5

# Full article-length block
Get-FakeText -MaxNbChars 2000
```

---

## Contributing

Contributions are welcome! See the [GitHub repository](https://github.com/baldator/PSFaker) for details.

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## License

PSFaker is released under the [MIT License](https://github.com/baldator/PSFaker/blob/main/LICENSE).
