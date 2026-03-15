function Test-PSSchema {
<#
.SYNOPSIS
    Returns $true if the input object passes schema validation, $false otherwise.

.DESCRIPTION
    Test-PSSchema is a non-throwing Boolean wrapper around Invoke-PSValidate.
    It never writes to the error stream; use Get-PSValidationError to retrieve
    the individual [PSValidationError] objects when the result is $false.

.PARAMETER InputObject
    The hashtable or PSCustomObject to test.

.PARAMETER Schema
    The [PSSchema] object that defines the validation rules.

.OUTPUTS
    System.Boolean

.EXAMPLE
    $schema = New-PSSchema -Fields @{
        Name = @{ Required = $true; Type = 'string' }
    }

    if (Test-PSSchema -InputObject @{ Name = 'Alice' } -Schema $schema) {
        Write-Host 'Valid!'
    }

.EXAMPLE
    # Use in a filter pipeline
    $validUsers = $users | Where-Object { Test-PSSchema -InputObject $_ -Schema $userSchema }
#>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object] $InputObject,

        [Parameter(Mandatory)]
        [PSSchema] $Schema
    )

    process {
        try {
            # Invoke-PSValidate -Quiet returns $true/$false without throwing
            return (Invoke-PSValidate -InputObject $InputObject -Schema $Schema -Quiet)
        } catch {
            # Should not reach here with -Quiet, but guard defensively
            return $false
        }
    }
}
