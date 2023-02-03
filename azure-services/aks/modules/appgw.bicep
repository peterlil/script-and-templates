// This bicep template is currently not used as it's easier to let the add-on create an appgw.
param location string
param appgwName string = 'aks-appgw'
param vnetName string = 'aks-vnet'
param appgwSubnetName string = 'appgw-subnet'

var publicFrontendIpConfigName = 'public-endpoint'
var frontendPublicIpName = 'appgw-frontend-public-ip'
var frontendPortTlsName = 'tls'
var frontendPortTlsPort = 443
var backendVnetConfig = 'backend-vnet'


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
  // SystemAssigned is not supported, UserAssigned TBD
  // identity: {
  //   type:'SystemAssigned'
  // }
  properties: {
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 1
    }
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
        name: frontendPortTlsName
        properties: {
          port: frontendPortTlsPort
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: backendVnetConfig
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
          port: frontendPortTlsPort
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
  }
}
