function Invoke-PSValidate {
<#
.SYNOPSIS
    Validates one or more objects against a PSSchema.

.DESCRIPTION
    Invoke-PSValidate runs every field in the schema against the supplied input
    object. It collects all [PSValidationError] objects produced by the
    per-field rules.

    On failure the cmdlet writes a terminating error whose message lists every
    validation error. Use -Quiet to suppress output and return $true/$false, or
    use Get-PSValidationError / Test-PSSchema for non-throwing alternatives.

    When -PassThru is specified the validated (and default-enriched) input
    object is written to the pipeline on success.

    Pipeline input is fully supported: multiple objects are each validated
    independently.

    NOTE: Schema validation is shallow — nested objects are not recursively
    validated in v1.0. Validate nested objects with a separate schema.

.PARAMETER InputObject
    The hashtable or PSCustomObject to validate. Accepts pipeline input.

.PARAMETER Schema
    The [PSSchema] object that defines the validation rules.

.PARAMETER PassThru
    When set, the validated input object (enriched with any Default values) is
    written to the success pipeline on success.

.PARAMETER Quiet
    Suppress all output. Returns $true on success, $false on failure.
    Mutually exclusive with -PassThru.

.OUTPUTS
    System.Boolean  (when -Quiet is used)
    PSCustomObject  (when -PassThru is used and validation passes)

.EXAMPLE
    $schema = New-PSSchema -Fields @{
        Name = @{ Required = $true; Type = 'string' }
        Age  = @{ Required = $true; Type = 'int'; Min = 0 }
    }
    Invoke-PSValidate -InputObject @{ Name = 'Alice'; Age = 30 } -Schema $schema -PassThru

.EXAMPLE
    # Pipeline validation
    $users | Invoke-PSValidate -Schema $schema -PassThru | Export-Csv ./valid.csv

.EXAMPLE
    # Quiet mode
    if (Invoke-PSValidate -InputObject $obj -Schema $schema -Quiet) {
        Write-Host 'Valid'
    }
#>
    [CmdletBinding()]
    [OutputType([bool], ParameterSetName = 'Quiet')]
    [OutputType([PSCustomObject], ParameterSetName = 'PassThru')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object] $InputObject,

        [Parameter(Mandatory)]
        [PSSchema] $Schema,

        [Parameter(ParameterSetName = 'PassThru')]
        [switch] $PassThru,

        [Parameter(ParameterSetName = 'Quiet')]
        [switch] $Quiet
    )

    process {
        # Convert input to a flat hashtable for uniform key access
        $inputHash = ConvertTo-InputHashtable -InputObject $InputObject

        $allErrors = [System.Collections.Generic.List[PSValidationError]]::new()

        # ── Validate each schema field ────────────────────────────────────────
        foreach ($fieldName in $Schema.Fields.Keys) {
            $rules = $Schema.Fields[$fieldName]

            # Retrieve the value (null when the key is absent)
            $value = if ($inputHash.ContainsKey($fieldName)) { $inputHash[$fieldName] } else { $null }

            $fieldErrors = Invoke-FieldValidation -FieldName $fieldName `
                                                  -Value $value `
                                                  -Rules $rules `
                                                  -InputObject $InputObject
            foreach ($e in $fieldErrors) { $allErrors.Add($e) }
        }

        # ── Strict mode: reject unknown keys ──────────────────────────────────
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

        # ── Report results ────────────────────────────────────────────────────
        if ($allErrors.Count -gt 0) {
            if ($Quiet) {
                return $false
            }

            $summary = $allErrors | ForEach-Object { $_.ToString() }
            $message = "Validation failed with $($allErrors.Count) error(s):`n" +
                       ($summary -join "`n")

            $ex     = [System.Exception]::new($message)
            $errRec = [System.Management.Automation.ErrorRecord]::new(
                $ex,
                'PSValidator.ValidationFailed',
                [System.Management.Automation.ErrorCategory]::InvalidData,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errRec)
        }

        # ── Success path ──────────────────────────────────────────────────────
        if ($Quiet) {
            return $true
        }

        if ($PassThru) {
            # Build output object: start from input, then inject Default values
            $output = @{} + $inputHash

            foreach ($fieldName in $Schema.Fields.Keys) {
                $rules = Resolve-FieldRule -Rules $Schema.Fields[$fieldName]
                if (-not $output.ContainsKey($fieldName) -and $null -ne $rules['Default']) {
                    $output[$fieldName] = $rules['Default']
                }
            }

            Write-Output ([PSCustomObject] $output)
        }
    }
}
