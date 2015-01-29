
Import-Module DhcpServer

$dhcpServer = 'dc1','dc2','dc3'

foreach ($server in $dhcpServer) {
    $scope = (Get-DhcpServerv4Scope -ComputerName $server).scopeid.IPAddressToString 
         
    foreach ($ip in $scope) {
        $result = (Get-DhcpServerv4Lease -ComputerName $server -AllLeases -ScopeId $ip | ? clientID -match '00-02-AB-D6-42-12').IPAddress.IPAddressToString 
        if($result -ne $null){Write-Host 'The IP of UNIT one is...' $result 'and the lease expires on...' ((Get-DhcpServerv4Lease -ComputerName $server -AllLeases -ScopeId $ip | ? clientID -match '00-02-AB-D6-42-12').leaseexpirytime) '     The Scope Name is:' (Get-DhcpServerv4Scope -ComputerName $server | ? ScopeID -match $ip).Name '...On Server...' $server }

        $result = (Get-DhcpServerv4Lease -ComputerName $server -AllLeases -ScopeId $ip | ? clientID -match '00-02-AB-0D-F1-FF').IPAddress.IPAddressToString 
        if($result -ne $null){Write-Host 'The IP of UNIT Two is...' $result 'and the lease expires on...' ((Get-DhcpServerv4Lease -ComputerName $server -AllLeases -ScopeId $ip | ? clientID -match '00-02-AB-0D-F1-FF').leaseexpirytime) '     The Scope Name is:' (Get-DhcpServerv4Scope -ComputerName $server | ? ScopeID -match $ip).Name '...On Server...' $server }
    }
}
