$pwneverexpire = Get-ADUser -Filter {(enabled -eq $true)} `
    -Properties Name, SamAccountName, PasswordLastSet, PasswordNeverExpires |
    Where-Object {$_.PasswordNeverExpires -eq $true} |
    Where-Object {$_.DistinguishedName -notlike '*guest*'} |
    Where-Object {$_.DistinguishedName -notlike '*zServiceAccounts*'} |
    Where-Object {$_.DistinguishedName -notlike '*silverchair*'} |
    Where-Object {$_.DistinguishedName -notlike '*training*'} |
    Where-Object {$_.DistinguishedName -notlike '*avalon*'} |
    Where-Object {$_.DistinguishedName -notlike '*survey*'} |
    Where-Object {$_.DistinguishedName -notlike '* IM*'} |
    Select-Object Name, SamAccountName, DistinguishedName


$pwneverexpire | Export-CSV .\pwneverexpire.csv -NoTypeInformation

Write-Host $pwneverexpire.count