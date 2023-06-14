param location string = 'swedencentral'
param apimCapacity int = 1
param apimSku string = 'Developer'
param apimPublisherEmail string
param apimPublisherName string


// A name for the environment that will be prefix, suffix or any other part of the name of the resources
param envName string = 'pluto'
param vnetPrefixes array = [
  '10.20.0.0/16'
]
param apimSubnetPrefix string = '10.20.0.0/24'

var vnetName = '${envName}-vnet'
var apimSubnetName = 'apim-subnet'
var saDevPortalName = '${envName}devportal'
var apimInstanceName = '${envName}-apim'

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
        }
      }
    ]
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
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    virtualNetworkType: 'Internal'
  }
}
