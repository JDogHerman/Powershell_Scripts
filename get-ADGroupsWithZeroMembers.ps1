#gets name of groups that have no members

$membercount = Get-ADGroup -Filter * -Properties members | Where-object {$_.members.count -eq '0'}

$membercount | Export-Csv -Path membercount.csv  -NoTypeInformation   

Write-host $membercount.Count