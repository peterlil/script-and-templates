
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


# Script below creates a storage pool from a hardcoded set of DiskNumber values.

# Creating Storage Pool from hardcoded Get-Disk numbers
$DiskNumbers = @(2, 3, 7, 8)
$SPFnHardcoded = "datafiles-hardcoded"

$Storage = Get-StorageSubSystem
$allPhysicalDisks = Get-PhysicalDisk

$SelectedPhysicalDisks = foreach ($diskNumber in $DiskNumbers) {
    $msftDisk = Get-CimInstance -Namespace root/microsoft/windows/storage -ClassName MSFT_Disk -Filter "Number=$diskNumber" -ErrorAction SilentlyContinue
    if (-not $msftDisk) {
        throw "DiskNumber '$diskNumber' was not found."
    }

    $associatedPhysical = Get-CimAssociatedInstance -InputObject $msftDisk -ResultClassName MSFT_PhysicalDisk -ErrorAction SilentlyContinue
    if (-not $associatedPhysical) {
        throw "DiskNumber '$diskNumber' could not be mapped to a physical disk."
    }

    foreach ($pd in $associatedPhysical) {
        $match = $allPhysicalDisks | Where-Object { $_.UniqueId -eq $pd.UniqueId }
        if ($match) { $match }
    }
}

$SelectedPhysicalDisks = $SelectedPhysicalDisks | Sort-Object UniqueId -Unique
$NotPoolable = $SelectedPhysicalDisks | Where-Object { -not $_.CanPool }
if ($NotPoolable) {
    throw "One or more selected disks are not poolable: $($NotPoolable.FriendlyName -join ', ')"
}

if ($SelectedPhysicalDisks.Count -ne $DiskNumbers.Count) {
    throw "Expected $($DiskNumbers.Count) physical disks from DiskNumber list, found $($SelectedPhysicalDisks.Count)."
}

New-StoragePool -FriendlyName $SPFnHardcoded -StorageSubSystemUniqueId $Storage.UniqueId -PhysicalDisks $SelectedPhysicalDisks
