# STEP 1: Sign-in to Azure via Azure Resource Manager

Login-AzureRmAccount

# STEP 2: Select Azure Subscription

$subscriptionId = 
    ( Get-AzureRmSubscription |
        Out-GridView `
          -Title "Select an Azure Subscription …" `
          -PassThru
    ).SubscriptionId

Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

# Option 1: Create and attach storage
$rgName = 'vm-infra-2'
$vmName = 'plweaz1ws2'
$location = 'West Europe' 
$storageType = 'Premium_LRS'
$zone = '1'

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName 


for ($i = 1; $i -lt 13; $i++) {
    $dataDiskName = $vmName + "_datadisk$i"

    $diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Empty -DiskSizeGB 1024 -Zone $zone

    $dataDisk = New-AzureRmDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName
    
    $vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun $i -Caching None

}

Update-AzureRmVM -VM $vm -ResourceGroupName $rgName

# Option 2: Only attach storage (storage already existing)
$rgName = 'vm-infra-2'
$vmName = 'plweaz1ws2'
$location = 'West Europe' 
$storageType = 'Premium_LRS'

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName 


for ($i = 1; $i -lt 13; $i++) {
    $dataDiskName = $vmName + "_datadisk$i"

    $dataDisk = Get-AzureRmDisk -ResourceGroupName $rgName -DiskName $dataDiskName
    
    $vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun $i -Caching None

}

Update-AzureRmVM -VM $vm -ResourceGroupName $rgName

