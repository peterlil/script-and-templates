# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name subnet-hackathon -AddressPrefix 10.100.0.0/24

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName RG-Shared -Location westeurope -Name vnet-hackathon -AddressPrefix 10.100.0.0/16 -Subnet $subnetConfig


