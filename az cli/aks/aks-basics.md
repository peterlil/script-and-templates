# AKS basics #
## Cluster management ##
Explanation | Command
----------- | -------
Connect to a cluster | `az aks get-credentials --resource-group <groupname> --name <clustername>`
Start a cluster | `az aks start --name <clustername> --resource-group <rgname>`
Stop a cluster | `az aks stop --name <clustername> --resource-group <rgname>`
View cluster status | `az aks show --name <clustername> --resource-group <rgname>`

## kubectl basics
Explanation | Command
----------- | -------
Configure a context for a namespace |`kubectl config set-context shgw --namespace=shgw --cluster=<clustername> --user=<user>`
