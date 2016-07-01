# A Quick script that searches within source directory for files containing a string. If the string is found it copies the file to the destination

$string = ""
$source = ""
$destination = ""


$I=0
$filecount = (Get-ChildItem).count

Get-ChildItem -path $source |ForEach-Object {
if(Get-Content $_ | select-string $string) {
    copy-item $_ -Destination $destination
    }; $I = $I+1; Write-Progress -Activity "Searching Files" -Status "Progress: $I out of $filecount Percent: $("{0:n3}" -f ($I/$filecount)*100)%" -PercentComplete ($I/$filecount*100)
}
Write-host "Done"
