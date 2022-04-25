# Deployment commands for bicep files in this folder

## Simple container app with public endpoint

```bash
rg=

$somePwd=

az deployment group create \
  --name SimpleContainerAppDeployment \
  --resource-group $rg \
  --template-file azure-services/container-apps/simple-container-app-w-public-endpoint.bicep \
  -p \
    containerRegistryPassword=somePwd
```
