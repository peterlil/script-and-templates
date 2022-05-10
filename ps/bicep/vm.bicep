param location string = 'sweden central'

param vmName string = 'vm-${uniqueString(resourceGroup().name)}'
param vmSize string = 'Standard_E4ds_v5'
param timeZone string = 'Central European Standard Time'

param adminUsername string = 'vmhero'
@secure()
param adminPassword string

param subnetName string = 'default'
param vnetName string = 'vnet-${replace(location, ' ', '-')}'
param ipAllocationMethod string = 'Static'

param dataDisks array

resource subnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${vnetName}/${subnetName}'  
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
        }
      }
    ]
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
      imageReference:{
        offer:'sql2019-ws2022'
        sku:'sqldev'
        publisher:'MicrosoftSQLServer'
        version:'15.0.220412'
      }
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

//az deployment group create -g test --mode complete --template-file .\ps\bicep\sql-vms-ag.bicep --parameters .\ps\bicep\sql-vms-ag.parameters.json --parameters adminPassword=
