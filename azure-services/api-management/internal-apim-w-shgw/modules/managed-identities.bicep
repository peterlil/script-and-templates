param location string
param envName string

resource apimMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: '${envName}-apim-identity'
  location: location
}

