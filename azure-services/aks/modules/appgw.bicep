param location string
param appgwName string = 'aks-appgw'
param vnetName string = 'aks-vnet'
param appgwSubnetName string = 'appgw-subnet'
param appGwMiName string = 'appgw-identity'

var publicFrontendIpConfigName = 'public-endpoint'
var frontendPublicIpName = 'appgw-frontend-public-ip'
var frontendPortName = '${appgwName}-ip'
var frontendPortIpConfigDefaultPort = 80
var dummyBackendPort = 80
var appGwVnetConfigName = 'appGwVnetConfig'
var dummyListenerName = 'dummyListener'
var dummyRuleName = 'dummyRule'


resource frontendPublicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: frontendPublicIpName
  location: location
  sku: {
    name:'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource appgwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = { 
  name: appGwMiName
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
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appgwMi.id}': {}
    }
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: publicFrontendIpConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: frontendPublicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: frontendPortIpConfigDefaultPort
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: appGwVnetConfigName
        properties: {
          subnet: {
            id: appgwSubnet.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'dummyAddressPool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'dummyHttpSetting'
        properties: {
          port: dummyBackendPort
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name:dummyListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwName, publicFrontendIpConfigName)
          }
          protocol: 'Http'
          frontendPort:{
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, frontendPortName)
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: dummyRuleName
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgwName, 'dummyAddressPool')
          }
          backendHttpSettings: {
            id:resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appgwName, 'dummyHttpSetting')
          }
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, dummyListenerName)
          }
          priority: 19500
        }
      }
    ]
    sku: {
      capacity: 1
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
  }
}

output appGwMiName string = appGwMiName
