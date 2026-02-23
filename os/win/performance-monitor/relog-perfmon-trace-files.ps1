
function Invoke-RelogPerfmonTraceFiles {
    [CmdletBinding()]
    param(
        # Search pattern for .tsv trace files, e.g. 'C:\PerfLogs\Admin\VM Performance Trace\*.tsv'
        [string]$TraceFileSearchPattern = '.\*.tsv',

        # Output path for resulting files
        [string]$OutputPath = ''
    )
    
    ### Load trace files matching the search pattern
    $traceFiles = Get-Item $TraceFileSearchPattern
    
    ### Extract counter names from the first trace file and save to a temporary file
    $counterNamesFile = [System.IO.Path]::GetTempFileName()
    Write-Verbose "Extracting counter names from '$($traceFiles[0].FullName)' to '$counterNamesFile'"
    Get-PerfmonTraceCounters -Path $traceFiles[0].FullName -OutputFile $counterNamesFile
    
    
    ### Migrate tsv-format files to binary format
    $binFiles = @()
    $traceFiles | ForEach-Object {
        $newFilename = Join-Path $_.DirectoryName ($_.BaseName + '.blg')
        Write-Verbose "Relogging '$($_.FullName)' to '$newFilename'"
        relog.exe $_.FullName -f bin -o $newFilename -cf $counterNamesFile
        $checkFile = Get-Item -Path $newFilename -ErrorAction SilentlyContinue
        # The 'last' file is most often locked as the performance trace is running. Then no output file is created.
        if( $checkFile ) {
            $fi = New-Object System.IO.FileInfo($newFilename)
            $binFiles += $fi.Name
        }
    }
    
    
    ### Relog all individual binary files into one binary file at once { ###

    #    $a = $binFiles
    #    $a += "-f"
    #    $a += "bin"
    #    $a += "-o"
#    $a +=  "merged.blg"
#    relog.exe $a

    ### } Relog all tsv files at once ###


    ### If there is a problem with relogging all files at once, customize this script to fit your needs { ###

#    $files = Get-Item *.tsv.blg
#    $i = 1
#    $files | ForEach-Object {
#        if(($i % 2) -eq 0) {
#            relog.exe ('"' + $filename1 + '" "' + $_.FullName + '"') -f bin -o "merged$i.blg"
#        } else {
#            $filename1 = $_.FullName
#        }
#        $i++
#    }

    ### } If there is a problem with relogging all files at once, customize this script to fit your needs ###
}


function Get-PerfmonTraceCounters {
<#
.SYNOPSIS
Reads the counter names from a TSV-formatted Performance Monitor trace file.
.DESCRIPTION
Performance Monitor TSV files store counter paths as tab-separated column headers
on the first line. This cmdlet reads that header, strips the timestamp column,
and outputs each counter path. Results can optionally be written to a file.
.PARAMETER Path
Path to the TSV-formatted Performance Monitor trace file.
Accepts pipeline input, including FileInfo objects from Get-Item/Get-ChildItem.
.PARAMETER OutputFile
Optional path to write the counter list to. One counter per line.
.EXAMPLE
Get-PerfmonTraceCounters -Path "C:\PerfLogs\Admin\VM Performance Trace\DataCollector01.tsv"
.EXAMPLE
Get-Item *.tsv | Select-Object -First 1 | Get-PerfmonTraceCounters -OutputFile counters.txt
#>
[CmdletBinding()]
param(
    # Path to the TSV-formatted Performance Monitor trace file
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]$Path,
    
    # Optional path to write the counter list to a file (one counter per line)
    [string]$OutputFile = ''
    )
    
    process {
        # The first line is the header row; columns are tab-separated and may be quoted
        $headerLine = Get-Content -Path $Path -TotalCount 1
        
        # Split on tab, skip column 0 (timestamp header), remove surrounding double-quotes
        $counters = ($headerLine -split "`t" | Select-Object -Skip 1) -replace '^"|"$', ''
        
        
        # Optionally persist to a file
        if ($OutputFile) {
            $counters | Set-Content -Path $OutputFile
            Write-Verbose "Counter list written to '$OutputFile'"
        }
        else {
            # Write to the pipeline
            $counters
        }
    }
}
        
        
# Invoke-RelogPerfmonTraceFiles -TraceFileSearchPattern 'c:\l\pe\cx\SEB\traces-and-logs\1\*.tsv' -Verbose
# relog.exe 'c:\l\pe\cx\SEB\traces-and-logs\SEB-SQLPR-04-20260219-0001.tsv' -f bin -o 'c:\l\pe\cx\SEB\traces-and-logs\SEB-SQLPR-04-20260219-0001.blg' -cf 'c:\Users\liljepet\AppData\Local\Temp\tmpm0epvr.tmp'