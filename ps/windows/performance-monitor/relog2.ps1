
# VARIABLES SECTIONS
# {

# Path, excluding trailing backslash, to the folder where the trace files resides
$TraceFilesPath = 'C:\PerfLogs\Admin\VM Performance Trace';

# Output-path, excluding trailing backslash, for the resulting files. It empty, a folder with yyyyMMddHHmm will be created in $TraceFilesPath
$OutputPath = ''

# }


# { Initialize

# Create the output path string if no path wass given.
if ( [string]::IsNullOrEmpty($OutputPath) ) { $OutputPath = [System.IO.Path]::Combine( $TraceFilesPath, [DateTime]::Now.ToString( 'yyyyMMddHHmm' ) ) }

# }


# Create the output path folder if it does not exists
if ( !( [System.IO.File]::Exists( $OutputPath ) ) ) {
    [System.IO.File]::Create( $OutputPath );
}

      