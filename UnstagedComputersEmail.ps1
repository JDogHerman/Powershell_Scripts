##################################################################################################################
# Please Configure the following variables....
$smtpServer="mail.altercareonline.net"
$from = "NOREPLY - IT Support <no-reply@altercareonline.net>"
$Recipient = "ITdeptTech@altercareonline.net", "rebecca.toomey@altercareonline.net", "blee@altercareonline.net", "sysadmin@altercareonline.net"
#
###################################################################################################################

Import-Module ActiveDirectory

$unstaged = Get-ADComputer -filter * -SearchBase "OU=Unstaged Computers,DC=tsg,DC=ds" | select Name 


# Email Subject Set Here
$subject="Please move Computer Objects from Unstaged OU"
  
# Email Body Set Here, Note You can use HTML, including Images.
$body ="
<p>Dear Staff,</p>
<p>This is a reminder. There are computers still listed in Unstaged Computers OU. Computers left in this location are NOT secure. These computers are... </br>"

$body+="<Table>"
$body+="<tr><th>Computer Name:</th></tr>"
Get-ADComputer -filter * -SearchBase "OU=Unstaged Computers,DC=tsg,DC=ds" | select Name | Sort-Object Name | % { $Body+="<tr><td>$($_.Name)</td></tr>" }
$body+="</Table>"

$body+="
<p><br /><br /> Please move these to their proper OU. <br /><br /> 
<p>&nbsp;</p>
<p>Thanks, </p>
<p>IT Dept Autobot</p>
"
    
  
# Send Email Message
if (($unstaged) -ne $null)
{
# Send Email Message
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High -UseSsl

} # End Send Message

# End