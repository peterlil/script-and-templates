param location string = 'swedencentral'
param apimCapacity int = 1
param apimSku string = 'Developer'
param apimPublisherEmail string
param apimPublisherName string
param initRun bool

// A name for the environment that will be prefix, suffix or any other part of the name of the resources
param envName string = 'pluto'
param vnetPrefixes array = [
  '10.20.0.0/16'
]
param apimSubnetPrefix string = '10.20.0.0/24'

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


var vnetName = '${envName}-vnet'
var apimSubnetName = 'apim-subnet'
var saDevPortalName = '${envName}devportal'
var apimInstanceName = '${envName}-apim'

resource apimMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = { 
  name: '${envName}-apim-identity'
}

resource nsgApimSubnet 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: '${envName}-apim-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-inbound-to-mgmt-endpoint'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'ApiManagement'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
        }
      }
      {
        name: 'allow-inbound-to-load-balancer'
        properties: {
          priority: 101
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '6390'
        }
      }
      {
        name: 'allow-outbound-to-storage'
        properties: {
          priority: 102
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
          destinationPortRange: '443'
        }
      }
      {
        name: 'allow-outbound-to-sql'
        properties: {
          priority: 103
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
          destinationPortRange: '1443'
        }
      }
      {
        name: 'allow-outbound-to-keyvault'
        properties: {
          priority: 104
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

// Virtual network for the APIM
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:vnetPrefixes
    }
    subnets: [
      {
        name: apimSubnetName
        properties:{
          addressPrefix: apimSubnetPrefix
          networkSecurityGroup: {
            id: nsgApimSubnet.id
          }
        }
      }
    ]
  }
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

// Storage Account for the Developer Portal Static Web App
resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: saDevPortalName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
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
    hostnameConfigurations: initRun ? [] : [
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
    ]
  }
}
