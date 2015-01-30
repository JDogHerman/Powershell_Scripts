#this script will delete a list of users from a text file supplied in $path

$path = "C:\script\disabledusers521.txt"

Get-Content -Path $path | Foreach-Object {

Set-ADUser -Enabled $false -Identity $_ -PassThru

}
