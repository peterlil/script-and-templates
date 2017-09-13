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

 #$rgName = "test"
 #$vmName = "ds15v2-1"
 #Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force
#
 #ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vmName


$rgName = 'Test'
$vmName = 'ds15v2-1'
$location = 'West Europe' 
$storageType = 'PremiumLRS'

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName 


for ($i = 1; $i -lt 11; $i++) {
    $dataDiskName = $vmName + "_datadisk$i"

    $diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Empty -DiskSizeGB 1023

    $dataDisk = New-AzureRmDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName
    
    $vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun $i

}

Update-AzureRmVM -VM $vm -ResourceGroupName $rgName
