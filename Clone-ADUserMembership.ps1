#This sctipt will clone a users membership to other users

$donor = ''
$recipiants = ''
Get-ADUser -Identity $donor -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $recipiants