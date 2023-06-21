targetScope = 'subscription'

param resourceGroupName string
param location string
param envName string
// User id for kv permissions
param objectIdOfUser string
param apimPrivateIp string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
}

module mi 'modules/managed-identities.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'managed-identities'
  params: {
    location: location
    envName: envName
  }
}

module kv 'modules/keyvault.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'keyvault'
  dependsOn: [
    mi
  ]
  params: {
    location: location
    envName: envName
    objectIdOfUser: objectIdOfUser
  }
}

module apimPre 'modules/apim-pre.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'apim-pre'
  params: {
    location: location
    envName: envName
    apimPrivateIp: apimPrivateIp
  }
}
