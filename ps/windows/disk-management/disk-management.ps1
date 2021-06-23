
$diskDrives = Get-WmiObject -Class Win32_DiskDrive
$diskDriveToDiskPartitionMapping = Get-WmiObject -Class Win32_DiskDriveToDiskPartition
$logicalDiskToPartitionMapping = Get-WmiObject -Class Win32_LogicalDiskToPartition
$logicalDisk = Get-WmiObject -Class Win32_LogicalDisk

$diskDrive | ForEach-Object {
  if ($_)
  {
    
  }
}
