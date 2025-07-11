# List the disks on the system
Get-PhysicalDisk | Sort-Object DeviceId | Format-Table DeviceId, Size

# Get a reference to the physical disk to manage
$PhysicalDisk=Get-PhysicalDisk | Where-Object {$_.DeviceId -eq 2}

# View the properties of the physical disk to manage
$PhysicalDisk | Format-List *

# List the partitions of the physical disk
Get-Partition -DiskNumber $PhysicalDisk.DeviceId

# Remove the drive letter from the partion. Good to do before removing the partition
$DriveLetter='E'
Get-Volume -Drive $DriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$DriveLetter`:\"

# Remove all partitions on the disk (Note: WhatIf)
Get-Partition -DiskNumber $PhysicalDisk.DeviceId | Remove-Partition -WhatIf

# Create a partition that spans the whole disk
New-Partition -DiskNumber $PhysicalDisk.DeviceId -UseMaximumSize -DriveLetter 'X' -MbrType FAT32

# Format a partition as NTFS
$DriveLetter='E'
Format-Volume -DriveLetter $DriveLetter -FileSystem NTFS -Force

# Format a partition as FAT32 (32 GB max limit)
$DriveLetter='E'
Format-Volume -DriveLetter $DriveLetter -FileSystem FAT32 -Force

# Create the same partition and format it (NTFS) in one step
New-Partition -DiskNumber $PhysicalDisk.DeviceId -UseMaximumSize -DriveLetter 'X' -MbrType FAT32 | `
    Format-Volume -FileSystem NTFS -Force

# Create the same partition and format it (FAT32) in one step
New-Partition -DiskNumber $PhysicalDisk.DeviceId -UseMaximumSize -DriveLetter 'X' -MbrType FAT32 | `
    Format-Volume -FileSystem FAT32 -Force

# Check a volume for problems
Repair-Volume -DriveLetter 'X' -Scan

# Assign a drive letter to a partion. Find the UniqueId with Get-Volume | Format-List *
$UniqueId = '\\?\Volume{b3f86a47-32d1-11ea-89dc-2816a8560a30}\'
$DriveLetter='E'
$PartitionNumber=1
Get-Volume -UniqueId $UniqueId | `
    Get-Partition | `
    Where-Object {$_.PartitionNumber -eq $PartitionNumber } | `
    Add-PartitionAccessPath -accesspath "$DriveLetter`:\"

