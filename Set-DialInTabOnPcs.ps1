# This script is run with a scheduled task and sets all enabled machines with there Dial In Tab not enabled to enabled.

Get-ADComputer -Filter {(Enabled -eq $True) -and (msNPAllowDialin -ne $true)} -Properties Name, msNPAllowDialin | ForEach-Object {

    Set-ADComputer -Identity $_.name -replace @{msNPAllowDialin='TRUE' }
}
