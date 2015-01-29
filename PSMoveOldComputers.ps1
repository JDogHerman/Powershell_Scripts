# PSMoveOldComputers.ps1
# PowerShell script to determine when each computer account in the
# domain last had their password changed. If this date is more than a
# specified number of days in the past, the computer object is
# considered inactive and it is moved to a target Organizational Unit.
# The computer account is also disabled. A log file keeps track of which
# computer objects are moved.
#
# ----------------------------------------------------------------------
# Copyright (c) 2011 Richard L. Mueller
# Hilltop Lab web site - http://www.rlmueller.net
# Version 1.0 - April 9, 2011
# Version 1.1 - June 24, 2011 - Escape any "/" characters in DN's.
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the copyright owner above has no warranty, obligations,
# or liability for such use.

Trap {"Error: $_"; Break;}

# Specify log file.
$File = "OldComputers.log"

# Specify the minimum number of days since the password as last set for
# the computer to considered inactive.
$intDays = 150

# Specify the DN of the OU into which inactive computer objects will be moved.
$TargetOU = "OU=Disabled Computers,OU=TSG,DC=tsg,DC=ds"

# Bind to target OU.
$OU = [ADSI]"LDAP://$TargetOU"

$D = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$Domain = [ADSI]"LDAP://$D"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.PageSize = 200
$Searcher.SearchScope = "subtree"

# Filter on all computers that are not disabled.
$Searcher.Filter = "(&(objectCategory=computer)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
$Searcher.PropertiesToLoad.Add("distinguishedName") > $Null
$Searcher.PropertiesToLoad.Add("pwdLastSet") > $Null
$Searcher.SearchRoot = "LDAP://" + $Domain.distinguishedName

# Write information to log file.
$Today = Get-Date
Add-Content -Path $File -Value "Search for inactive computer accounts"
Add-Content -Path $File -Value "Start: $Today"
Add-Content -Path $File -Value "Base of search: $Domain"
Add-Content -Path $File -Value "Log file: $File"
Add-Content -Path $File -Value "Inactive if password not set in days: $intdays"
Add-Content -Path $File -Value "Inactive accounts moved to: $TargetOU"
Add-Content -Path $File -Value "-------------------------------------------"

# Initialize totals.
$Total = 0
$Inactive = 0
$NotMoved = 0
$NotDisabled = 0

$Results = $Searcher.FindAll()
ForEach ($Result In $Results)
{
    $DN = $Result.Properties.Item("distinguishedName")
    #$DN = $DN.Replace("/", "\/")
    $PLS = $Result.Properties.Item("pwdLastSet")
    $Total = $Total + 1
    If ($PLS.Count -eq 0)
    {
        $Date = [DateTime]0
    }
    Else
    {
        # Interpret 64-bit integer as a date.
        $Date = [DateTime]$PLS.Item(0)
    }
    # Convert from .NET ticks to Active Directory Integer8 ticks.
    # Also, convert from UTC to local time.
    $PwdLastSet = $Date.AddYears(1600).ToLocalTime()
    If ($PwdLastSet.AddDays($intDays) -lt $Today)
    {
        # Computer inactive.
        $Inactive = $Inactive + 1
        $Computer= [ADSI]"LDAP://$DN"
        Add-Content -Path $File -Value "Inactive: $DN - Password last set $PwdLastSet"
        # Move computer to target OU.
        Try
        {
            $Computer.psbase.MoveTo($OU)
        }
        Catch
        {
            $NotMoved = $NotMoved + 1
            Add-Content -Path $File -Value "Cannot move: $DN"
        }
        # Disable the computer account.
        Try
        {
            $Flag = $Computer.userAccountControl.Value
            $NewFlag = $Flag -bxor 2
            $Computer.userAccountControl = $NewFlag
            $Computer.SetInfo()
        }
        Catch
        {
            $NotDisabled = $NotDisabled + 1
            Add-Content -Path $File -Value "Cannot disable: $DN"
        }
    }
}

Add-Content -Path $File -Value "Finished: $(Get-Date)"
Add-Content -Path $File -Value "Total computer objects found:   $Total"
Add-Content -Path $File -Value "Inactive:                       $Inactive"
Add-Content -Path $File -Value "Inactice accounts not moved:    $NotMoved"
Add-Content -Path $File -Value "Inactive accounts not disabled: $NotDisabled"
Add-Content -Path $File -Value "-------------------------------------------"

"Total computer objects found:   $Total"
"Inactive:                       $Inactive"
"Inactice accounts not moved:    $NotMoved"
"Inactive accounts not disabled: $NotDisabled"
"Done"