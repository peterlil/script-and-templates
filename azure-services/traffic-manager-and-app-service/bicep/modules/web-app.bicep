param webApp1Location string
param webApp2Location string
param webApp1LocationAbbr string
param webApp2LocationAbbr string
param solutionName string
param sku string = 'S1'
@allowed([
  '1'
  '2'
])
param backendAppNo string

var hostingPlan1Name = '${solutionName}-${webApp1LocationAbbr}-asp'
var hostingPlan2Name = '${solutionName}-${webApp2LocationAbbr}-asp'
var webAppName1 = '${solutionName}-1-webapp'
var webAppName2 = '${solutionName}-2-webapp'
var tmName = '${solutionName}-tmp'

resource hostingPlan1 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlan1Name
  location: webApp1Location
  sku: {
    name: sku
  }
}

resource hostingPlan2 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlan2Name
  location: webApp2Location
  sku: {
    name: sku
  }
}

resource webApp1 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName1
  location: webApp1Location
  properties: {
    serverFarmId: hostingPlan1.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'sampleapp:ServiceName'
          value: 'Web App 1'
        }
      ]
    }
  }
}

resource webApp2 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName2
  location: webApp2Location
  properties: {
    serverFarmId: hostingPlan2.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'sampleapp:ServiceName'
          value: 'Web App 2'
        }
      ]
    }
  }
}

resource webApp3 'Microsoft.Web/sites@2022-03-01' = {
  name: '${webAppName2}-copy'
  location: webApp2Location
  properties: {
    serverFarmId: hostingPlan2.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'sampleapp:ServiceName'
          value: 'Web App 2'
        }
      ]
    }
  }
}



resource tm 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: tmName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: tmName
      ttl: 10
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/'
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 202
        }
        {
          min: 301
          max: 302
        }
      ]
    }
    endpoints: [
      {
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        name: 'endpoint1'
        properties: {
          targetResourceId: webApp1.id
          endpointStatus: 'Enabled'
          priority: backendAppNo == '1' ? 1 : 1000
        }
      }
      {
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        name: 'endpoint2'
        properties: {
          targetResourceId: webApp2.id
          endpointStatus: 'Enabled'
          priority: backendAppNo == '2' ? 1 : 1000
        }
      }
    ]
  }
}
