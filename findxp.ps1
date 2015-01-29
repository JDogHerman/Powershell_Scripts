$XP = Get-ADComputer -Filter {(OperatingSystem -like "*XP*") -and (enabled -eq $true)} `
    -Properties Name, Enabled, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-90))} |
    Select-Object Name, Enabled, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
          Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        @{name='Owner';`
          Expression={$_.nTSecurityDescriptor.Owner}}, `
        DistinguishedName

$XP | Export-CSV .\xp.csv -NoTypeInformation
