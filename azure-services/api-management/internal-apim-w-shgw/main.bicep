param location string
param envName string

// API Management
param apimPublisherEmail string
param apimPublisherName string

param mgmtCertExpiry string
param mgmtCertSubject string
param mgmtCertThumbprint string
param mgmtCertId string

param devCertExpiry string
param devCertSubject string
param devCertThumbprint string
param devCertId string

param portalCertExpiry string
param portalCertSubject string
param portalCertThumbprint string
param portalCertId string

param proxyCertExpiry string
param proxyCertSubject string
param proxyCertThumbprint string
param proxyCertId string

param scmCertExpiry string
param scmCertSubject string
param scmCertThumbprint string
param scmCertId string

param configCertExpiry string
param configCertSubject string
param configCertThumbprint string
param configCertId string

@secure()
param configEndpointCertificateSecretId string

param clusterAdminName string
param sshRSAPublicKey string


////////////////////////////////////////////////////////////////////////////////
///// Module: API Management
module apim 'modules/apim.bicep' = {
  scope: resourceGroup()
  name: 'azure-api-management'
  params: {
    location: location
    envName: envName
    apimPublisherEmail: apimPublisherEmail
    apimPublisherName: apimPublisherName
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
    configCertExpiry: configCertExpiry
    configCertSubject: configCertSubject
    configCertThumbprint: configCertThumbprint
    configCertId: configCertId
  }
}
///// Module: API Management
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: Application Gateway

module appgw 'modules/appgw.bicep' = {
  scope: resourceGroup()
  name: 'azure-application-gateway'
  params: {
    location: location
    envName: envName
    configEndpointCertificateSecretId: configEndpointCertificateSecretId
  }
}

///// Module: Application Gateway
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: vnet
module aksVnet 'modules/aks-vnet.bicep' = {
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
  dependsOn: [
    aksVnet
  ]
  params: {
    location: location
    envName: envName
    linuxAdminUsername: clusterAdminName
    sshRSAPublicKey: sshRSAPublicKey
  }
}
///// Module: AKS
////////////////////////////////////////////////////////////////////////////////
