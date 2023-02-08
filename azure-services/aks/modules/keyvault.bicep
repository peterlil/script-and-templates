param location string
param kvName string = 'aks-kv-metallica'
param objectIdOfUser string
param appGwMiName string

var skuName = 'standard'

resource appgwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: appGwMiName
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: kvName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    accessPolicies:[
      {
        objectId: objectIdOfUser
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'backup'
            'restore'
          ]
          secrets:[
            'all'
          ]
          certificates: [
            'all'
          ]
        }
      }
      {
        objectId: appgwMi.properties.principalId
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'backup'
            'restore'
          ]
          secrets:[
            'all'
          ]
          certificates: [
            'all'
          ]
        }
      }
    ]
  }
}
