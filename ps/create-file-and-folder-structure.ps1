# 700 objects (files and folders)

$totalObjectCount = 700
$fileCount = $totalObjectCount - $folderCount
$Depth = 3

$folderLevels = @(1,5,10)
$folderCount = $folderLevels[$folderLevels.Count - 2] * $folderLevels[$folderLevels.Count - 1]

$filesPerFolder = [Math]::Floor($fileCount / $folderCount)



$folder = 'c:\l\temp'

function New-FolderHierarchy {
    param(
        $Folder,
        $Depth,
        $CurrentDepth,
        $FolderLevels,
        $FilesPerFolder
    )

    "Current Depth: $CurrentDepth"
    #$sourceFiles = @('c:\l\temp\1\1.txt', 'c:\l\temp\1\10.txt', 'c:\l\temp\1\100.txt');
    $sourceFiles = @('c:\l\temp\1\1.txt', 'c:\l\temp\1\1.txt', 'c:\l\temp\1\1.txt');
    
    $folderToCreateOnThisLevel = $FolderLevels[$CurrentDepth]
    for($i = 0; $i -lt $folderToCreateOnThisLevel; $i++) {
        
        if($CurrentDepth -lt $Depth) {
            $folderName = "folder$(Get-Random -Minimum 1000 -Maximum 100000)"
            $folderName
            $newFolder = New-Item -Path "$($folder)" -Name $($folderName) -ItemType Directory
            New-FolderHierarchy -Folder $newFolder.FullName -Depth $Depth -CurrentDepth ($CurrentDepth + 1) -FolderLevels $folderLevels -FilesPerFolder $filesPerFolder
        }
    }

    if($CurrentDepth -eq $Depth) {
        "STOP THE PRESS"
        for($j = 0; $j -lt $FilesPerFolder; $j++) {
            $fileName = "File$(Get-Random -Minimum 1000 -Maximum 100000)"
            $rand = Get-Random -Minimum 0 -Maximum 3

            ""
            $sourceFiles[$rand]
            "$($Folder)\$($fileName)"

            Copy-Item -Path $sourceFiles[$rand] -Destination "$($Folder)\$($fileName)"
        }
    }

}


New-FolderHierarchy -Folder $folder -Depth $Depth -CurrentDepth 0 -FolderLevels $folderLevels -FilesPerFolder $filesPerFolder


