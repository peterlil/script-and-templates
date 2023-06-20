param location string
param envName string

resource apimMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: '${envName}-apim-identity'
  location: location
}

resource appGwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: '${envName}-appgw-identity'
  location: location
}
