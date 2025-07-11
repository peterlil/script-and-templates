param location string

param vnetName string = 'aks-vnet'
param vnetCidr string = '10.224.0.0/12'           // 10.224.0.0     10.239.255.255
param aksNodeSubnetName string = 'aks-subnet'
param aksNodeSubnetCidr string = '10.224.0.0/24'  // 10.224.0.0     10.224.0.255
param appgwSubnetName string = 'appgw-subnet'
param appgwSubnetCidr string = '10.225.0.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCidr
      ]
    }
    subnets: [
      {
        name: aksNodeSubnetName
        properties: {
          addressPrefix: aksNodeSubnetCidr
        }
      }
      {
        name: appgwSubnetName
        properties: {
          addressPrefix: appgwSubnetCidr
        }
      }
    ]
  }
}

output vnetName string = vnet.name
