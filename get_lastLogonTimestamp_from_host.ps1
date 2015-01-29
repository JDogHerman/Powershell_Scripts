# Gets host and lastLogonTimestamp in UTC of specified host
 
# get Name
$hostname = Read-host "Enter a hostname"
 
# grab the lastLogonTimestamp attribute
Get-ADComputer $hostname -Properties lastlogontimestamp |
 
# output hostname and timestamp in human readable format
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
