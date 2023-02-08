# Provision a private AKS cluster

## Sign in to Azure

```bash
# Login to Azure CLI
az login
# Make sure we are in the right subscription
az account set --name <sub-name>
# Verify subscription
az account show
```

## Common variables and aliases
```bash
location='sweden central'
resourceGroupName=aks-lab
#nodeResourceGroupName=aks-lab-nodes 
vnetName=aks-vnet
clusterName=labcluster
acrName=acrforlabcluster
apiProjName=aks-webapi
imageVersion=1.0.0
appGwName=aks-appgw
appGwSubnetCidr=10.225.0.0/24
appGwMiName='appgw-identity'
aksMiName='aks-identity'
ingressAppGwMiName='ingress-app-gw-identity'
kvName='aks-kv-'$(openssl rand -hex 4)
alias k=kubectl
```

## Setup of the vnet

Kubenet

vnet/subnet       | cidr             | Address range
------------------|------------------|------------------------------
aks-vnet          | 10.224.0.0/12    | 10.224.0.0   - 10.239.255.255
aks-subnet        | 10.224.0.0/24    | 10.224.0.0   - 10.224.255.255
appgw-subnet      | 10.225.0.0/24    | 10.225.0.0   - 10.225.0.255

<!-- Maybe use these when doing CNI? -->
<!-- aks-node-subnet   | 10.224.0.0/24    | 10.224.0.0   - 10.224.0.255 -->
<!-- aks-pod-subnet    | 10.224.128.0/17  | 10.224.128.0 - 10.224.255.255 -->

## Create the resources

```bash
publicKey=$(cat ~/.ssh/id_rsa.pub)
objectIdOfUser=$(az ad signed-in-user show --query id -o tsv)
subscriptionId=$(az account show --query id -o tsv)

az group create --name $resourceGroupName --location "$location"

# Create the managed identities
az deployment group create \
    --resource-group $resourceGroupName \
    --name 'full-deployment-'$(date "+%Y-%m-%d_%H%M%S") \
    -f 'azure-services\aks\managed-identities.bicep' \
    -p location="$location" \
        appGwMiName=$appGwMiName \
        aksMiName=$aksMiName \
        ingressAppGwMiName=$ingressAppGwMiName

appGwIdentity=$(az identity show --name $appGwMiName --resource-group $resourceGroupName)
aksIdentity=$(az identity show --name $aksMiName --resource-group $resourceGroupName)
ingressAppGwIdentity=$(az identity show --name $ingressAppGwMiName --resource-group $resourceGroupName)

# Add role assignment for control plane identity
# https://learn.microsoft.com/en-us/azure/aks/use-managed-identity#add-role-assignment-for-control-plane-identity
az role assignment create \
    --role Contributor \
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName \
    --assignee $(echo $aksIdentity | jq -r '.principalId')

# Add role assignment for ingress controller identity
az role assignment create \
    --role Reader \
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName \
    --assignee $(echo $ingressAppGwIdentity | jq -r '.principalId')

# Create the vnet, appgw and kv
az deployment group create \
    --resource-group $resourceGroupName \
    --name 'full-deployment-'$(date "+%Y-%m-%d_%H%M%S") \
    -f 'azure-services\aks\main-1.bicep' \
    -p location="$location" \
        vnetName=$vnetName \
        appGwName=$appGwName \
        appGwMiName=$appGwMiName \
        kvName=$kvName \
        objectIdOfUser=$objectIdOfUser

# Add role assignment for app gateway identity
az role assignment create \
    --role Contributor \
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/applicationGateways/$appGwName \
    --assignee $(echo $ingressAppGwIdentity | jq -r '.principalId')

# Create the cluster
az deployment group create \
    --resource-group $resourceGroupName \
    --name 'full-deployment-'$(date "+%Y-%m-%d_%H%M%S") \
    -f 'azure-services\aks\main-2.bicep' \
    -p location="$location" \
        clusterName=$clusterName \
        clusterAdminName='peter' \
        sshRSAPublicKey="$publicKey" \
        vnetName=$vnetName \
        ingressAppGwMiName=$ingressAppGwMiName \
        aksMiName=$aksMiName \
        acrName=$acrName


# Fix as the cluster is not created with the correct identity for the ingress controller
realIngressAppGwMiName='ingressapplicationgateway-labcluster'
nodeResourceGroupName='MC_aks-lab_labcluster_swedencentral'
realIngressAppGwIdentity=$(az identity show --name $realIngressAppGwMiName --resource-group $nodeResourceGroupName)
az role assignment create \
    --role Reader \
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName \
    --assignee $(echo $realIngressAppGwIdentity | jq -r '.principalId')
az role assignment create \
    --role Contributor \
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/applicationGateways/$appGwName \
    --assignee $(echo $realIngressAppGwIdentity | jq -r '.principalId')

// UGLY: Refresh the credentials by restarting the cluster

# Get the credentials for kubectl
az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing

# Verify the cluster
k get nodes -o wide
k get pods -o wide -A

# Connect the cluster to the registry
az aks update -n $clusterName -g $resourceGroupName --attach-acr $acrName
```

## Generate an api

```bash
rm -rf azure-services/aks/$apiProjName
dotnet new webapi -au none -minimal -o azure-services/aks/$apiProjName
rm azure-services/aks/$apiProjName/Program.cs
{
cat <<EOF >>azure-services/aks/$apiProjName/Program.cs
var builder = WebApplication.CreateBuilder(args);
// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var app = builder.Build();
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.MapGet("/", () => "Hello World!");
app.Run();
EOF
}

```

## Build the image and push it to the registry

```bash
#docker build --progress=plain --no-cache -t aks-webapi -f Dockerfile . # Use for troubleshooting image builds
docker build -t $acrName.azurecr.io/$apiProjName:$imageVersion -f ./azure-services/aks/Dockerfile ./azure-services/aks

az acr login --name $acrName
docker push $acrName.azurecr.io/$apiProjName:$imageVersion
```

## Provision the pod (http)
```bash
k apply -f ./azure-services/aks/aks-webapi-http.yaml

# Verify the pod and the ingress
$podName=aks-webapi
k get pods $podName -o wide
k get svc -o wide
k get ingress $podName 

k get pods $podName -o wide --namespace kube-system
k get pods ingress-appgw-deployment-7978d7d5d-snqb4 -o wide --namespace kube-system
k logs ingress-appgw-deployment-7978d7d5d-snqb4 --namespace kube-system
echo $aksIdentity | jq -r '.principalId'
echo $appGwIdentity | jq -r '.principalId'
echo $ingressAppGwIdentity | jq -r '.principalId'

# Try a request with curl
ip=$(k get ingress $podName -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
curl http://$ip/

```

## Provision the pod (https)

Create the certificate (this is a custom process and not meant to be followed. This script is just as example)

```bash
fqdn=aks-webapi.peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
password=<password>
acme.sh --toPkcs -d $fqdn --password $password
```

```bash
# Upload the certificate to key vault
fqdnDashes=${fqdn//./-}
az keyvault certificate import --vault-name $kvName --name $fqdnDashes --file ~/.acme.sh/$fqdn/$fqdn.pfx --password $password
versionedSecretId=$(az keyvault certificate show -n $fqdnDashes --vault-name $kvName --query "sid" -o tsv)
unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5)

# ssl certificate with name $fqdnDashes will be configured on AppGw
az network application-gateway ssl-cert create \
    -n $fqdnDashes \
    --gateway-name $appGwName \
    --resource-group $resourceGroupName \
    --key-vault-secret-id $unversionedSecretId

ingressName=aks-webapi-with-gw-https
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $ingressName
  labels:
    app: $ingressName
spec:
  containers:
  - image: "acrforlabcluster.azurecr.io/aks-webapi:1.0.0"
    name: aks-webapi-image
    ports:
    - containerPort: 80
      protocol: TCP

---

apiVersion: v1
kind: Service
metadata:
  name: $ingressName
spec:
  selector:
    app: $ingressName
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $ingressName
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/appgw-ssl-certificate: aks-webapi-peterlabs-net
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          service:
            name: $ingressName
            port:
              number: 80
        pathType: Exact
EOF
#k apply -f ./azure-services/aks/aks-webapi-https.yaml

# Verify the pod and the ingress
k get pods -o wide -A
k get svc -o wide
k get ingress $ingressName -o wide

# Try a request with curl
ip=$(k get ingress $ingressName -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -k --resolve $fqdn:443:$ip https://$ip/
curl -k --resolve $fqdn:443:20.240.242.2 https://20.240.242.2/
```


## Look at the provisioned resources
```bash
k get pods -o wide -A
k get svc -o wide
k get ingress -o wide -A
k logs <podname> -n kube-system
k delete pod <podname> -n kube-system
```

## Remove the deployment
```bash
k delete pod aks-webapi
k delete svc aks-webapi
k delete ingress aks-webapi
```

