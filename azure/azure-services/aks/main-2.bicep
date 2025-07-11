// Resource group
param location string = 'sweden central'

// aks
param clusterName string = 'labcluster'
param clusterAdminName string
param sshRSAPublicKey string
param vnetName string
param ingressAppGwMiName string
param aksMiName string

// acr
param acrName string = 'acrforlabcluster'

////////////////////////////////////////////////////////////////////////////////
///// Module: AKS
module aks 'modules/aks.bicep' = {
  scope: resourceGroup()
  name: 'aks'
  params: {
    location: location
    clusterName: clusterName
    linuxAdminUsername: clusterAdminName
    sshRSAPublicKey: sshRSAPublicKey
    vnetName: vnetName
    ingressAppGwMiName: ingressAppGwMiName
    aksMiName: aksMiName
  }
}
///// Module: AKS
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: ACR
module acr 'modules/acr.bicep' = {
  scope: resourceGroup()
  name: 'acr'
  params: {
    location: location
    acrName: acrName
  }
}
///// Module: ACR
////////////////////////////////////////////////////////////////////////////////

