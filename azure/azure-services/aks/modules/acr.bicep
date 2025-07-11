param location string
param acrName string = 'acrforlabcluster'


resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location 
  sku: {
    name: 'Basic'
  }
}
