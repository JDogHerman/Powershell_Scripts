#this script pulls the event log and parses the computername for all machines having an error
#authenticating to the domain
#5722/6 - 5805/6 - 5723/5

$id = 5805
$index = 6 
$computername = 'tsgdc2.tsg.ds'
$daysinpast = 5

$afterdate = (Get-Date).AddDays(-$daysinpast)

$message = Get-WinEvent -FilterHashtable @{StartTime = $afterdate;logname='system'; id=$id} -ComputerName $computername | Select-Object Message

$list = foreach ($line in $message) {
    
    $line.Message.split(" ")[$index]

}

$list -replace ("'",'') | sort-object | Get-Unique