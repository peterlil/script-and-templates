targetScope = 'subscription'

// Resource group
param location string
param resourceGroupName string

// Solution wide
param envName string

// API Management
param apimPublisherEmail string
param apimPublisherName string

// User id for kv permissions
param objectIdOfUser string

param initRun bool = false

param mgmtCertExpiry string = ''
param mgmtCertSubject string = ''
param mgmtCertThumbprint string = ''
param mgmtCertId string = ''

param devCertExpiry string = ''
param devCertSubject string = ''
param devCertThumbprint string = ''
param devCertId string = ''

param portalCertExpiry string = ''
param portalCertSubject string = ''
param portalCertThumbprint string = ''
param portalCertId string = ''

param proxyCertExpiry string = ''
param proxyCertSubject string = ''
param proxyCertThumbprint string = ''
param proxyCertId string = ''

param scmCertExpiry string = ''
param scmCertSubject string = ''
param scmCertThumbprint string = ''
param scmCertId string = ''

////////////////////////////////////////////////////////////////////////////////
///// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
}
///// Resource Group
////////////////////////////////////////////////////////////////////////////////

module mi 'modules/managed-identities.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'managed-identities'
  params: {
    location: location
    envName: envName
  }
}

module kv 'modules/keyvault.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'keyvault'
  params: {
    location: location
    envName: envName
    objectIdOfUser: objectIdOfUser
  }
}

////////////////////////////////////////////////////////////////////////////////
///// Module: API Management
module apim 'modules/apim.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'azure-api-management'
  params: {
    location: location
    envName: envName
    apimPublisherEmail: apimPublisherEmail
    apimPublisherName: apimPublisherName
    initRun: initRun
    mgmtCertExpiry: mgmtCertExpiry
    mgmtCertSubject: mgmtCertSubject
    mgmtCertThumbprint: mgmtCertThumbprint
    mgmtCertId: mgmtCertId
    devCertExpiry: devCertExpiry
    devCertSubject: devCertSubject
    devCertThumbprint: devCertThumbprint
    devCertId: devCertId
    portalCertExpiry: portalCertExpiry
    portalCertSubject: portalCertSubject
    portalCertThumbprint: portalCertThumbprint
    portalCertId: portalCertId
    proxyCertExpiry: proxyCertExpiry
    proxyCertSubject: proxyCertSubject
    proxyCertThumbprint: proxyCertThumbprint
    proxyCertId: proxyCertId
    scmCertExpiry: scmCertExpiry
    scmCertSubject: scmCertSubject
    scmCertThumbprint: scmCertThumbprint
    scmCertId: scmCertId
  }
}
///// Module: API Management
////////////////////////////////////////////////////////////////////////////////
