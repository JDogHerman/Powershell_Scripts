#this script will delete a list of computers from a text file supplied in path
﻿
﻿$path = "C:\script\disabledpcs5-19.txt"

Get-Content -Path $path | Foreach-Object {

Set-ADComputer -Enabled $false -Identity $_ -PassThru

}
