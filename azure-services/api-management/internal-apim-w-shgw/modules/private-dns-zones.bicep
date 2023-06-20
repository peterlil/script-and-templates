param envName string

var vnetName = '${envName}-vnet'

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
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

resource mgmtARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'mgmt-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '10.20.0.4'
      }
    ]
  }
}

resource devARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'dev-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '10.20.0.4'
      }
    ]
  }
}

resource portalARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'portal-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '10.20.0.4'
      }
    ]
  }
}

resource proxyARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'proxy-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '10.20.0.4'
      }
    ]
  }
}

resource scmARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'scm-apim'
  parent: apimPrivateDns
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '10.20.0.4'
      }
    ]
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

resource configARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'goofy-apim'
  parent: apimPrivateDnsDefault
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '10.20.0.4'
      }
    ]
  }
}
