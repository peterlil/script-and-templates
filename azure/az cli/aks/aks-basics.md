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
Configure a context for a namespace |`kubectl config set-context <name> --namespace=<namespace> --cluster=<clustername> --user=<user>`
ssh to a pod | `kubectl exec <podname> -i -t -- bash -il`
Restart all pods | <pre>pods=$(k get pods -o name --no-headers=true)<br>while IFS= read -r pod; do<br>&nbsp;&nbsp;k delete $pod<br>done <<< "$pods"</pre>
