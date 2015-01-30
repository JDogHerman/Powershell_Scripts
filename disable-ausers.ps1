#this script will delete a list of users from a text file

Get-Content -Path C:\script\disabledusers521.txt | Foreach-Object {

Set-ADUser -Enabled $false -Identity $_ -PassThru

}