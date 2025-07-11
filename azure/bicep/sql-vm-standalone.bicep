param location string = 'sweden central'
param vnetAddressPrefixes array = [
  '10.0.0.0/24'
]
param subnets array
param adminUsername string = 'vmhero'
@secure()
param adminPassword string
param dataDisks array
param vnetName string = 'vnet-${replace(location, ' ', '-')}'
param nsgSourceIp string

param vm1Name string = 'vm-${substring(uniqueString(resourceGroup().name), 0, 5)}'

param imageReference object = {
  offer:'sql2019-ws2022'
  sku:'sqldev'
  publisher:'MicrosoftSQLServer'
  version:'15.0.220412'
}

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
    location:location
    subnetName:subnets[0].name
    vnetName:vnetName
    nsgSourceIp:nsgSourceIp
    imageReference:imageReference
  }
}


/* BASH
az login
az account show
rgName=sql-vm-test
location=swedencentral
az group create -g $rgName -l $location

pwd=$(az keyvault secret show -n 'vmhero' \
  --subscription $(az account show --query 'id' -o tsv) \
  --vault-name devboxes-vm-encrypt \
  --query "value" \
  -o tsv)

myPublicIp=$(curl ifconfig.me)

az deployment group create \
  -g $rgName \
  --mode complete \
  --template-file ./ps/bicep/sql-vm-standalone.bicep \
  --parameters ./ps/bicep/sql-vm-standalone.parameters.json \
  --parameters nsgSourceIp=$myPublicIp adminPassword=$pwd

*/
