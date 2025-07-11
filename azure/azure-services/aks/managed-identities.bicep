param location string
param appGwMiName string = 'appgw-identity'
param aksMiName string = 'aks-identity'
param ingressAppGwMiName string = 'ingress-app-gw-identity'

resource appgwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: appGwMiName
  location: location
}

resource aksMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: aksMiName
  location: location
}

resource ingressAppGwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = { 
  name: ingressAppGwMiName
  location: location
}

