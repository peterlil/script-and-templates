# Load the disk, partition and logical disk information
$diskDrives = Get-CimInstance -Class Win32_DiskDrive | Sort-Object -Property DeviceID
$diskDriveToDiskPartitionMappings = Get-CimInstance -Class Win32_DiskDriveToDiskPartition
$diskPartitions = Get-CimInstance -Class Win32_DiskPartition
$logicalDiskToPartitionMappings = Get-CimInstance -Class Win32_LogicalDiskToPartition
$logicalDisks = Get-CimInstance -Class Win32_LogicalDisk

# Not sure if Win32_Volume is depricated or not. It's the only place I found the name on the system reserved 
# partitions, but right now it's not being used.
#$volumes = Get-CimInstance -Class Win32_Volume

$list = $diskDrives | ForEach-Object {
  $diskDrive = $_
  if ($_)
  {
    # Get partition mappings for the current drive
    $diskDriveToDiskPartitionMapping = $diskDriveToDiskPartitionMappings |
      Where-Object { $_.Antecedent.DeviceID -eq $diskDrive.DeviceID }
      
    if($diskDriveToDiskPartitionMapping) {
      $diskDriveToDiskPartitionMapping | ForEach-Object {
        $partitionMapping = $_
        $diskPartition = $diskPartitions | 
          Where-Object { $_.Name -eq $partitionMapping.Dependent.DeviceID }

        $logicalDiskToPartitionMapping = $logicalDiskToPartitionMappings |
            Where-Object { $_.Antecedent.DeviceID -eq $partitionMapping.Dependent.DeviceID }
        
        if($logicalDiskToPartitionMapping) {
          $logicalDisk = $logicalDisks |
            Where-Object {$_.DeviceID -eq $logicalDiskToPartitionMapping.Dependent.DeviceID}
        }

        if($logicalDisk.DeviceID)
        {
            $deviceId = $logicalDisk.DeviceID
        }
        New-Object -TypeName PSObject -Property @{
          DeviceId = $deviceId
          LUN = $DiskDrive.SCSILogicalUnit
          SCSIBus = $DiskDrive.SCSIBus
          SCSIPort = $DiskDrive.SCSIPort
          SCSITargetId = $DiskDrive.SCSITargetId
          SCSILogicalUnit = $DiskDrive.SCSILogicalUnit
          DiskIndex = $DiskDrive.Index
          DiskPartitions = $DiskDrive.Partitions
          DiskInterfaceType = $DiskDrive.InterfaceType
          DiskSize = $DiskDrive.Size
          DiskSizeGB = [math]::Round($DiskDrive.Size / (1024*1024*1024))
          DiskStatus = $DiskDrive.Status
          PartitionIndex = $diskPartition.Index
          PartitionName = $diskPartition.Name
          PartitionSize = $diskPartition.Size
          PartitionSizeGB = [math]::Round($diskPartition.Size / (1024*1024*1024), 1)
          PartitionIsBoot = $diskPartition.BootPartition
        }
      }
    } else {
      New-Object -TypeName PSObject -Property @{
        DeviceId = $deviceId
        LUN = $DiskDrive.SCSILogicalUnit
        SCSIBus = $DiskDrive.SCSIBus
        SCSIPort = $DiskDrive.SCSIPort
        SCSITargetId = $DiskDrive.SCSITargetId
        SCSILogicalUnit = $DiskDrive.SCSILogicalUnit
        DiskIndex = $DiskDrive.Index
        DiskPartitions = $DiskDrive.Partitions
        DiskInterfaceType = $DiskDrive.InterfaceType
        DiskSize = $DiskDrive.Size
        DiskSizeGB = [math]::Round($DiskDrive.Size / (1024*1024*1024), 1)
        DiskStatus = $DiskDrive.Status
        PartitionIndex = $null
        PartitionName = $null
        PartitionSize = $null
        PartitionSizeGB = $null
        PartitionIsBoot = $null
      }
    }
    $logicalDisk = $null
    $logicalDiskToPartitionMapping = $null
    $diskDriveToDiskPartitionMapping = $null
    $deviceId = $null
    $diskPartition = $null
  }
}

$list | Format-Table DiskIndex, DeviceId, LUN, DiskPartitions, DiskInterfaceType, DiskSizeGB, SCSIBus, SCSIPort,
  SCSITargetId, SCSILogicalUnit, PartitionName, PartitionSizeGB






