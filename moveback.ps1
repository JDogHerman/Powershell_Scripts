Import-Csv 'c:\script\moveback_full.csv' | `

Foreach {$computer = get-QADComputer -name $_.computer; `

if ($computer -eq $null) {Write-Output "$_.computer bad object`n"}

       else {move-QADObject $computer -to $_.target }

      }