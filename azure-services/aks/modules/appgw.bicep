param location string
param appgwName string = 'aks-appgw'
param vnetName string = 'aks-vnet'
param appgwSubnetName string = 'appgw-subnet'

var publicFrontendIpConfigName = 'public-endpoint'
var frontendPublicIpName = 'frontend-public-ip'
var backendVnetConfig = 'backend-vnet'


resource frontendPublicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: frontendPublicIpName
  sku: {
    name:'Standard'
    tier:'Global'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName  
}

resource appgwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: appgwSubnetName
  parent: vnet
}

resource appgw 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: appgwName
  location: location
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 1
    }
    frontendIPConfigurations: [
      {
        name: publicFrontendIpConfigName
        properties: {
          publicIPAddress: {
            id: frontendPublicIp.id
          }
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: backendVnetConfig
        properties: {
          subnet: appgwSubnet
        }
      }
    ]
    sku: {
      capacity: 1
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
  }
}
