#this script saves a log of where VMs live at in a Cluster
#I set it up to run as a scheduled task every 5 mins.

$path = 'ClusterRoles.csv'

Get-ClusterResource | Select-Object Cluster, OwnerNode, ResourceType, State, OwnerGroup | 
Where-object {$_.ResourceType -eq 'Virtual Machine'} | export-csv -NoTypeInformation $path -force
