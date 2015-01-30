
#Start VS1 TFTP Server for Phones
Get-Service -Name "SolarWinds TFTP Server" -computername vs1 | Set-Service -Status Running
#Start VS2 - SQL Server
Get-Service -Name "SQL Server (SQLEXPRESS)" -computername vs2 | Set-Service -Status Running

#Start HERE!
#Invoke-Command -ComputerName HV4 -ScriptBlock {Start-VM -Name Crashplan}