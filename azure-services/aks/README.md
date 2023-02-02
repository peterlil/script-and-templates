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

## Provision the vnet

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
        resourceGroupName=aks-lab \
        clusterName=labcluster \
        clusterAdminName='peter' \
        sshRSAPublicKey="$publicKey"

```



## Create the App GW

One vnet and one subnet got created when the cluster was created. For the app gw we need one more subnet.

vnet/subnet       | cidr           | Address range
------------------|----------------|------------------------------
aks-vnet-17831063 | 10.224.0.0/12  | 10.224.0.0 - 10.239.255.255
aks-subnet        | 10.224.0.0/16  | 10.224.0.0 - 10.224.255.255
appgw-subnet      | 10.225.0.0/24  | 10.225.0.0 - 10.225.0.255






