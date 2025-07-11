
# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName RG-Workloads -Location westeurope -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "hackathonvm1-$(Get-Random)"



# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name hackathonNsgRuleRDP  -Protocol Tcp `
    -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80 (not sure if this will be needed for the hackathon...)
$nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name hackathonNsgRuleWWW  -Protocol Tcp `
    -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName RG-Workloads -Location westeurope `
    -Name hackathonNsg -SecurityRules $nsgRuleRDP,$nsgRuleWeb


# Get a reference to the vnet
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName RG-Shared -Name vnet-hackathon



# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name hackthonVm1Nic -ResourceGroupName RG-Workloads -Location westeurope `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id



# Define a credential object for the vm administrator
$cred = Get-Credential

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName hackathonVm1 -VMSize Standard_DS2 | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName hackathonVm1 -Credential $cred | `
    Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer `
    -Skus 2016-Datacenter -Version latest | Add-AzureRmVMNetworkInterface -Id $nic.Id

$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name "hackathonVm1-osdisk" -StorageAccountType PremiumLRS -CreateOption FromImage

New-AzureRmVM -ResourceGroupName RG-Workloads -Location westeurope -VM $vmConfig
# NOTE: The warning message blow that appears is invalid, the disk is created using Standard storage, not Premium.
# "WARNING: Since the VM is created using premium storage, existing standard storage account, XYZ, is used for boot diagnostics."
