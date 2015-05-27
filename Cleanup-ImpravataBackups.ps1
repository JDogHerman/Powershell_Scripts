#Powershell Script That will Clean Up old backup files
#Before deleting old files the script will check to make sure files exist in the recent past.

$path = '\\fs1.tsg.ds\Imprivata'
$filter = "*_*.IBU"

$smtpServer="mail.altercareonline.net"
$from = "NOREPLY - IT Support <no-reply@altercareonline.net>"
$Recipient = "sysadmin@altercareonline.net, sspangler@altercareonline.net"
$subject = "No New Impravata Backup Files"
$body = "There are not any new Impravata backups in $path. Please go and find out why these are missing."

$files = @(get-childitem $path -filter $filter | where-object {$_.CreationTime -gt (get-date).AddDays(-7)})

$body += " The current file list is: $((get-childitem $path -filter $filter | select FullName, Length, CreationTime | Sort-Object -property CreationTime -Descending  | ConvertTo-Html -fragment) -replace "\<table\>",'<table cellpadding="5">') "

if (!($files.length -gt 3)) {
Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High -UseSsl
}
    else {
        get-childitem $path -filter $filter | where-object {$_.CreationTime -lt (get-date).AddDays(-60)} | foreach ($_) {remove-item $_.fullname}
    }
