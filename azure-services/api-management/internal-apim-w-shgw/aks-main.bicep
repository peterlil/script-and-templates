// Resource group
param location string
param envName string
param clusterAdminName string
param sshRSAPublicKey string


////////////////////////////////////////////////////////////////////////////////
///// Module: vnet
module vnet 'modules/aks-vnet.bicep' = {
  scope: resourceGroup()
  name: 'aks-vnet'
  params: {
    location: location 
    envName: envName
  }
}
///// Module: vnet
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: AKS
module aks 'modules/aks.bicep' = {
  scope: resourceGroup()
  name: 'aks'
  params: {
    location: location
    envName: envName
    linuxAdminUsername: clusterAdminName
    sshRSAPublicKey: sshRSAPublicKey
  }
}
///// Module: AKS
////////////////////////////////////////////////////////////////////////////////
