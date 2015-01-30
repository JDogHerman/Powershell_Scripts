$vms = Get-VM 
$log = "c:\temp\vhdx_conversion.txt" 
$VHDType = "Dynamic" 
$DeleteSource = $true 
Clear-Content $log 
 
foreach ($vm in $vms) { 
 
"Processing $($vm.name)" | Add-Content -Path $log 
 
if ($vm.State.ToString() -eq "Off") { 
 
$vhds = $vm.harddrives 
 
if ($vhds) { 
 
foreach ($vhd in $vhds) { 
 
"Processing $($vhd.path)" | Add-Content -Path $log 
 
if ($vhd.path -like "*.vhd") { 
 
$vhdobject = Get-VHD $vhd.Path 
$vhdx = $vhd.path -replace "vhd","vhdx" 
 
"Converting $($vhd.path) - Started $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)" | Add-Content -Path $log 
"VhdType = $($vhdobject.VhdType) Size = $($vhdobject.Size/1GB) GB, FileSize = $($vhdobject.FileSize/1GB) GB" | Add-Content -Path $log 
 
if ($DeleteSource) { 
Convert-VHD -Path $vhd.path -DestinationPath $vhdx -VHDType $VHDType -DeleteSource 
} 
else { 
Convert-VHD -Path $vhd.path -DestinationPath $vhdx -VHDType $VHDType 
} 
 
 
"Converting $($vhd.path) - Ended $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)" | Add-Content -Path $log 
 
$vhd | Set-VMHardDiskDrive -ToControllerType $vhd.ControllerType -ToControllerLocation $vhd.ControllerLocation -ToControllerNumber $vhd.ControllerNumber -Path $vhdx 
 
} 
else { 
"Skipping $($vhd.path) (snapshot or already VHDX)" | Add-Content -Path $log 
} 
 
} 
 
} 
} 
else { 
"$($vm.name) is running, skipping." | Add-Content -Path $log 
} 
}