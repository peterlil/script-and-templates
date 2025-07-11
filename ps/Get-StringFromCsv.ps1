Function Get-PasswordFromCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Path to the file")]
        [string]$Path,

        [Parameter(Mandatory=$true, 
            HelpMessage="Vaule of the key")]
        [string]$Key
    )

    $table = Import-Csv -Path $Path

    $table | ForEach-Object {
        if ($_.vm.ToLower() -eq $Key.ToLower()) {
            Write-Host $_.pwd
            break
        }
    }
}

