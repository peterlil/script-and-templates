// This bicep does not work yet. Haven't gotten the passwordSecretRef to work
param location string = resourceGroup().location
param secrets array = [
  {
    name: 'registry-password'
    value: containerRegistryPassword
  }
]

@secure()
param containerRegistryPassword string

var registrySecretRefName = 'registry-password'

resource acaC 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'aca-c'
  location: location
  properties: {
    configuration: {
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 443
      }
      registries: [
        {
          server: 'mcr.microsoft.com'
          username: 'someuser'
          passwordSecretRef: registrySecretRefName
        }
      ]
    }
    managedEnvironmentId: '/subscriptions/05c25b78-003c-49ef-8f02-b24ca4aca086/resourceGroups/aca/providers/Microsoft.Web/kubeEnvironments/aca-env-a'
    template: {
      containers: [
        {
          image: 'azuredocs/containerapps-helloworld:latest'
          name: 'simple-hello-world-container'
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}
