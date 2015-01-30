
﻿#this script will find all DHCP leases to a MAC address across a domain.
﻿
Import-Module DhcpServer

$searchbase = 'dc=tsg,dc=ds'
$defaultmac = 'c8-cb-b8-16-b0-e1'

$clientID = Read-Host 'What is the MAC Address? ex: c8-cb-b8-16-b0-e1'
if($clientID -eq $null){$clientid = $defaultmac}
if($clientID -eq ''){$clientid = $defaultmac}

$searchbase = "cn=configuration," + $searchbase

$dhcpServer = Get-ADObject -SearchBase $searchbase -Filter "objectclass -eq 'dhcpclass' -AND Name -ne 'dhcproot'" | select name
$dhcpServer = $dhcpserver|foreach {$_.name.split('.')[0]}

foreach ($server in $dhcpServer) {
    $scope = (Get-DhcpServerv4Scope -ComputerName $server).scopeid.IPAddressToString 
         
    foreach ($ip in $scope) {
        $result = (Get-DhcpServerv4Lease -ComputerName $server -AllLeases -ScopeId $ip | ? clientID -match $clientID).IPAddress.IPAddressToString 
        if($result -ne $null){Write-Host 'The IP is...' $result 'and the lease expires on...' ((Get-DhcpServerv4Lease -ComputerName $server -AllLeases -ScopeId $ip | ? clientID -match $clientID).leaseexpirytime) '     The Scope Name is:' (Get-DhcpServerv4Scope -ComputerName $server | ? ScopeID -match $ip).Name '...On Server...' $server }
    }
}
