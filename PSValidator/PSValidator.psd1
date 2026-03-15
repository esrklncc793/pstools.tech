@{
    ModuleVersion     = '1.0.0'
    GUID              = 'a3f7c2d1-84b6-4e59-9f0a-1d2e3b4c5f6a'
    Author            = 'baldator'
    CompanyName       = 'pstools.tech'
    Copyright         = '(c) 2024 baldator. All rights reserved.'
    Description       = 'Declarative schema validation for PowerShell objects — inspired by Pydantic and Zod.'
    PowerShellVersion = '5.1'
    RootModule        = 'PSValidator.psm1'

    FunctionsToExport = @(
        'New-PSSchema',
        'Invoke-PSValidate',
        'Test-PSSchema',
        'Get-PSValidationError'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags        = @('validation','schema','pydantic','zod','hashtable','PSCustomObject','DevOps')
            ProjectUri  = 'https://github.com/esrklncc793/PSValidator'
            LicenseUri  = 'https://github.com/esrklncc793/PSValidator/blob/main/LICENSE'
            ReleaseNotes = 'Initial release — full schema validation engine for hashtables and PSCustomObjects.'
        }
    }
}
