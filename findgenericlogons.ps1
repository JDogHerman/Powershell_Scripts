get-aduser -f {(Enabled -eq $true )-and ((name -like '*skills*') -or (name -like '*admin') -or 
(name -like 'HR*') -or (name -like 'don*') -or (name -like '*diet*') -or 
(name -like '*social*') -or (name -like '*MDS*') -or (name -like '*OF*'))} | Out-GridView