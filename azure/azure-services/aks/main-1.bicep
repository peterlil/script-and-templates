// Resource group
param location string = 'sweden central'

// vnet
param vnetName string = 'aks-vnet'

//appgw
param appGwName string = 'aks-appgw'
param appGwMiName string = 'appgw-identity'

// keyvault
param kvName string = 'aks-kv'
param objectIdOfUser string

////////////////////////////////////////////////////////////////////////////////
///// Module: vnet
module vnet 'modules/vnet.bicep' = {
  scope: resourceGroup()
  name: 'vnet'
  params: {
    location: location 
    vnetName: vnetName
  }
}
///// Module: vnet
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: app-gw
module appgw 'modules/appgw.bicep' = {
  scope: resourceGroup()
  name: 'app-gw'
  params: {
    appgwName: appGwName
    location: location
    vnetName: vnet.outputs.vnetName
    appGwMiName: appGwMiName
  }
}
///// Module: AKS
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: Key Vault
module kv 'modules/keyvault.bicep' = {
  scope: resourceGroup()
  name: 'kv'
  params: {
    location: location
    kvName: kvName
    objectIdOfUser: objectIdOfUser
    appGwMiName: appgw.outputs.appGwMiName
  }
}
///// Module: Key Vault
////////////////////////////////////////////////////////////////////////////////

