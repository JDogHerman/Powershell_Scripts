
<#
.SYNOPSIS

Group Policy objects in your domain can have preferences that store passwords for different tasks, such as the following:

    1. Data Sources
    2. Drive Maps
    3. Local Users
    4. Scheduled Tasks (both XP and up-level)
    5. Services

These passwords are stored in SYSVOL as part of GP preferences and are not secure because of weak encryption (32-byte AES). 
Therefore, we recommend that you not deploy such preferences in your domain environment and remove any such existing 
preferences. This script is to help administrator find GP Preferences in their domain's SYSVOL that contains passwords.
 
.DESCRIPTION
This script should be run on a DC or a client computer that is installed with RSAT to print all the preferences that contain 
password with information such as GPO, Preference Name, GPEdit path under which this preference is defined.

After you have a list of affected preferences, these preferences can be removed by using the editor in the Group Policy Management Console.
 
.SYNTAX
Get-SettingsWithCPassword.ps1 [-Path  <String>] 

.EXAMPLE
Get-SettingsWithCPassword.ps1 -Path %WinDir%\SYSVOL\domain

Get-SettingsWithCPassword.ps1 -Path  <GPO Backup Folder Path>
 
.NOTES
If Group Policy PS module is not found the output will contain GPO GUIDs instead of GPO names. You can either run 
this script on a domain controller or rerun the script on the client after you have installed RSAT and 
enabled the Group Policy module.
Or, you can use GPO GUIDs to obtain GPO names by using the Get-GPO cmdlet.
 
.LINK
http://go.microsoft.com/fwlink/?LinkID=390507
 
#>

#----------------------------------------------------------------------------------------------------------------
# Input parameters
#--------------------------------------------------------------------------------------------------------------
param(
    [string]$Path = $(throw "-Path is required.") # Directory path where GPPs are located.
 )

#---------------------------------------------------------------------------------------------------------------

$isGPModuleAvailable = $false
$impactedPrefs = { "Groups.xml", "ScheduledTasks.xml","Services.xml", "DataSources.xml", "Drives.xml" }

#----------------------------------------------------------------------------------------------------------------
# import Group olicy module if available
#----------------------------------------------------------------------------------------------------------------
if (-not (Get-Module -name "GroupPolicy"))
{
   if (Get-Module -ListAvailable | 
         Where-Object { $_.Name -ieq "GroupPolicy" })
    {
        $isGPModuleAvailable = $true
        Import-Module "GroupPolicy"
    }
    else
    {
        Write-Warning "Unable to import Group Policy module for PowerShell. Therefore, GPO guids will be reported. 
                       Run this script on DC to obtain the GPO names, or use the Get-GPO cmdlet (on DC) to obtain the GPO name from GPO guid."
    }
}
else
{
    $isGPModuleAvailable = $true
}

Function Enum-SettingsWithCpassword ( [string]$sysvolLocation )
{
    # GPMC tree paths
    $commonPath = " -> Preferences -> Control Panel Settings -> "
    $driveMapPath = " -> Preferences -> Windows Settings -> "
    
    # Recursively obtain all the xml files within the SYVOL location
    $impactedXmls = Get-ChildItem $sysvolLocation -Recurse -Filter "*.xml" | Where-Object { $impactedPrefs -cmatch $_.Name }
    
    
    # Each xml file contains multiple preferences. Iterate through each preference to check whether it
    # contains cpassword attribute and display it.

    foreach ( $file in $impactedXmls )
    {
        $fileFullPath = $file.FullName
        
        # Set GPP category. If file is located under Machine folder in SYSVOL
        # the setting is defined under computer configuration otherwise the 
        # setting is a to user configuration  

        if ( $fileFullPath.Contains("Machine") )
        {
            $category = "Computer Configuration"
        }
        elseif ( $fileFullPath.Contains("User") )
        {
            $category = "User Configuration"
        }
        else
        {
            $category = "Unknown"
        }

        # Obtain file content as XML
        try
        {
            [xml]$xmlFile = get-content $fileFullPath -ErrorAction Continue
        }
        catch [Exception]{
            Write-Host $_.Exception.Message
        }

        if ($xmlFile -eq $null)
        {
            continue
        }

        switch ( $file.BaseName )
        {

            Groups 
            {
                $gppWithCpassword = $xmlFile.SelectNodes("Groups/User") | where-Object { $_.Properties.cpassword -ne $null}
                $preferenceType = "Local Users"
            }

            ScheduledTasks
            {
                $gppWithCpassword  = $xmlFile.SelectNodes("ScheduledTasks/*") | where-Object { $_.Properties.cpassword -ne $null}
                $preferenceType = "Scheduled Tasks"
            }

            DataSources
            {
                $gppWithCpassword = $xmlFile.SelectNodes("DataSources/DataSource") | where-Object { $_.Properties.cpassword -ne $null}
                $preferenceType = "Data sources"
            }

            Drives
            {
                $gppWithCpassword = $xmlFile.SelectNodes("Drives/Drive") | where-Object { $_.Properties.cpassword -ne $null}
                $preferenceType = "Drive Maps"
            }

            Services
            {
                $gppWithCpassword = $xmlFile.SelectNodes("NTServices/NTService") | where-Object { $_.Properties.cpassword -ne $null}
                $preferenceType = "Services"
            }

            default
            {   # clear gppWithCpassword and preferenceType for next item.
                try
                {
                    Clear-Variable -Name gppWithCpassword -ErrorAction SilentlyContinue
                    Clear-Variable -Name preferenceType -ErrorAction SilentlyContinue
                }
                catch [Exception]{}
            }
        }

        if ($gppWithCpassword -ne $null)
        {
            # Build GPO name from GUID extracted from filePath 
            $guidRegex = [regex]"\{(.*)\}"
            $match = $guidRegex.match($fileFullPath)

            if ($match.Success)
            {
               $gpoGuid = $match.groups[1].value
               $gpoName = $gpoGuid
            }
            else
            {
               $gpoName = "Unknown"
            }

            if($isGPModuleAvailable -eq $true)
            {
                try 
                {   
                    $gpoInfo = Get-GPO -Guid $gpoGuid -ErrorAction Continue
                    $gpoName = $gpoInfo.DisplayName
                }
                catch [Exception] {
                    Write-Host $_.Exception.Message
                }
            }

            # display prefrences that contain cpassword
            foreach ( $gpp in $gppWithCpassword )
            {
                if ( $preferenceType -eq "Drive Maps" )
                {
                    $prefLocation = $category + $driveMapPath + $preferenceType
                }
                else
                {
                    $prefLocation = $category + $commonPath + $preferenceType
                }

                $obj = New-Object -typeName PSObject 
                $obj | Add-Member –membertype NoteProperty –name GPOName    –value ($gpoName)      –passthru |
                       Add-Member -MemberType NoteProperty -name Preference -value ($gpp.Name)     -passthru |
                       Add-Member -MemberType NoteProperty -name Path       -value ($prefLocation)

                Write-Output $obj 

            }
        } # end if $gppWithCpassword
    } # end foreach $file
} # end functions Enum-PoliciesWithCpassword

#-----------------------------------------------------------------------------------
# Check whether Path is valid. Enumerate all settings that contain cpassword. 
#-----------------------------------------------------------------------------------
if (Test-Path $Path )
{
    Enum-SettingsWithCpassword $Path
}
else
{
    Write-Warning "No such directory: $Path"
} 