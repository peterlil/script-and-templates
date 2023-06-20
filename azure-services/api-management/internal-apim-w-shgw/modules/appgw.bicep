param location string
param envName string
@secure()
param configEndpointCertificateSecretId string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: '${envName}-vnet'
}
  
resource appgwSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'appgw-subnet'
  parent: vnet
  properties: {
    addressPrefix: '10.20.1.0/24'
  }
}

resource appgwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = { 
  name: '${envName}-appgw-identity'
}

resource appgwPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: '${envName}-appgw-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings:{
      domainNameLabel: '${envName}-appgw'
    }
  }
  sku: {
    name: 'Standard'
  }
}

resource appGw 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: '${envName}-appgw'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appgwMi.id}': {}
    }
  }
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'
        properties: {
          subnet: {
            id: appgwSubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: appgwPublicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: '${envName}-backend-pool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${envName}-apim.configuration.azure-api.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: '${envName}-backend-http-settings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: '${envName}-apim.configuration.azure-api.net'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: '${envName}-appgw-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${envName}-appgw', 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${envName}-appgw', 'port_443')
          }
          protocol: 'Https'
          hostName: '${envName}-configuration.peterlabs.net'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', '${envName}-appgw', '${envName}-configuration')
          }
        }
      }
    ]
    enableHttp2: false
    sslCertificates: [
      {
        name: '${envName}-configuration'
        properties: {
          keyVaultSecretId: configEndpointCertificateSecretId
        }
      }
    ]
    requestRoutingRules: [
      {
        name: '${envName}-routing-rule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${envName}-appgw', '${envName}-appgw-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${envName}-appgw', '${envName}-backend-pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${envName}-appgw', '${envName}-backend-http-settings')
          }
        }
      }
    ]
  }
}


