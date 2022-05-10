param location string = 'sweden central'
param vnetName string = 'vnet-${replace(location, ' ', '-')}'
param vnetAddressPrefixes array
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [for item in subnets: {
      name:item.name
      properties:{
        addressPrefix: item.addressPrefix
      }
    }]
  }
}
