param location string = 'swedencentral'
param apimCapacity int = 1
param apimSku string = 'Developer'
param apimPublisherEmail string
param apimPublisherName string

// A name for the environment that will be prefix, suffix or any other part of the name of the resources
param envName string

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

var apimInstanceName = '${envName}-apim'

resource apimMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = { 
  name: '${envName}-apim-identity'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: '${envName}-vnet'
}

resource publicIpApim 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: '${envName}-apim-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings:{
      domainNameLabel: '${envName}-apim'
    }
  }
  sku: {
    name: 'Standard'
  }
}

// API Management
resource apim 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apimInstanceName
  location: location
  sku: {
    capacity: apimCapacity
    name: apimSku
  }
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${apimMi.id}': {}
    }
  }
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    virtualNetworkType: 'Internal'
    virtualNetworkConfiguration: {
      subnetResourceId: vnet.properties.subnets[0].id
    }
    publicIpAddressId: publicIpApim.id
    // when running this the first time, there are no certificates in key vault. So only create hostnames when
    // running this for the second time and onwards
    hostnameConfigurations: [
      {
        hostName: 'mgmt-apim.${envName}.peterlabs.net'
        type: 'Management'
        certificate: {
          expiry: mgmtCertExpiry
          subject: mgmtCertSubject
          thumbprint: mgmtCertThumbprint
        }
        certificateSource: 'KeyVault'
        identityClientId: apimMi.properties.clientId
        keyVaultId: mgmtCertId
      }
      {
        hostName: 'dev-apim.${envName}.peterlabs.net'
        type:'DeveloperPortal'
        certificate: {
          expiry: devCertExpiry
          subject: devCertSubject
          thumbprint: devCertThumbprint
        }
        certificateSource: 'KeyVault'
        identityClientId: apimMi.properties.clientId
        keyVaultId: devCertId
      }
      {
        hostName: 'portal-apim.${envName}.peterlabs.net'
        type: 'Portal'
        certificate: {
          expiry: portalCertExpiry
          subject: portalCertSubject
          thumbprint: portalCertThumbprint
        }
        certificateSource: 'KeyVault'
        identityClientId: apimMi.properties.clientId
        keyVaultId: portalCertId
      }
      {
        hostName: 'proxy-apim.${envName}.peterlabs.net'
        type: 'Proxy'
        certificate: {
          expiry: proxyCertExpiry
          subject: proxyCertSubject
          thumbprint: proxyCertThumbprint
        }
        certificateSource: 'KeyVault'
        identityClientId: apimMi.properties.clientId
        keyVaultId: proxyCertId
      }
      {
        hostName: 'scm-apim.${envName}.peterlabs.net'
        type: 'Scm'
        certificate: {
          expiry: scmCertExpiry
          subject: scmCertSubject
          thumbprint: scmCertThumbprint
        }
        certificateSource: 'KeyVault'
        identityClientId: apimMi.properties.clientId
        keyVaultId: scmCertId
      }
      // { Comes with API 2023-03-01-preview
      //   hostName: 'config-apim.${envName}.peterlabs.net'
      //   type: 'ConfigurationApi'
      //   certificate: {
      //     expiry: configCertExpiry
      //     subject: configCertSubject
      //     thumbprint: configCertThumbprint
      //   }
      //   certificateSource: 'KeyVault'
      //   identityClientId: apimMi.properties.clientId
      //   keyVaultId: configCertId
      // }
    ]
  }
}
