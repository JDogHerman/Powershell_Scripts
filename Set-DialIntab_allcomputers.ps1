Get-ADComputer -Filter * -Properties Name, msNPAllowDialin | ForEach-Object {

    Set-ADComputer -identity $_.name -replace @{msnpallowdialin='TRUE'}
}

#Get-ADComputer -Filter {Name -like '*-LT*'} -Properties Name, msNPAllowDialin | select Name, msnpallowdialin