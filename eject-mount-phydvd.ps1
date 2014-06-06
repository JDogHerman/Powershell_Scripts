#Eject Disk
Invoke-Command -ComputerName SAS-DC1 -ScriptBlock {get-vm DAD-VM1 | Get-VMDvdDrive | Set-VMDvdDrive -path $null}
#Mount Disk
Invoke-Command -ComputerName SAS-DC1 -ScriptBlock {get-vm DAD-VM1 | Get-VMDvdDrive | Set-VMDvdDrive -Passthru -path D:}