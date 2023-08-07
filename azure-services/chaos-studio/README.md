# Test of Chaos Studio in AKS

## Provision a sample AKS cluster and deploy an app

I used this tutorial to provision a public cluster and deploy a simple application: [Tutorial: Prepare an application for Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app)

Then I enabled Chaos Studio on the AKS cluster in the portal following [this article](https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-tutorial-aks-portal#enable-chaos-studio-on-your-aks-cluster).


```bash
aksResourceGroup=chaos-tests
location=swedencentral
clusterName=chaos-cluster
acrName=chaosacr99

az group create --name $aksResourceGroup --location $location

az acr create --resource-group $aksResourceGroup --name $acrName --sku Basic

az acr login --name "$acrName.azurecr.io"

docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 $acrName.azurecr.io/azure-vote-front:v1

docker images

docker push $acrName.azurecr.io/azure-vote-front:v1

az aks create \
    --resource-group $aksResourceGroup \
    --name $clusterName \
    --node-count 2 \
    --generate-ssh-keys \
    --attach-acr $acrName

az aks get-credentials --resource-group $aksResourceGroup --name $clusterName

kubectl get nodes

kubectl apply -f azure-vote-all-in-one-redis.yaml
kubectl apply -f /mnt/c/l/src/github/peterlil/Azure-Samples/azure-voting-app-redis/azure-vote-all-in-one-redis.yaml

kubectl get service azure-vote-front --watch


helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update
kubectl create ns chaos-testing
helm install chaos-mesh chaos-mesh/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

kubectl get po -n chaos-testing


SUBSCRIPTION_ID="<sub-id>"
RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourcegroups/$aksResourceGroup/providers/Microsoft.ContainerService/managedClusters/chaos-cluster"
az rest --method put --url "https://management.azure.com/$RESOURCE_ID/providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh?api-version=2021-09-15-preview" --body "{\"properties\":{}}"

CAPABILITY="PodChaos-2.1"
az rest --method put --url "https://management.azure.com/$RESOURCE_ID/providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh/capabilities/$CAPABILITY?api-version=2021-09-15-preview"  --body "{\"properties\":{}}"

RESOURCE_GROUP=$aksResourceGroup
EXPERIMENT_NAME="Kill-pods"
az rest --method put --uri https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Chaos/experiments/$EXPERIMENT_NAME?api-version=2021-09-15-preview --body @experiment.json 


EXPERIMENT_PRINCIPAL_ID="<principal-id>"
az role assignment create --role "Azure Kubernetes Service Cluster Admin Role" --assignee-object-id $EXPERIMENT_PRINCIPAL_ID --scope $RESOURCE_ID

kubectl scale --replicas=2 deployment/azure-vote-front
kubectl scale --replicas=2 deployment/azure-vote-back

k get pods

k get svc -A

```

```

action: pod-kill
mode: one
selector:
  namespaces:
    - azure-vote-front

{"action":"pod-kill","mode":"one","selector":{"namespaces":["azure-vote-front"]}} -> works
{\"action\":\"pod-kill\",\"mode\":\"one\",\"selector\":{\"namespaces\":[\"azure-vote-front\"]}}


action: pod-failure
mode: fixed
value: 1
selector:
  namespaces:
    - azure-vote-front
duration: '30s'

{"action":"pod-failure","mode":"fixed","value":"1","selector":{"namespaces":["azure-vote-front"]},"duration":"30s"} -> works
```