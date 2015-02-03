
##################################################################################################################
# Please Configure the following variables....
$smtpServer="mail.altercareonline.net"
$from = "VEEAM TAPES - IT Support <no-reply@altercareonline.net>"
$Recipient = "sysadmin@altercareonline.net", "meggleston@altercareonline.net"
#
###################################################################################################################

Add-PSSnapIn -Name VeeamPSSnapIn

$date = (get-date -DisplayHint Date)

$barcode = Get-VBRTapeMedium | Select-Object Barcode, expirationdate, Location | Where-Object {($_.expirationdate -lt $date) -and ($_.barcode -notlike "CL*") -and ($_.Location.type -eq "None")} | Sort-Object Expirationdate
$slot = Get-VBRTapeMedium | Select-Object Barcode, expirationdate, Location | Where-Object {($_.expirationdate -gt $date) -and ($_.barcode -notlike "CL*") -and ($_.Location.type -eq "Slot")} | Sort-Object Barcode

# Email Subject Set Here
$subject="Please go get the tapes!"
  
# Email Body Set Here, Note You can use HTML, including Images.
$body ="
<p>Dear Awesome Sysadmin,</p>
<p>This is a reminder. Can you please feed VEEAM more tapes? </br>"

$body+="<Table>"
$body+="<tr><th>Barcode:</th><th></th><th>Expiration Date:</th></tr>"
$barcode | % { $Body+="<tr><td>$($_.Barcode)</td><td>    </td><td>$($_.ExpirationDate)</td></tr>" }
$body+="</Table>"

if(($slot) -ne $null)
{
    $body+="<p>"
    $body+="And pull these tapes from the library and take to the vault?"

    $body+="<Table>"
    $body+="<tr><th>Barcode:</th><th></th><th>Expiration Date:</th></tr>"
    $slot | % { $Body+="<tr><td>$($_.Barcode)</td><td>    </td><td>$($_.ExpirationDate)</td></tr>" }
    $body+="</Table>"
}

$body+="

<p>&nbsp;</p>
<p>Thanks, </p>
<p>IT Dept Autobot</p>
"
    
  
# Send Email Message
if (($barcode) -ne $null)
{
# Send Email Message
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High  

} # End Send Message

# End