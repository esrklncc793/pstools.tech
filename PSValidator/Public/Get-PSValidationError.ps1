function Get-PSValidationError {
<#
.SYNOPSIS
    Returns all [PSValidationError] objects for an input without throwing.

.DESCRIPTION
    Get-PSValidationError runs the same validation logic as Invoke-PSValidate
    but never throws and never writes to the error stream. Instead it returns
    every [PSValidationError] produced by the schema check.

    Returns an empty array when the input is valid.

.PARAMETER InputObject
    The hashtable or PSCustomObject to validate.

.PARAMETER Schema
    The [PSSchema] object that defines the validation rules.

.OUTPUTS
    PSValidationError[]

.EXAMPLE
    $errors = Get-PSValidationError -InputObject @{ Username = 'x'; Age = -1 } -Schema $schema
    $errors | Format-Table Field, Rule, Message -AutoSize

.EXAMPLE
    # Check a specific rule
    $errors = Get-PSValidationError -InputObject $obj -Schema $schema
    $typeErrors = $errors | Where-Object Rule -eq 'Type'
#>
    [CmdletBinding()]
    [OutputType('PSValidationError[]')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object] $InputObject,

        [Parameter(Mandatory)]
        [PSSchema] $Schema
    )

    process {
        # Convert input to a flat hashtable for uniform key access
        $inputHash = ConvertTo-InputHashtable -InputObject $InputObject

        $allErrors = [System.Collections.Generic.List[PSValidationError]]::new()

        # Validate every schema field
        foreach ($fieldName in $Schema.Fields.Keys) {
            $rules = $Schema.Fields[$fieldName]
            $value = if ($inputHash.ContainsKey($fieldName)) { $inputHash[$fieldName] } else { $null }

            $fieldErrors = Invoke-FieldValidation -FieldName $fieldName `
                                                  -Value $value `
                                                  -Rules $rules `
                                                  -InputObject $InputObject
            foreach ($e in $fieldErrors) { $allErrors.Add($e) }
        }

        # Strict mode: reject unknown keys
        if ($Schema.StrictMode) {
            foreach ($key in $inputHash.Keys) {
                if (-not $Schema.Fields.ContainsKey($key)) {
                    $allErrors.Add(
                        (Format-ValidationError -Field $key -Rule 'StrictMode' `
                            -Message ("Unknown field '{0}' is not allowed in strict mode." -f $key) `
                            -Actual $key -Expected 'defined schema field')
                    )
                }
            }
        }

        return $allErrors.ToArray()
    }
}
