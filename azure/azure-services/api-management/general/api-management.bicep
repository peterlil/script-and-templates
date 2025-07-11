targetScope = 'subscription'

// Resource group
param location string
param resourceGroupName string

// API Management
param apimInstanceName string
param apimPublisherEmail string
param apimPublisherName string

// Storage Account for the developer portal
param saDevPortalName string = 'devportal${uniqueString(apimInstanceName)}'


////////////////////////////////////////////////////////////////////////////////
///// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
}
///// Resource Group
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
///// Module: API Management
module apim 'modules/apim.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'azure-api-management'
  params: {
    location: location
    apimInstanceName: apimInstanceName
    apimPublisherEmail: apimPublisherEmail
    apimPublisherName: apimPublisherName
    saDevPortalName: saDevPortalName
  }
}
///// Module: API Management
////////////////////////////////////////////////////////////////////////////////

output DevPortalName string = saDevPortalName
