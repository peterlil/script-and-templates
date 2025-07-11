param envName string
param location string
param apimPrivateIp string
param vnetPrefixes array = [
  '10.20.0.0/16'
]
param apimSubnetPrefix string = '10.20.0.0/24'


var vnetName = '${envName}-vnet'
var apimSubnetName = 'apim-subnet'

resource nsgApimSubnet 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: '${envName}-apim-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-inbound-to-mgmt-endpoint'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'ApiManagement'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
        }
      }
      {
        name: 'allow-inbound-to-load-balancer'
        properties: {
          priority: 101
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '6390'
        }
      }
      {
        name: 'allow-outbound-to-storage'
        properties: {
          priority: 102
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
          destinationPortRange: '443'
        }
      }
      {
        name: 'allow-outbound-to-sql'
        properties: {
          priority: 103
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
          destinationPortRange: '1443'
        }
      }
      {
        name: 'allow-outbound-to-keyvault'
        properties: {
          priority: 104
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

// Virtual network for the APIM
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:vnetPrefixes
    }
    subnets: [
      {
        name: apimSubnetName
        properties:{
          addressPrefix: apimSubnetPrefix
          networkSecurityGroup: {
            id: nsgApimSubnet.id
          }
        }
      }
    ]
  }
}

resource apimPrivateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${envName}.peterlabs.net'
  location: 'global'
}

resource apimPrivateDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${envName}-apim-private-dns-link'
  location: 'global'
  parent: apimPrivateDns
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: true
  }
}

resource mgmtCNAMERecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: 'mgmt-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}

resource devCNAMERecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: 'dev-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}

resource portalCNAMERecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: 'portal-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}

resource proxyCNAMERecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: 'proxy-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}

resource scmCNAMERecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: 'scm-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}

resource configCNAMERecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: 'config-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}

resource apimPrivateDnsDefault 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'configuration.azure-api.net'
  location: 'global'
}

resource apimPrivateDnsDefaultLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${envName}-apim-private-dns-default-link'
  location: 'global'
  parent: apimPrivateDnsDefault
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

resource configCNAMERecordDnsDefault 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: '${envName}-apim'
  parent: apimPrivateDnsDefault
  properties: {
    ttl: 300
    cnameRecord: {
      cname: '${envName}-apim.azure-api.net'
    }
  }
}


resource apimPrivateDnsDefaultRoot 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net'
  location: 'global'
}

resource apimPrivateDnsDefaultRootLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${envName}-apim-private-dns-default-root-link'
  location: 'global'
  parent: apimPrivateDnsDefaultRoot
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

resource configCNAMERecordDnsDefaultRoot 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: '${envName}-apim'
  parent: apimPrivateDnsDefaultRoot
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: apimPrivateIp
      }
    ]
  }
}
