#This sctipt will clone a users (donor) membership and apply it to other user(s) (recipiants) I think it should work on multiple recipiants but I havent checked.
$donorcheck = $false
$recipiantscheck = $false

while ($donorcheck -eq $false) {
$donor = read-host "What username do you want to clone?"
$User = Get-ADUser -LDAPFilter "(sAMAccountName=$donor)"
If ($User -eq $Null) {"$donor does not exist in AD"}
Else {"$donor found in AD"
    $donorcheck = $true
    }
}

while ($recipiantscheck -eq $false) {
    $recipiants = read-host "Whom do you want $donor membership applied to?"
    $User = Get-ADUser -LDAPFilter "(sAMAccountName=$recipiants)"
    If ($User -eq $Null) {"$recipiants does not exist in AD"}
    Else {"$recipiants found in AD"
        $recipiantscheck = $true
        }
}

$confirm = 'Y'
$confirm = read-host "Are you sure you want to clone $donor to $recipiants (Y/n)?"
if (($confirm -eq 'Y') -or ($confirm -eq 'y')) {
    write-host "Cloning $donor to $recipiants"
    Get-ADUser -Identity $donor -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $recipiants
} else {
    write-host "You did not enter Y or y, Exiting..."
}
