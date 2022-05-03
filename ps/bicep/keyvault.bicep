param location string = resourceGroup().location
param keyVaultName string
param sku string
param objectIdOfUser string
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  location: location
  name: keyVaultName
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    sku: {
      name: sku
      family: 'A'
    }
    tenantId: subscription().tenantId
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
    ]
  }
}

/*
 PowerShell
 az deployment group create -g kvtest98 `
  --parameters `@azuredeploy.keyvault.parameters.json `
  --parameters keyVaultName=kvtest98 objectIdOfUser=<object-id> `
  --template-file keyvault.bicep `
  --mode complete
*/

