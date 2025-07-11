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


## Create a simple container app, no vnet, public endpoint

## Create a simple container app, vnet, private endpoint

```bash
az monitor log-analytics workspace create `
  --resource-group 'sample-rg' `
  --workspace-name 'logs-for-sample'

$LOG_ANALYTICS_WORKSPACE_CLIENT_ID=(az monitor log-analytics workspace show --query customerId -g 'sample-rg' -n 'logs-for-sample' --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g 'sample-rg' -n 'logs-for-sample' --out tsv)

az containerapp env create -n aca-env-a -g sample-rg `
    --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
    --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
    --location northeurope


```
