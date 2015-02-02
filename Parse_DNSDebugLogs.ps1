#this script pulls in a DNS log and parses it for unique DNS records
#
$path = ".\dns2.txt " #Location where DNS Debug log is placed.
$fulllogpath = "fulllogpath.txt" #The location and file name where the full log is placed (has duplicates)
$trimmeddns = "trimmeddns.txt" #The location where the final trimmed dns records go.
$amount = 112 #How much of the debug log should be trimmed away.
    
ForEach($line in (Get-content $path))
     { 
    
     if ($line.length -gt $amount) {
        
        if($line -match "(3)"){
            $line = $line -replace "\(3\)","."
        }
        if($line -match '(0)'){
            $line = $line -replace '\(0\)',''
       }
       if($line -match '(16)'){
            $line = $line -replace '\(16\)','.'
       }
       if($line -match '(5)'){
            $line = $line -replace '\(5\)','.'
       }
       if($line -match '(9)'){
            $line = $line -replace '\(9\)','.'
       }
       if($line -match '(4)'){
            $line = $line -replace '\(4\)','.'
       }
       if($line -match '(6)'){
            $line = $line -replace '\(6\)','.'
       }
       if($line -match '(2)'){
            $line = $line -replace '\(2\)','.'
       }
       if($line -match '(7)'){
            $line = $line -replace '\(7\)','.'
       }
       if($line -match '(8)'){
            $line = $line -replace '\(7\)','.'
       }
       if($line -match '(1)'){
            $line = $line -replace '\(1\)','.'
       }
       if($line -match '(14)'){
            $line = $line -replace '\(14\)','.'
       }
       if($line -match '(10)'){
            $line = $line -replace '\(10\)','.'
       }
       if($line -match '(13)'){
            $line = $line -replace '\(13\)','.'
       }
       if($line -match '(12)'){
            $line = $line -replace '\(12\)','.'
       }
       if($line -match '(8)'){
            $line = $line -replace '\(8\)','.'
       }
       if($line -match '(15)'){
            $line = $line -replace '\(15\)','.'
       }
       if($line -match '(11)'){
            $line = $line -replace '\(11\)','.'
       }
        if($line -match '(19)'){
            $line = $line -replace '\(19\)','.'
       }
       if($line -match '(17)'){
            $line = $line -replace '\(17\)','.'
       }
       if($line -match '(21)'){
            $line = $line -replace '\(21\)','.'
       }
      Add-Content $fulllogpath $line.Substring($amount+1)} 
      
     }
     
Add-content $trimmedDNS Log ((Get-Content $fulllogpath).ToLower() | Sort-Object |Get-Unique )