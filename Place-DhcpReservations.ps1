#Sets reservation for DHCP server. The imput file should be in csv format with all details needed.

$path = "reservations.csv"
$DCHPServer = 'TSGDC1.tsg.ds'

﻿Import-Csv –Path $path | Add-DhcpServerv4Reservation -ComputerName $DCHPServer
