param location string = 'sweden central'
param vnetAddressPrefixes array = [
  '10.0.0.0/16'
]
param subnets array
param adminUsername string = 'vmhero'
@secure()
param adminPassword string
param dataDisks array
param vnetName string = 'vnet-${replace(location, ' ', '-')}'

param vm1Name string = 'sql1'
param vm2Name string = 'sql2'

module vnetMod './vnet.bicep' = {
  name: 'vnetDeploy'
  params:{
    vnetName:vnetName
    location: location
    vnetAddressPrefixes:vnetAddressPrefixes
    subnets: subnets
  }
}

module vm1 './vm.bicep' = {
  dependsOn: [
    vnetMod
  ]
  name: 'vm1Deploy'
  params: {
    vmName:vm1Name
    adminPassword:adminPassword
    adminUsername:adminUsername
    dataDisks:dataDisks
    ipAllocationMethod:'dynamic'
    location:location
    subnetName:subnets[0].name
    vnetName:vnetName
  }
}

module vm2 './vm.bicep' = {
  name: 'vm2Deploy'
  dependsOn: [
    vnetMod
  ]
  params: {
    vmName:vm2Name
    adminPassword:adminPassword
    adminUsername:adminUsername
    dataDisks:dataDisks
    ipAllocationMethod:'dynamic'
    location:location
    subnetName:subnets[1].name
    vnetName:vnetName
  }
}

