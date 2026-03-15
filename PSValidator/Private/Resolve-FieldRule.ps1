# Resolve-FieldRule.ps1
# Normalises a raw rule hashtable by filling in default values for optional keys.

function Resolve-FieldRule {
    # Accepts a raw rule hashtable and returns a normalised copy with all keys present.
    param(
        [Parameter(Mandatory)] [hashtable] $Rules
    )

    # Start with a copy so the original is not mutated
    $normalised = @{} + $Rules

    # Boolean flags default to $false when not supplied
    if (-not $normalised.ContainsKey('Required'))  { $normalised['Required']  = $false }
    if (-not $normalised.ContainsKey('Nullable'))  { $normalised['Nullable']  = $false }
    if (-not $normalised.ContainsKey('StrictMode')) { $normalised['StrictMode'] = $false }

    # Numeric / string constraints default to $null (not enforced)
    foreach ($key in @('Type','MinLength','MaxLength','Min','Max','Pattern','AllowedValues','Custom','Default')) {
        if (-not $normalised.ContainsKey($key)) { $normalised[$key] = $null }
    }

    return $normalised
}
