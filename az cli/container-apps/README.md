# Azure Container Apps

## Misc common command helpers

Get the default-domain for a container app. Useful for a container app in a private vnet with a private endpoint.
```bash
az containerapp env show -n aca-env-b -g aca --query defaultDomain --out json | tr -d '"'
```

Get the static private ip of a container app in a private vnet with a private endpoint.
```bash
az containerapp env show -n aca-env-b -g aca --query staticIp --out json | tr -d '"'
```

[Full script to deploy with a private DNS zone](https://docs.microsoft.com/en-us/azure/container-apps/vnet-custom?tabs=bash&pivots=azure-cli#deploy-with-a-private-dns)