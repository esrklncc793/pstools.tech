# ConvertTo-InputHashtable.ps1
# Converts any supported input type to a flat hashtable for uniform key access
# across the validation engine.

function ConvertTo-InputHashtable {
    # Accepts null, hashtable, PSCustomObject, or any object with NoteProperties.
    # Returns a hashtable (empty when input is null).
    param([object] $InputObject)

    if ($null -eq $InputObject) {
        return @{}
    }

    if ($InputObject -is [hashtable]) {
        return $InputObject
    }

    # PSCustomObject or any object with NoteProperties
    $ht = @{}
    $InputObject.PSObject.Properties | ForEach-Object { $ht[$_.Name] = $_.Value }
    return $ht
}
