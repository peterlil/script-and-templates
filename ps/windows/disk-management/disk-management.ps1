
$diskDrives = Get-WmiObject -Class Win32_DiskDrive
$diskDriveToDiskPartitionMappings = Get-WmiObject -Class Win32_DiskDriveToDiskPartition
$logicalDiskToPartitionMappings = Get-WmiObject -Class Win32_LogicalDiskToPartition
$logicalDisks = Get-WmiObject -Class Win32_LogicalDisk


$diskDrives | Format-Table __Path
$diskDriveToDiskPartitionMappings | Format-Table Antecedent

$diskDrives | ForEach-Object {
  $diskDrive = $_
  if ($_)
  {
  
    #$logicalDiskToPartitionMapping = $logicalDiskToPartitionMappings | 
    #  Where-Object {  }

    

    $diskDriveToDiskPartitionMapping = $diskDriveToDiskPartitionMappings |
      Where-Object { $_.Antecedent -eq $diskDrive.__Path }
    
    New-Object -TypeName PSObject -Property @{
      Col1 = $diskDriveToDiskPartitionMapping.Antecedent
      SCSIBus = $DiskDrive.SCSIBus
      SCSIPort = $DiskDrive.SCSIPort
      SCSITargetId = $DiskDrive.SCSITargetId
      SCSILogicalUnit = $DiskDrive.SCSILogicalUnit
    }
  }
}
