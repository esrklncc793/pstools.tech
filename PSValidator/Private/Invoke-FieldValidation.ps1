# Invoke-FieldValidation.ps1
# Per-field validation engine. Runs each rule check in order and returns
# an array of [PSValidationError] objects (empty array when the field is valid).

function Invoke-FieldValidation {
    param(
        [Parameter(Mandatory)] [string]    $FieldName,
        [object]                           $Value,
        [Parameter(Mandatory)] [hashtable] $Rules,
        [object]                           $InputObject   # full input; reserved for cross-field rules
    )

    # Normalise the rule hashtable so every key is guaranteed to exist
    $r = Resolve-FieldRule -Rules $Rules

    $errors = [System.Collections.Generic.List[PSValidationError]]::new()

    # Helper – determine whether a value is absent (null or missing)
    $isAbsent = ($null -eq $Value)

    # ── 1. Required ──────────────────────────────────────────────────────────
    if ($r['Required'] -and $isAbsent) {
        # Nullable overrides Required: a null value is acceptable when Nullable = $true
        if (-not $r['Nullable']) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'Required' `
                    -Message ("Field '{0}' is required but was not found or is null." -f $FieldName) `
                    -Actual $null -Expected 'non-null value')
            )
            # Short-circuit — remaining rules are meaningless without a value
            return $errors.ToArray()
        }
    }

    # ── 2. Nullable short-circuit ─────────────────────────────────────────────
    # If value is null and either Nullable is set or the field is not Required,
    # there is nothing more to validate.
    if ($isAbsent) {
        return $errors.ToArray()
    }

    # ── 3. Type ───────────────────────────────────────────────────────────────
    if ($null -ne $r['Type']) {
        $expectedTypeName = $r['Type'].ToString().ToLower()

        # Map friendly names to .NET type names
        $typeMap = @{
            'string'   = [string]
            'int'      = [int]
            'int32'    = [int]
            'int64'    = [long]
            'long'     = [long]
            'double'   = [double]
            'float'    = [float]
            'single'   = [float]
            'decimal'  = [decimal]
            'bool'     = [bool]
            'boolean'  = [bool]
            'datetime' = [datetime]
            'guid'     = [guid]
            'uri'      = [uri]
        }

        $targetType = if ($typeMap.ContainsKey($expectedTypeName)) {
            $typeMap[$expectedTypeName]
        } else {
            # Try to resolve via reflection for any other .NET type name
            try { [System.Type]::GetType($r['Type'], $false, $true) } catch { $null }
        }

        $typeValid = $false
        if ($null -ne $targetType) {
            $typeValid = $Value -is $targetType
        } else {
            # Fallback: compare the simple type name (no coercion)
            $typeValid = ($Value.GetType().Name -ieq $r['Type'])
        }

        if (-not $typeValid) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'Type' `
                    -Message ("Field '{0}' expected type '{1}' but got '{2}'." -f `
                        $FieldName, $r['Type'], $Value.GetType().Name) `
                    -Actual $Value.GetType().Name -Expected $r['Type'])
            )
            # A type mismatch makes further numeric/length checks unreliable — short-circuit
            return $errors.ToArray()
        }
    }

    # ── 4. MinLength / MaxLength ──────────────────────────────────────────────
    # Applies to both [string] (character count) and arrays (element count)
    $length = $null
    if ($Value -is [string])  { $length = $Value.Length }
    elseif ($Value -is [array]) { $length = $Value.Count }
    elseif ($Value -is [System.Collections.ICollection]) { $length = $Value.Count }

    if ($null -ne $length) {
        if ($null -ne $r['MinLength'] -and $length -lt [int]$r['MinLength']) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'MinLength' `
                    -Message ("Field '{0}' length {1} is below minimum {2}." -f `
                        $FieldName, $length, $r['MinLength']) `
                    -Actual $length -Expected $r['MinLength'])
            )
        }

        if ($null -ne $r['MaxLength'] -and $length -gt [int]$r['MaxLength']) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'MaxLength' `
                    -Message ("Field '{0}' length {1} exceeds maximum {2}." -f `
                        $FieldName, $length, $r['MaxLength']) `
                    -Actual $length -Expected $r['MaxLength'])
            )
        }
    }

    # ── 5. Min / Max (numeric) ────────────────────────────────────────────────
    if ($null -ne $r['Min'] -or $null -ne $r['Max']) {
        # Only apply when the value is a numeric type
        $isNumeric = $Value -is [int]     -or $Value -is [long]    -or
                     $Value -is [double]  -or $Value -is [float]   -or
                     $Value -is [decimal] -or $Value -is [byte]    -or
                     $Value -is [short]   -or $Value -is [uint32]  -or
                     $Value -is [uint64]

        if ($isNumeric) {
            if ($null -ne $r['Min'] -and $Value -lt $r['Min']) {
                $errors.Add(
                    (Format-ValidationError -Field $FieldName -Rule 'Min' `
                        -Message ("Field '{0}' value {1} is below minimum {2}." -f `
                            $FieldName, $Value, $r['Min']) `
                        -Actual $Value -Expected $r['Min'])
                )
            }

            if ($null -ne $r['Max'] -and $Value -gt $r['Max']) {
                $errors.Add(
                    (Format-ValidationError -Field $FieldName -Rule 'Max' `
                        -Message ("Field '{0}' value {1} exceeds maximum {2}." -f `
                            $FieldName, $Value, $r['Max']) `
                        -Actual $Value -Expected $r['Max'])
                )
            }
        }
    }

    # ── 6. Pattern (regex) ────────────────────────────────────────────────────
    if ($null -ne $r['Pattern'] -and $Value -is [string]) {
        if ($Value -notmatch $r['Pattern']) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'Pattern' `
                    -Message ("Field '{0}' value '{1}' does not match pattern '{2}'." -f `
                        $FieldName, $Value, $r['Pattern']) `
                    -Actual $Value -Expected $r['Pattern'])
            )
        }
    }

    # ── 7. AllowedValues ──────────────────────────────────────────────────────
    if ($null -ne $r['AllowedValues']) {
        $allowed = @($r['AllowedValues'])
        if ($Value -notin $allowed) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'AllowedValues' `
                    -Message ("Field '{0}' value '{1}' is not in allowed values: {2}." -f `
                        $FieldName, $Value, ($allowed -join ', ')) `
                    -Actual $Value -Expected ($allowed -join ', '))
            )
        }
    }

    # ── 8. Custom scriptblock ─────────────────────────────────────────────────
    if ($null -ne $r['Custom']) {
        $customResult = $null
        try {
            $customResult = & $r['Custom'] $Value
        } catch {
            # The scriptblock itself threw — use the exception message
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'Custom' `
                    -Message ("Field '{0}' failed custom validation: {1}." -f `
                        $FieldName, $_.Exception.Message) `
                    -Actual $Value -Expected 'custom rule')
            )
            return $errors.ToArray()
        }

        # Interpret the return value:
        #   [string] → use as custom error message
        #   $false   → generic failure message
        #   $true    → pass
        if ($customResult -is [string]) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'Custom' `
                    -Message ("Field '{0}' failed custom validation: {1}." -f `
                        $FieldName, $customResult) `
                    -Actual $Value -Expected 'custom rule')
            )
        } elseif ($customResult -eq $false) {
            $errors.Add(
                (Format-ValidationError -Field $FieldName -Rule 'Custom' `
                    -Message ("Field '{0}' failed custom validation." -f $FieldName) `
                    -Actual $Value -Expected 'custom rule')
            )
        }
        # $true or any truthy non-string → pass
    }

    return $errors.ToArray()
}
