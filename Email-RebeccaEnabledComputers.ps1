##################################################################################################################
# Please Configure the following variables....
$smtpServer="mail.altercareonline.net"
$from = "NOREPLY - IT Support <no-reply@altercareonline.net>"
$Recipient = "rebecca.toomey@altercareonline.net", "justin.herman@altercareonline.net"
#
###################################################################################################################

Import-Module ActiveDirectory

$pcs = Get-ADComputer -Filter {((OperatingSystem -like "*7*") -or (OperatingSystem -like "*Embedded*") -or (OperatingSystem -like "* 8*") -or (OperatingSystem -like "*XP*")) -and (enabled -eq $true)} `
    -Properties Name, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Select-Object Name, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
          Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        DistinguishedName

$pcs | Export-CSV .\clientpcs.csv -NoTypeInformation


# Email Subject Set Here
$subject="Daily Enabled AD Computers - " + $pcs.Count 
  
# Email Body Set Here, Note You can use HTML, including Images.
$body ="
<p>Dear Rebecca,</p>
<p>These are computers that are enabled and are XP, Win7, Win8, or Embedded and are part of our Domain. There are "+ $pcs.Count +" computers.</br>
<p>&nbsp;</p>
<p>Thanks, </p>
<p>IT Dept Autobot</p>
"
    
  
# Send Email Message
if (($pcs) -ne $null)
{
# Send Email Message
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -Attachments "clientpcs.csv" -priority High -UseSsl

} # End Send Message

# End