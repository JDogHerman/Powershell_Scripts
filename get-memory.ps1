function Get-Memory {
    do {
        $comp = Read-Host "Enter server name"
        $cred = Get-Credential
        $OS = gwmi  Win32_OperatingSystem -ComputerName $comp -Credential $cred | Select TotalVisibleMemorySize
        $RAM = gwmi  Win32_MemoryDevice -ComputerName $comp -Credential $cred| Select DeviceID, StartingAddress, EndingAddress
        $RAM | ft DeviceID, @{Label = "Module Size(MB)"; Expression = {
        (($_.endingaddress - $_.startingaddress) / 1KB).tostring("F00")}} -AutoSize
        "Total Memory: `n`t" + ($OS.TotalVisibleMemorySize / 1KB).tostring("F00") + " MB`n"
    } while ($true)
}