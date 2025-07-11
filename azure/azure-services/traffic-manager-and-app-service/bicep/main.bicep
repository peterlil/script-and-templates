targetScope = 'subscription'

// Resource group
param location string
param resourceGroupName string

param webApp1Location string = 'northeurope'
param webApp2Location string = 'westeurope'
param webApp1Abbr string = '1'
param webApp2Abbr string = '2'
param solutionName string
@allowed([
  '1'
  '2'
])
param webAppNo string


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
}

module webapp 'modules/web-app.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'WebApp'
  params: {
    webApp1Location:webApp1Location
    webApp1Abbr:webApp1Abbr
    webApp2Location:webApp2Location
    webApp2Abbr:webApp2Abbr
    solutionName: solutionName
    backendAppNo: webAppNo
  }
}

/*
az deployment sub create \
  --location 'northeurope' \
  --name 'full-deployment-'$(date "+%Y-%m-%d_%H%M%S") \
  -f main.bicep \
  -p location=northeurope resourceGroupName=hm-app-service-traffic-manager-449 solutionName=peterlil449 webAppNo=1
*/
