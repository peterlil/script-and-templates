// Test VM to validate stuff

param location string
param envName string
param vmUsername string
@secure()
param vmPassword string

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: 'goofy-vnet/apim-subnet'
}

resource vmPublicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${envName}-vm-public-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${envName}-vm'
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${envName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: apimSubnet.id
          }
          publicIPAddress: {
            id: vmPublicIp.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: '${envName}-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_F16s_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-ent'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: '${envName}-vm'
      adminUsername: vmUsername
      adminPassword: vmPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
