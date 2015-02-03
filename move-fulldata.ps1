Add-PSSnapIn -Name VeeamPSSnapIn

Remove-Item 'F:\Monthly\*' -Include .vbk

Copy-Item -Path 'E:\Backups\HVCluster Backup\*.vbk' -Destination 'F:\Monthly'

get-vbrtapejob -name "Monthly Archive" | start-vbrjob -FullBackup