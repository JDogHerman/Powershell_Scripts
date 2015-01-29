$pcs = Get-ADComputer -Filter {((OperatingSystem -like "*7*") -or (OperatingSystem -like "*XP*")) -and (enabled -eq $true)} `
    -Properties Name, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-90))} |
    Select-Object Name, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
          Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        `
        DistinguishedName

$pcs | Export-CSV .\clientpcs.csv -NoTypeInformation
