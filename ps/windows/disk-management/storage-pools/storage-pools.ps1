﻿
Get-PhysicalDisk | Sort-Object DeviceId | Format-Table DeviceId, Size

# Execute locally on VM
#Creating Storage Pool and assigning disks to this pool
$DiskDeviceIdStart = 2   #Physical disks' device ID that is the starting disk to add to the pool
$DiskDeviceCount   = 14  #Physical disks' device ID that is the ending disk to add to the pool
$SPFn = "datafiles"      #Storage Pool Friendly Name
$DriveLetter = 'M'
$DiskSize = 1099511627776 # Use 'Get-PhysicalDisk | Format-Table Size' to get the size.

$Storage = Get-StorageSubSystem
#Get-PhysicalDisk | Format-Table FriendlyName,DeviceId, Size
$PhysicalDisks = Get-PhysicalDisk | `
    Where-Object {
        ([int]($_.DeviceId) -ge $DiskDeviceIdStart) -and `
        ([int]($_.DeviceId) -lt $DiskDeviceCount) -and `
        (($_.Size) -eq $DiskSize)
    }  # | Select-Object FriendlyName, Size, DeviceID
New-StoragePool -FriendlyName $SPFn -StorageSubSystemUniqueId $Storage.uniqueID -PhysicalDisks $PhysicalDisks

#Creating Virtual Disk
$disks = Get-StoragePool –FriendlyName $SPFn -IsPrimordial $false | Get-PhysicalDisk
New-VirtualDisk –FriendlyName $SPFn -ResiliencySettingName Simple –NumberOfColumns $disks.Count `
    –UseMaximumSize –Interleave 64KB -StoragePoolFriendlyName $SPFn
Get-VirtualDisk –FriendlyName $SPFn | `
    Get-Disk | `
    Initialize-Disk –Passthru | `
    New-Partition –DriveLetter $DriveLetter –UseMaximumSize | `
    Format-Volume –AllocationUnitSize 65536


# Delete Volume, Partition, Disk
$DriveLetter = 'M'
Remove-Partition -DriveLetter $DriveLetter
Remove-VirtualDisk -FriendlyName $SPFn
#
#
Get-StoragePool -FriendlyName datafiles | Get-ResiliencySetting
Get-StoragePool -FriendlyName datafiles | Format-List *


