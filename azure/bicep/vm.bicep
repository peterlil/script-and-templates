param location string = 'sweden central'

param vmName string = 'vm-${substring(uniqueString(resourceGroup().name), 0, 5)}'
param vmSize string = 'Standard_E4ds_v5'
param timeZone string = 'Central European Standard Time'

param adminUsername string = 'vmhero'
@secure()
param adminPassword string

param subnetName string = 'default'
param vnetName string = 'vnet-${replace(location, ' ', '-')}'
param ipAllocationMethod string = 'dynamic'
param nsgSourceIp string
// Avoid to create an nsg on the VM's NIC if you want jit to work on the subnet nsg.
param createVmInterfaceNsg bool = true

param dataDisks array

param imageReference object = {
  offer:'windows-11'
  sku:'win11-21h2-ent'
  publisher:'MicrosoftWindowsDesktop'
  version:'22000.856.220805'
}

resource subnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${vnetName}/${subnetName}'  
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'ip-${vmName}'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings:{
      domainNameLabel:vmName
    }
  }
  sku:{
    name: 'Standard'
    tier: 'Regional'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = if (createVmInterfaceNsg) {
  name: '${vmName}-rdp-nsg'
  location: location
  properties: {}
}

resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = if (createVmInterfaceNsg) {
  name: '${vmNic.name}-rdp-nsg-rule'
  parent: nsg
  properties: {
    access: 'Allow'
    description: 'rdp-to-${vmName}'
    destinationAddressPrefix: vmNic.properties.ipConfigurations[0].properties.privateIPAddress
    destinationPortRange: '3389'
    direction: 'Inbound'
    priority: 1001
    protocol: 'Tcp'
    sourceAddressPrefix: nsgSourceIp
    sourcePortRange: '*'
  }
}


resource vmNic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${vmName}-ip-config'
        properties: {
          subnet:{
            id: subnetRef.id
          }
          privateIPAllocationMethod: ipAllocationMethod
          publicIPAddress:{
            properties:{
              deleteOption:'Delete'
            }
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIPAddresses', publicIp.name)
          }
        }
      }
    ]
    networkSecurityGroup: createVmInterfaceNsg ? { id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', nsg.name) } : null
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  location:location
  name: vmName
  properties: {
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled:true
      }
    }
    hardwareProfile: {
      vmSize:vmSize
    }
    networkProfile: {
      networkInterfaces:[
        {
          id: vmNic.id
        }
      ]
    }
    osProfile:{
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration:{
        timeZone:timeZone
      }
    }
    storageProfile:{
      osDisk:{
        name: '${vmName}-os-disk'
        createOption:'FromImage'
      }
      imageReference:imageReference
      dataDisks: [for (disk,i) in dataDisks: {
        createOption:'Empty'
        lun: i
        deleteOption: disk.deleteOption
        caching: disk.caching
        diskSizeGB: disk.diskSizeInGB
        managedDisk: {
          storageAccountType: disk.storageAccountType
        }
        name: '${vmName}-${disk.name}'
      }]
    }
  }
}


// [System.TimeZoneInfo]::GetSystemTimeZones() | Select-Object -ExpandProperty Id

// Script block to use when template gets password from key vault
/*

az login
az account show
$rgName='vm-test'
$location='swedencentral'
az group create -g $rgName -l $location

$myPublicIp=$(curl ifconfig.me)

az deployment group create `
  -g $rgName `
  --mode complete `
  --template-file .\ps\bicep\vm.bicep `
  --parameters .\ps\bicep\vm.parameters.json `
  --parameters nsgSourceIp=$myPublicIp

*/

// Script block to use when suppling password
/*

az login
az account show
$rgName='vm-test'
$location='swedencentral'
az group create -g $rgName -l $location

$pwd = az keyvault secret show -n 'common-vm-credentials' `
        --subscription (az account show --query 'id' -o tsv) `
        --vault-name devboxes-vm-encrypt `
        --query "value" `
        -o tsv

$myPublicIp=$(curl ifconfig.me)

az deployment group create `
  -g $rgName `
  --mode complete `
  --template-file .\ps\bicep\vm.bicep `
  --parameters .\ps\bicep\vm.parameters.json `
  --parameters nsgSourceIp=$myPublicIp adminPassword=$pwd

*/
