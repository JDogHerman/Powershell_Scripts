Clear-Host

# Import Active Directory Modules, if needed
if (!(Get-Module ActiveDirectory)) {Import-Module ActiveDirectory}

# A little setup for dealing with Null Groups
$GroupName = @()
$NullGroups = New-Object PSObject -Property @{
Name = "No Users or Groups"
SamAccountName = "No Users or Groups"
}

# - Monitoring the following Groups -

$ChildGroups = "Domain Admins","ITDept","Cisco-Networking"
$RootGroups = "Enterprise Admins","Domain Admins","Schema Admins"

# Loop through each child domain group to add "Domain"
foreach ($ChildGroup in $ChildGroups)
{
$GroupName += New-Object PSObject -Property @{
GPName = $ChildGroup;
Domain = 0
}
}
# Loop through each Root domain group to add "domain"
foreach ($RootGroup in $RootGroups)
{
$GroupName += New-Object PSObject -Property @{
GPName = $RootGroup;
Domain = 1
}
}

# Set up the logs path (I wanted to keep the logs separate from the actual script)
$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path) + "\Logs"
if (!(Test-Path $ScriptPath))
{
New-Item -Path $ScriptPath -ItemType Directory | Out-Null
}

$emailFrom = "PSGroupMonitoring@altercareonline.net"
$EmailTo = "alerts@altercareonline.net"
$smtp = "mail.altercareonline.net"

foreach ($Group in $GroupName)
{
switch ($Group.Domain)
{
0 {$domain = (Get-ADDomain).DNSRoot}
}
[array]$members = Get-ADGroupMember $Group.GPName -server $domain | select Name, SamAccountName
Write-Host "$($Group.GPName) Count = [$($members.count)]"
$EmailSubject = "PS MONITORING - $($Group.GPName) Membership Change"

$StateFile = "$($Group.GPName)_$($Group.Domain)_membership.csv"

if (!($members))
{
$members = $NullGroups
}

if (!(Test-Path (Join-Path $ScriptPath $StateFile)))
{
# Create the file if one does not already exist
$members | Export-Csv (Join-Path $ScriptPath $StateFile) -NoTypeInformation
$subj = "PS Monitoring - $($Group.GPName)"
$body = "$($Group.GPName), is now being monitored.`n`nNew baseline files have been created and stored at $(Join-Path $ScriptPath $StateFile)"
Send-MailMessage -To $EmailTo -From $emailFrom -Subject $subj -body $body -SmtpServer $smtp -UseSsl
}

# Get the current membership and start comparing to the last one
$Changes = Compare-Object $Members $(Import-Csv (Join-Path $ScriptPath $StateFile)) -Property Name, SamAccountName | Select-Object Name, SamAccountName,@{n='State';e={If ($_.SideIndicator -eq "=>") {"Removed"} Else {"Added"}}}

if ($Changes)
{
$body = $changes | ConvertTo-Html | Out-String
Send-MailMessage -To $EmailTo -From $emailFrom -Subject $EmailSubject -body $body -BodyAsHtml -SmtpServer $smtp -UseSsl

# Update the CVS file with new Changes, only if there are changes
$Members | Export-csv (Join-Path $ScriptPath $StateFile) -NoTypeInformation
}
}