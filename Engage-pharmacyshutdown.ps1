####Shutdown Pharmacy###
$a = new-object -comobject wscript.shell 
$intAnswer = $a.popup("Do you want to shutdown Pharmacy?", ` 
0,"Pharmacy System Shutdown",4) 
If ($intAnswer -eq 6) { 
    $a.popup("You answered yes. Shutting Down! Click ok to 'Make it so!'")
    
    #Get all Hyper-V Hosts and add them to a VAR
    $HV = get-clusternode -Cluster HVCluster1

    #Shutdown PHTS1
    
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "*PHTS1 *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name PHTS1}}
    }

    #Shutdown HO-PCXP-cberke
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "HO-PCXP-CBERKE *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name HO-PCXP-CBERKE}}
    }

    #Shutdown JerryL
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "Jerryl *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name JerryL}}
    }

    #Shutdown RPHOnCall
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "RPHOnCall *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name RPHOnCall}}
    }

    #Shutdown WEB.TSG.DS – (Access Absolute)
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "Web *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name Web}}
    }

    #Shutdown DTFax Server
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "DTFax *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name DTFax}}
    }

    #On DTApp, stop "Intega Docutrack Document Processing Service"
    Get-Service -Name "Intega Docutrack Document Processing Service" -computername DTApp | Set-Service -Status Stopped

    #On DTApp, make sure D:\DocuTrack\Documents\System\PreImport directory is clear
    do {start-sleep -s 1}
    until ((Get-ChildItem '\\dtapp\d$\DocuTrack\Documents\System\PreImport' | Measure-Object).count -eq 0)

    #On DTApp and PreImport directory is clear, stop "Intega Docutrack Document Import Service"
    Get-Service -Name "Intega Docutrack Document Import Service" -computername DTApp | Set-Service -Status Stopped

    #Shutdown DTApp
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "DTApp *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name DTApp}}
    }

    #Shutdown DTSql
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "DTDQL *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name DTSql}}
    }

    #On PHSQL, stop FrameworkHL7 Interface Service
    Get-Service -Name "FrameworkHL7" -computername PHSQL | Set-Service -Status Stopped


    #On RXPASSPORT, stop DXS Transaction Generator
    Get-Service -Name "DXS HL7 Transaction Generator" -computername RXPASSPORT | Set-Service -Status Stopped


    #ON RXPASSPORT, stop rest of DX services
    Get-Service -Name "DX*" -computername RXPASSPORT | Set-Service -Status Stopped


    #On RXPASSPORT, run DX Manager and check for messages. wait for messages
    #Maybe do this???? idk

    #Shutdown RXPassPort
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "RXPassPort *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name RXPassPort}}
    }

    #Shutdown TSGInterfaces	
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "TSGInterfaces *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name TSGInterfaces}}
    }

    #Shutdown PHSQL
    foreach ($i in $HV){
        $HV_VMs = Invoke-Command -ComputerName $i -ScriptBlock {get-vm | select Name} | Out-string
        if ($HV_VMs -like "PHSQL *") 
            {Invoke-Command -ComputerName $i -ScriptBlock {Stop-VM -Name PHSQL}}
    }

    (New-Object -ComObject Wscript.Shell).Popup("Mission Accomplished
But we should still veify.",0,"Hope it worked!")

} else { 
    $a.popup("You answered no. You scared me there.") 
} 