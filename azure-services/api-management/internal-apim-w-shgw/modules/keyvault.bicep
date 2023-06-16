param location string
param envName string
param objectIdOfUser string

var skuName = 'standard'

resource apimMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: '${envName}-apim-identity'
  location: location
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${envName}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    accessPolicies: [
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
        objectId: apimMi.properties.principalId
        tenantId: subscription().tenantId
        permissions: {
          secrets:[
            'get'
          ]
          certificates: [
            'get'
            'getissuers'
            'list'
            'listissuers'
          ]
        }
      }
    ]
  }
}

output keyVaultName string = kv.name
