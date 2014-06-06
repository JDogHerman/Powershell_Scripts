$cred = Get-Credential 'tsg.ds\jlherman'
cd C:\script
. .\tools.ps1

$servers = Get-Content -Path C:\script\serverlist.txt

Get-DiskFree -cn $servers -Format | ? { $_.Type -like '*fixed*' } | sort 'Use%' -Descending | Export-Csv -Path ServerDiskUsage.csv -NoTypeInformation

$xl = New-Object -comobject Excel.Application
# Show Excel
$xl.visible = $true
$xl.DisplayAlerts = $False
# Create a workbook
$wb = $xl.Workbooks.open("C:\script\ServerDiskUsage.csv") 
# Get sheets
#$ws = $wb.WorkSheets.item("Test") 
#$ws.activate()
Start-Sleep 1
$Rng = $ws.UsedRange.Cells 
$row = $Rng.Rows.Count 