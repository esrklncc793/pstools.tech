# PSValidator.psm1
# Root module loader — dot-sources classes, private functions, and public functions
# in the correct dependency order.

# 1. Load class definitions first so [PSSchema] and [PSValidationError] are available
. "$PSScriptRoot/Classes/PSValidatorClasses.ps1"

# 2. Load private helper functions
Get-ChildItem "$PSScriptRoot/Private/*.ps1" | ForEach-Object { . $_.FullName }

# 3. Load public cmdlets
Get-ChildItem "$PSScriptRoot/Public/*.ps1" | ForEach-Object { . $_.FullName }
