<#
        .Synopsis 
            Gets membership information of local groups in remote computer
 
        .Description
            This script by default queries the membership details of local administrators group on remote computers. 
            It has a provision to query any local group in remote server, not just administrators group.
 
        .Parameter ComputerName
            Computer Name(s) which you want to query for local group information
 
        .Parameter LocalGroupName
            Name of the local group which you want to query for membership information. It queries 'Administrators' group when
            this parameter is not specified
 
        .Parameter OutputDir
            Name of the folder where you want to place the output file. It creates the output file in c:\temp folder
            this parameter is not used.
 
        .Example
            Get-LocalGroupMembers.ps1 -ComputerName srvmem1, srvmem2
 
            Queries the local administrators group membership and writes the details to c:\temp\localGroupMembers.CSV
 
        .Example
            Get-LocalGroupMembers.ps1 -ComputerName (get-content c:\temp\servers.txt)
 
        .Example
            Get-LocalGroupMembers.ps1 -ComputerName srvmem1, srvmem2
 
        .Notes
            Author : Sitaram Pamarthi
            WebSite: http://techibee.com
 
#>
[CmdletBinding()]
Param(
    [Parameter(    ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
                )]
    [string[]]
    $ComputerName = $env:ComputerName,
 
    [Parameter()]
    [string]
    $LocalGroupName = "Administrators",
 
    [Parameter()]
    [string]
    $OutputDir = "c:\temp"
)
 
Begin {
 
    $OutputFile = Join-Path $OutputDir "LocalGroupMembers.csv"
    Write-Verbose "Script will write the output to $OutputFile folder"
    Add-Content -Path $OutPutFile -Value "ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName"
}
 
Process {
    ForEach($Computer in $ComputerName) {
        Write-host "Working on $Computer"
        If(!(Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
            Write-Verbose "$Computer is offline. Proceeding with next computer"
            Add-Content -Path $OutputFile -Value "$Computer,$LocalGroupName,Offline"
            Continue
        } else {
            Write-Verbose "Working on $computer"
            try {
                $group = [ADSI]"WinNT://$Computer/$LocalGroupName"
                $members = @($group.Invoke("Members"))
                Write-Verbose "Successfully queries the members of $computer"
                if(!$members) {
                    Add-Content -Path $OutputFile -Value "$Computer,$LocalGroupName,NoMembersFound"
                    Write-Verbose "No members found in the group"
                    continue
                }
            }        
            catch {
                Write-Verbose "Failed to query the members of $computer"
                Add-Content -Path $OutputFile -Value "$Computer,,FailedToQuery"
                Continue
            }
            foreach($member in $members) {
                try {
                    $MemberName = $member.GetType().Invokemember("Name","GetProperty",$null,$member,$null)
                    $MemberType = $member.GetType().Invokemember("Class","GetProperty",$null,$member,$null)
                    $MemberPath = $member.GetType().Invokemember("ADSPath","GetProperty",$null,$member,$null)
                    $MemberDomain = $null
                    if($MemberPath -match "^Winnt\:\/\/(?<domainName>\S+)\/(?<CompName>\S+)\/") {
                        if($MemberType -eq "User") {
                            $MemberType = "LocalUser"
                        } elseif($MemberType -eq "Group"){
                            $MemberType = "LocalGroup"
                        }
                        $MemberDomain = $matches["CompName"]
 
                    } elseif($MemberPath -match "^WinNT\:\/\/(?<domainname>\S+)/") {
                        if($MemberType -eq "User") {
                            $MemberType = "DomainUser"
                        } elseif($MemberType -eq "Group"){
                            $MemberType = "DomainGroup"
                        }
                        $MemberDomain = $matches["domainname"]
 
                    } else {
                        $MemberType = "Unknown"
                        $MemberDomain = "Unknown"
                    }
                Add-Content -Path $OutPutFile -Value "$Computer, $LocalGroupName, SUCCESS, $MemberType, $MemberDomain, $MemberName"
                } catch {
                    Write-Verbose "failed to query details of a member. Details $_"
                    Add-Content -Path $OutputFile -Value "$Computer,,FailedQueryMember"
                }
 
            } 
        }
 
    }
 
}
End {}
