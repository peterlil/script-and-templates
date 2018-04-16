
# VARIABLES SECTIONS
# {

# Servername of the 
$serverName = 'PETERLIL1'

# An array of driveletters
$driveLetters = @('C')

# Path, excluding trailing backslash, to the folder where the trace files resides
$TraceFilesPath = 'C:\PerfLogs\Admin\VM Performance Trace';

# Output-path, excluding trailing backslash, for the resulting files. It empty, a folder with yyyyMMddHHmm will be created in $TraceFilesPath
$OutputPath = ''

# }


### Navigate to the folder of the trace files { ###
cd "c:\PerfLogs\Admin\VM Performance Trace"

#cd "C:\PerfLogs\Admin\VM Performance Trace\VM Performance Trace" 

### } Navigate to the folder of the trace files ###



### Generate the file for the selected counter sets { ###

$tempFileFI = New-TemporaryFile
Add-Content $tempFileFI "\\$serverName\Processor(_Total)\% Processor Time"
Add-Content $tempFileFI "\\$serverName\LogicalDisk($($driveLetter):)\Disk Bytes/sec"
Add-Content $tempFileFI "\\$serverName\LogicalDisk($($driveLetter):)\Transfers/sec"
Add-Content $tempFileFI "\\$serverName\Memory\Available MBytes"


### Generate the file for the selected counter sets } ###



### Migrate tsv-format files to binary format .blg { ###

$binFiles = @()
Get-Item *.tsv | ForEach-Object {
    $newFilename = $_.FullName.Replace($_.Extension, ".blg")
    relog.exe $_.FullName -f bin -o $newFilename -cf $tempFileFI.FullName
    $checkFile = Get-Item -Path $newFilename -ErrorAction SilentlyContinue
    # The 'last' file is most often locked as the performance trace is running. Then no output file is created.
    if( $checkFile ) {
        $fi = New-Object System.IO.FileInfo($newFilename) 
        $binFiles += $fi.Name;
    }
}


### Relog all individual binary files into one binary file at once { ###

$a = $binFiles
$a += "-f"
$a += "bin"
$a += "-o"
$a +=  "merged.blg"
relog.exe $a

### } Relog all tsv files as once ###


### If there is a problem with relogging all files at once, customize this script to fit your needs { ###

$files = Get-Item *.tsv.blg
$i = 1
$files | ForEach-Object {
    if(($i % 2) -eq 0) {
        relog.exe ('"' + $filename1 + '" "' + $_.FullName + '"') -f bin -o "merged$i.blg"
    } else {
        $filename1 = $_.FullName
    }
    $i++
} 

### } If there is a problem with relogging all files at once, customize this script to fit your needs ###
