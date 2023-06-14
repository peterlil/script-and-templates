targetScope = 'subscription'

// Resource group
param location string
param resourceGroupName string

// Solution wide
param envName string

// API Management
param apimPublisherEmail string
param apimPublisherName string


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
    envName: envName
    apimPublisherEmail: apimPublisherEmail
    apimPublisherName: apimPublisherName
  }
}
///// Module: API Management
////////////////////////////////////////////////////////////////////////////////


