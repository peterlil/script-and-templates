param apimInstanceName string
param location string = resourceGroup().location
param apimCapacity int = 1
param apimSku string = 'Developer'
param apimPublisherEmail string
param apimPublisherName string
param saDevPortalName string


////////////////////////////////////////////////////////////////////////////////
///// API Management

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
  }
}

///// API Management
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Storage Account for the Developer Portal Static Web App
resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: saDevPortalName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
///// Storage Account for the Developer Portal Static Web App
////////////////////////////////////////////////////////////////////////////////
