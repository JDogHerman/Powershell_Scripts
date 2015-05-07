############################################################################
### A Script to check webpages on disparate hosts and send an email when the are not suscessful
############################################################################
$smtpServer = "mail.altercareonline.net"
$from = "NOREPLY - IT Support <no-reply@altercareonline.net>"
$Recipient = "sysadmin@altercareonline.net"
$ADGoup = "EMARMachines"  #What group has the members to check?
$checkdelay = "30" #How many mins?
############################################################################
Import-Module ActiveDirectory

#creating interation to scan for all machines 
foreach ($emarhost in (get-adgroupmember -Identity $ADGoup | select name).name) {
#checking for connection to system
    if (Test-Connection -ComputerName $emarhost -Quiet) {
        $ie = New-Object -ComObject internetExplorer.Application
        $ie.Visible= $false
        $ie.fullscreen = $false

        $ie.Navigate("http://"+$emarhost+":8088/eMAROffline/login.do")

        #wait till not busy
        while ($ie.Busy -eq $true){Start-Sleep -seconds 2}  

        #turned off as it didnt work in Windows 2008 R2
        #$result = $ie.Document.getElementsByTagName('div') | select textContent | Where-Object {$_.textContent -match 'Update'} 
        $result = $ie.Document.getElementsByTagName('div') | select Outertext | Where-Object {$_.Outertext -match 'Update'} 

        #same as above
        #$resulttrimmed = $result.textContent.ToString().trim() -replace '\s+', ' '
        $resulttrimmed = $result.Outertext.ToString().trim() -replace '\s+', ' '
        (Get-Process -Name iexplore)| Where-Object {$_.MainWindowHandle -eq $ie.HWND} | Stop-Process

        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie)
        #write-host $emarhost $resulttrimmed

        $resultsarray = $resulttrimmed.Split(" ")

        #If the webage status shows as Successful and the time is less than the current time minus the $checkdelay then send an email
        if (($resultsarray[2] -eq 'Successful') -and
        ([datetime]($resultsarray[3]+" "+$resultsarray[4]+" "+$resultsarray[5]) -gt (get-date).AddMinutes(-$checkdelay))
        ){
            $subject = "Issue with EMAR Machine: $emarhost" 
            $body ="
            <p>Dear Lee,</p>
            <p>There is an issue with the EMAR Machine: $emarhost...<p>&nbsp;</p></br>"
            $body+="It's last result was.. <p>&nbsp;</p></br>" 
            $body+= $resulttrimmed
            $body+="The last update was greater than $checkdelay mins"
            $body+="
            <p><br /><br /> Please fix this. :( <br /><br /> 
            <p>&nbsp;</p>
            <p>Thanks, </p>
            <p>IT Dept Autobot</p>
            "
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High -UseSsl 
        } else {
            #write-host "Everything is Awesome!"
        }


        Remove-Variable ie

    } else {
        $subject = "Issue with connecting to the EMAR Machine: $emarhost"
        $body ="
        <p>Dear Lee,</p>
        <p>There is an issue with the Emar Machine: $emarhost...</br></br>"
        $body+="<p>The EMAR Machine is down and could not be checked.</p>"
        $body+="
        <p><br /><br /> Please fix this. :( <br /><br /> 
        <p>&nbsp;</p>
        <p>Thanks, </p>
        <p>IT Dept Autobot</p>
        "
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High -UseSsl 
    }
}