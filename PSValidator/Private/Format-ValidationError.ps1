# Format-ValidationError.ps1
# Factory function that creates [PSValidationError] objects consistently.

function Format-ValidationError {
    # Creates a [PSValidationError] instance with the supplied properties.
    param(
        [Parameter(Mandatory)] [string] $Field,
        [Parameter(Mandatory)] [string] $Rule,
        [Parameter(Mandatory)] [string] $Message,
        [object] $Actual,
        [object] $Expected
    )

    return [PSValidationError]::new($Field, $Rule, $Message, $Actual, $Expected)
}
