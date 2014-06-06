#this script will delete a list of computers from a text file

Get-Content -Path C:\script\disabledpcs5-19.txt | Foreach-Object {

Set-ADComputer -Enabled $false -Identity $_ -PassThru

}