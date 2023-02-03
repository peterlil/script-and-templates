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
resourceGroupName=aks-lab
clusterName=labcluster
acrName=acrforlabcluster
apiProjName=aks-webapi
imageVersion=1.0.0
appGwName=ingress-appgateway
appGwSubnetCidr=10.225.0.0/24
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

## Create the AKS instance

This creates an AKS cluster with:
- Kubenet

```bash
publicKey=$(cat ~/.ssh/id_rsa.pub)
az deployment sub create \
    --location 'sweden central' \
    --name 'full-deployment-'$(date "+%Y-%m-%d_%H%M%S") \
    -f 'azure-services\aks\main.bicep' \
    -p location='sweden central' \
        resourceGroupName=$resourceGroupName \
        clusterName=$clusterName \
        clusterAdminName='peter' \
        sshRSAPublicKey="$publicKey" \
        acrName=$acrName

az aks addon enable \
    -n $clusterName \
    -g $resourceGroupName \
    -a ingress-appgw \
    --appgw-name $appGwName \
    --appgw-subnet-cidr $appGwSubnetCidr

az aks get-credentials --resource-group $resourceGroupName --name $clusterName

k get nodes -o wide
k get pods -o wide -A

az aks update -n $clusterName -g $resourceGroupName --attach-acr $acrName
```

## Generate an api

```bash
rm -rf $apiProjName 
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

## Provision the pod
```bash
k apply -f ./azure-services/aks/aks-webapi.yaml
```

## Remove the deployment
```bash
k delete pod aks-webapi
k delete svc aks-webapi
k delete ingress aks-webapi
```