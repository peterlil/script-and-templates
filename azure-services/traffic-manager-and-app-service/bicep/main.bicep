targetScope = 'subscription'

// Resource group
param location string
param webApp1Location string = 'northeurope'
param webApp2Location string = 'westeurope'
param webApp1LocationAbbr string = 'ne'
param webApp2LocationAbbr string = 'we'
param resourceGroupName string
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
    webApp1LocationAbbr:webApp1LocationAbbr
    webApp2Location:webApp2Location
    webApp2LocationAbbr:webApp2LocationAbbr
    solutionName: solutionName
    backendAppNo: webAppNo
  }
}

/*
az deployment sub create `
  --location 'northeurope' `
  --name "full-deployment-$(Get-Date -format 'yyyy-MM-dd_hhmmss')" `
  -f main.bicep `
  -p location=northeurope resourceGroupName=hm-app-service-traffic-manager-2 solutionName=peterlil444 webAppNo=1
*/
