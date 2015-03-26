$oldusers = Get-ADUser -Filter {(enabled -eq $true)} `
    -Properties Name, SamAccountName, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {[datetime]::FromFileTimeUTC($_.LastLogonTimestamp) -lt $((Get-Date).AddDays(-180))} |
    Where-Object {($_.whencreated) -lt $((Get-Date).AddDays(-90))} |
    Where-Object {$_.DistinguishedName -notlike '*silverchair*'} |
    Where-Object {$_.DistinguishedName -notlike '*zServiceAccounts*'} |
    Select-Object Name, SamAccountName, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
          Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        @{name='Owner';`
          Expression={$_.nTSecurityDescriptor.Owner}}, `
        DistinguishedName

$oldusers | Export-CSV .\oldusers.csv -NoTypeInformation

Write-host $oldusers.count
