# Receiver
$ReceiverIp = '10.2.0.5';
$NtttcpPath = 'C:\Users\peterlil\Downloads\NTttcp-v5.33\amd64fre\ntttcp.exe'
$NumberOfCores = 4;
$ThreadsPerCore = 4;
$Async = $true;


$AsyncParam = "";
if($Async) {
    $AsyncParam = " -a 4";
}

for($iCore = 0; $iCore -lt $NumberOfCores; $iCore++) {
    for($iThread = 0; $iThread -lt $ThreadsPerCore; $iThread++) {
        $Threads = $iCore*$ThreadsPerCore + ($iThread + 1);
        $Command = 
@"
cmd.exe /C $NtttcpPath -r -m $Threads,$iCore,$ReceiverIp$AsyncParam
"@
        $Command
        Invoke-Expression -Command:$Command
    }
}
