# PSValidatorClasses.ps1
# Defines the [PSValidationError] and [PSSchema] classes used throughout the module.

class PSValidationError {
    [string] $Field
    [string] $Rule
    [string] $Message
    [object] $ActualValue
    [object] $ExpectedValue

    PSValidationError(
        [string]$field,
        [string]$rule,
        [string]$message,
        [object]$actual,
        [object]$expected
    ) {
        $this.Field         = $field
        $this.Rule          = $rule
        $this.Message       = $message
        $this.ActualValue   = $actual
        $this.ExpectedValue = $expected
    }

    [string] ToString() {
        return "[$($this.Field)] $($this.Message)"
    }
}

class PSSchema {
    [hashtable] $Fields      # Field name -> rule hashtable
    [bool]      $StrictMode  # Reject keys not defined in schema

    PSSchema([hashtable]$fields, [bool]$strict) {
        $this.Fields     = $fields
        $this.StrictMode = $strict
    }
}
