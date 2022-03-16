resource symbolicname 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'string'
  location: 'string'
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  properties: {
    configuration: {
      activeRevisionsMode: 'string'
      dapr: {
        appId: 'string'
        appPort: int
        appProtocol: 'string'
        enabled: bool
      }
      ingress: {
        allowInsecure: bool
        customDomains: [
          {
            bindingType: 'string'
            certificateId: 'string'
            name: 'string'
          }
        ]
        external: bool
        targetPort: int
        traffic: [
          {
            latestRevision: bool
            revisionName: 'string'
            weight: int
          }
        ]
        transport: 'string'
      }
      registries: [
        {
          passwordSecretRef: 'string'
          server: 'string'
          username: 'string'
        }
      ]
      secrets: [
        {
          name: 'string'
          value: 'string'
        }
      ]
    }
    managedEnvironmentId: 'string'
    template: {
      containers: [
        {
          args: [
            'string'
          ]
          command: [
            'string'
          ]
          env: [
            {
              name: 'string'
              secretRef: 'string'
              value: 'string'
            }
          ]
          image: 'string'
          name: 'string'
          probes: [
            {
              failureThreshold: int
              httpGet: {
                host: 'string'
                httpHeaders: [
                  {
                    name: 'string'
                    value: 'string'
                  }
                ]
                path: 'string'
                port: int
                scheme: 'string'
              }
              initialDelaySeconds: int
              periodSeconds: int
              successThreshold: int
              tcpSocket: {
                host: 'string'
                port: int
              }
              terminationGracePeriodSeconds: int
              timeoutSeconds: int
              type: 'string'
            }
          ]
          resources: {
            cpu: int
            memory: 'string'
          }
          volumeMounts: [
            {
              mountPath: 'string'
              volumeName: 'string'
            }
          ]
        }
      ]
      revisionSuffix: 'string'
      scale: {
        maxReplicas: int
        minReplicas: int
        rules: [
          {
            azureQueue: {
              auth: [
                {
                  secretRef: 'string'
                  triggerParameter: 'string'
                }
              ]
              queueLength: int
              queueName: 'string'
            }
            custom: {
              auth: [
                {
                  secretRef: 'string'
                  triggerParameter: 'string'
                }
              ]
              metadata: {}
              type: 'string'
            }
            http: {
              auth: [
                {
                  secretRef: 'string'
                  triggerParameter: 'string'
                }
              ]
              metadata: {}
            }
            name: 'string'
          }
        ]
      }
      volumes: [
        {
          name: 'string'
          storageName: 'string'
          storageType: 'string'
        }
      ]
    }
  }
}