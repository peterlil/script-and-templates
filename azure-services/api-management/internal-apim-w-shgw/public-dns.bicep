param envName string
param appGwPublicIp string

resource peterlabsNetDns 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: 'peterlabs.net'
}

resource appgwPublicIpARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: '${envName}-configuration'
  parent: peterlabsNetDns
  properties: {
    TTL: 300
    ARecords: [
      {
        ipv4Address:appGwPublicIp
      }
    ]
  }
}
