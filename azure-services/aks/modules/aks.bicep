@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('The name of the Managed Cluster resource.')
param clusterName string = 'labcluster'

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = clusterName

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 1

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

param vnetName string = 'aks-vnet'
param aksNodeSubnetName string = 'aks-subnet'
param aksPodCidr string = '10.224.128.0/17'
param appgwName string = 'aks-appgw'
// param appgwSubnetCidr string = '10.225.0.0/24'
param ingressAppGwMiName string = 'ingress-app-gw-identity'
param aksMiName string = 'aks-identity'

var dockerBridgeCidr = '172.17.0.1/16'
var dnsServiceIp = '10.0.0.10'
var serviceCidr = '10.0.0.0/16'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}

resource nodeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: aksNodeSubnetName
  parent: vnet
}

resource ingressAppGwMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: ingressAppGwMiName
}

resource aksMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: aksMiName
}

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksMi.id}': {}
    }
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
        //podSubnetID: podSubnet.id
        vnetSubnetID: nodeSubnet.id
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    networkProfile: {
      dnsServiceIP: dnsServiceIp
      dockerBridgeCidr: dockerBridgeCidr
      networkPlugin: 'kubenet'
      podCidr: aksPodCidr
      serviceCidr: serviceCidr
    }
    //nodeResourceGroup: '${resourceGroup().name}-nodes'
    addonProfiles: {
      ingressApplicationGateway:{
        config: {
          applicationGatewayId: resourceId('Microsoft.Network/applicationGateways', appgwName)
        }
        enabled: true
        identity: {
          clientId: ingressAppGwMi.properties.clientId
          objectId: ingressAppGwMi.properties.principalId
          resourceId: ingressAppGwMi.id
        }
      }
    }
  }
}

// resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
//   scope: subscription()
//   name: 'xxx'
// }
// //Microsoft.Authorization/roleAssignments@2020-04-01-preview
// resource aksfix 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id,'aksfix','Contributor')
//   scope: resourceGroup()
//   properties: {
//     description: 'fixes aks cross resource group principal permissions for agic'
//     principalId: aks.properties.addonProfiles.ingressApplicationGateway.identity.objectId
//     principalType: 'ServicePrincipal'
//     roleDefinitionId: contributorRoleDefinition.id
//   }
// }

output controlPlaneFQDN string = aks.properties.fqdn
