Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
	Script ConfigureStripeset
	{
		TestScript = {
			$SPFn = "datafiles"      #Storage Pool Friendly Name
			$pool = Get-StoragePool -FriendlyName $SPFn -ErrorAction SilentlyContinue
			($pool -ne $null)
		}
		SetScript = {
			# Execute locally on VM
			#Creating Storage Pool and assigning disks to this pool
			$DiskDeviceIdStart = 1   #Physical disks' device ID that is the starting disk to add to the pool
			$DiskDeviceCount   = 32  #Physical disks' device ID that is the ending disk to add to the pool
			$SPFn = "datafiles"      #Storage Pool Friendly Name
			$DriveLetter = 'F'
			$DiskSize = 67645734912  # Use 'Get-PhysicalDisk | ft Size' to get the size.
									 # Common sizes:
									 #  Bytes		| GB
									 # -----------------------------
									 # 67645734912  | 63

			$Storage = Get-StorageSubSystem
			#Get-PhysicalDisk | Format-Table FriendlyName,DeviceId, Size
			
			$PhysicalDisks = Get-PhysicalDisk | `
				Where-Object {
					(($_.Size) -eq $DiskSize)
				} #  | select FriendlyName, Size, DeviceID

			New-StoragePool -FriendlyName $SPFn -StorageSubSystemUniqueId $Storage.uniqueID -PhysicalDisks $PhysicalDisks

			#############################################################################
			### Creating Virtual Disk
			#############################################################################
			
			# Interleave - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-sql-performance
			$interleave = 256KB

			# Number of Columns - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-sql-performance
			# no of columns = count of disks.
			$disks = Get-StoragePool –FriendlyName $SPFn -IsPrimordial $false | Get-PhysicalDisk
			New-VirtualDisk –FriendlyName $SPFn -ResiliencySettingName Simple –NumberOfColumns $disks.Count `
				–UseMaximumSize –Interleave $interleave -StoragePoolFriendlyName $SPFn
			Get-VirtualDisk –FriendlyName $SPFn | `
				Get-Disk | `
				Initialize-Disk –Passthru | `
				New-Partition –DriveLetter $DriveLetter –UseMaximumSize | `
				Format-Volume –AllocationUnitSize 65536


		}
		GetScript = { @("") }
	}
  }
}