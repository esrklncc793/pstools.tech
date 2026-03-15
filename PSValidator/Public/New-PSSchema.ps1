function New-PSSchema {
<#
.SYNOPSIS
    Defines a validation schema as a [PSSchema] object.

.DESCRIPTION
    New-PSSchema creates a [PSSchema] object that encapsulates field rules used
    by Invoke-PSValidate, Test-PSSchema, and Get-PSValidationError.

    Each entry in -Fields maps a field name to a rule hashtable. Supported rule
    keys are: Type, Required, MinLength, MaxLength, Min, Max, Pattern,
    AllowedValues, Custom, Nullable, Default.

    When -Strict is supplied, any key present in the input object that is NOT
    defined in the schema will cause a validation failure.

.PARAMETER Fields
    A hashtable where each key is a field name and each value is a hashtable of
    validation rules for that field.

.PARAMETER Strict
    If set, input objects may not contain keys that are not defined in -Fields.

.OUTPUTS
    PSSchema

.EXAMPLE
    $schema = New-PSSchema -Fields @{
        Name  = @{ Required = $true; Type = 'string'; MinLength = 2; MaxLength = 50 }
        Age   = @{ Required = $true; Type = 'int';    Min = 0;       Max = 150 }
        Email = @{ Required = $true; Type = 'string'; Pattern = '^[\w.]+@[\w.]+\.\w+$' }
        Role  = @{ Required = $false; AllowedValues = @('admin','user','guest'); Default = 'user' }
    } -Strict

.EXAMPLE
    # Non-strict schema — extra fields in input are ignored
    $loose = New-PSSchema -Fields @{
        Id = @{ Required = $true; Type = 'int' }
    }
#>
    [CmdletBinding()]
    [OutputType('PSSchema')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [hashtable] $Fields,

        [Parameter()]
        [switch] $Strict
    )

    return [PSSchema]::new($Fields, $Strict.IsPresent)
}
