#The purpose of the script is to find domain users who
#are in the local administrators group on their local
#computer

#This script will do the following:
# 1. Query Active Directory for all computers in domain
# 2. Loop through all computers
# 3. If the computer is on the network use WMI
#    to get all local admins, filter out domain admins
#    and any other admins specified
# 4. Write all other admins to console

#Declare variables
$domain = "tsg.ds"

#Declare what local admins to filter out
$localadmin1 = "domain\domain admins"
$localadmin2 = "administrator"

$computers = Get-QADComputer | select name

foreach ($computer in $computers)
{
      $computer = $computer.name
     
      ##Check if computer is accessible, if not go to next computer in list
      $access = Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue
      if ($access -eq $null)
      {
      continue
      }

      #Get list of users in local admin group with WMI
      $list = Get-WmiObject -computername $computer -Class win32_GROUPUSER | WHERE {$_.groupcomponent -match 'administrators' } | foreach {[wmi]$_.partcomponent } -ErrorAction SilentlyContinue

      #For each user filter out domain admins and administrator
      foreach ($user in $list)
      {
      $username = $user.name
     
      #If user is not caught in filter, write to host
      if ($username -notlike "$localadmin1" -and $username -notlike "$localadmin2")
      {
      Write-Host "$computer,$username"
      }
      }
}    
exit