targetScope = 'subscription'

// Resource group
param location string = 'sweden central'
param resourceGroupName string = 'aks-lab'

// aks
param clusterName string = 'labcluster'
param clusterAdminName string
param sshRSAPublicKey string

// appgw


////////////////////////////////////////////////////////////////////////////////
///// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
}
///// Resource Group
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: vnet
module vnet 'modules/vnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vnet'
  params: {
    location: location 
  }
}
///// Module: vnet
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
///// Module: AKS
module aks 'modules/aks.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aks'
  params: {
    location: location
    clusterName: clusterName
    linuxAdminUsername: clusterAdminName
    sshRSAPublicKey: sshRSAPublicKey
    vnetName: vnet.outputs.vnetName
  }
}
///// Module: AKS
////////////////////////////////////////////////////////////////////////////////


// This bicep template is currently not used as it's easier to let the add-on create an appgw.
////////////////////////////////////////////////////////////////////////////////
///// Module: app-gw
// module appgw 'modules/appgw.bicep' = {
//   scope: resourceGroup(rg.name)
//   name: 'app-gw'
//   params: {
//     location: location
//     vnetName: vnet.outputs.vnetName
//   }
// }
///// Module: AKS
////////////////////////////////////////////////////////////////////////////////
