# Deploy an internal API Management solution and Self-hosted gateway in AKS, using the v2 configuration

This article explains how to deploy an Azure API Management instance into a virtual network in internal mode with custom domains and how to expose the configuration endpoint to a self-hosted gateway deployed somewhere else. It is not as easy as it seems as the configuration endpoint does not support custom domains like the other endpoints does. 

There might be more solutions to this problem, but in this article I outline one solution.

## Start by generating certificates for the domain names

I develop on a Windows machine, and use [WSLv2](https://learn.microsoft.com/en-us/windows/wsl/install), [Let's Encrypt](https://letsencrypt.org/), [acme.sh](https://github.com/acmesh-official/acme.sh) and [Azure DNS](https://learn.microsoft.com/en-us/azure/dns/) to generate the certificates for this proof of concept.

### Generate the certificates in WSL
```bash
# Fill in the password you want to use to protect the pfx files.
password=''
# Enter the name of the environment you will create. This name will be a part of domain names and resource names
envName=''
# the path to the windows folder where you want the pfx files to land (e.g. /mnt/c/...)
# the last part of the path is created if it does not exists
windowsPath=''

# Generate the certificates
fqdn=mgmt-apim.$(echo $envName).peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

fqdn=dev-apim.$(echo $envName).peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

fqdn=portal-apim.$(echo $envName).peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

fqdn=proxy-apim.$(echo $envName).peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

fqdn=scm-apim.$(echo $envName).peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

fqdn=config-apim.$(echo $envName).peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

fqdn=$(echo $envName)-configuration.peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

# copy the certificates to a location in Windows where PowerShell can access them.
cd ~
mkdir $windowsPath
cp .acme.sh/mgmt-apim.$(echo $envName).peterlabs.net/mgmt-apim.$(echo $envName).peterlabs.net.pfx $windowsPath
cp .acme.sh/dev-apim.$(echo $envName).peterlabs.net/dev-apim.$(echo $envName).peterlabs.net.pfx $windowsPath
cp .acme.sh/portal-apim.$(echo $envName).peterlabs.net/portal-apim.$(echo $envName).peterlabs.net.pfx $windowsPath
cp .acme.sh/proxy-apim.$(echo $envName).peterlabs.net/proxy-apim.$(echo $envName).peterlabs.net.pfx $windowsPath
cp .acme.sh/scm-apim.$(echo $envName).peterlabs.net/scm-apim.$(echo $envName).peterlabs.net.pfx $windowsPath
cp .acme.sh/config-apim.$(echo $envName).peterlabs.net/config-apim.$(echo $envName).peterlabs.net.pfx $windowsPath
cp .acme.sh/$(echo $envName)-configuration.peterlabs.net/$(echo $envName)-configuration.peterlabs.net.pfx $windowsPath
```

### Log in to Azure with PowerShell
```PowerShell
# Log in to Azure
az login
# Make sure you are in the right subscription
az account show
# If not, change and run the commented command below
# az account set -n <subscriptionname>
```

### Deploy foundational services for APIM with PowerShell and Bicep

```PowerShell
# NOTE: Set/change the variables used in scripts below
$pfxPassword=""
$location="swedencentral"
$envName=""
$resourceGroupName="$envName-poc"
$apimPublisherName="Jane Doe"
$apimPublisherEmail="noreply@microsoft.com"
$clusterName="$envName-aks-cluster"
$clusterAdminName=""
$apimPrivateIp="10.20.0.4"

$objectIdOfUser=(az ad signed-in-user show --query id -o tsv)
$publicKey=cat ~\.ssh\id_rsa.pub
$subscriptionId=az account show --query id -o tsv

$cd = Get-Location
if ( $cd.Path.EndsWith("\internal-apim-w-shgw") -eq $false ) {
    # Assume current direactory is repo root, change to internal-apim-w-shgw 
    Set-Location "azure-services\api-management\internal-apim-w-shgw"
}

az deployment sub create `
    --location $location `
    --name "main-pre-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -f 'main-pre.bicep' `
    -p location=$location `
        resourceGroupName=$resourceGroupName `
        envName=$envName `
        objectIdOfUser=$objectIdOfUser `
        apimPrivateIp=$apimPrivateIp
```

### Deploy API Managagement Developer instance with PowerShell and Bicep

```PowerShell
# NOTE: Change to something that works in your environment
$tempFolder = ""

# Get the name of the key vault
$kv = az keyvault list -g $resourceGroupName --query "[].name" -o tsv
# Import the certificates to key vault and store the properties of the certificates in variables.
$certMgmt = az keyvault certificate import --file "\l\temp\pfx\mgmt-apim.$envName.peterlabs.net.pfx" --name "mgmt-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
$certDev = az keyvault certificate import --file "\l\temp\pfx\dev-apim.$envName.peterlabs.net.pfx" --name "dev-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
$certPortal = az keyvault certificate import --file "\l\temp\pfx\portal-apim.$envName.peterlabs.net.pfx" --name "portal-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
$certProxy = az keyvault certificate import --file "\l\temp\pfx\proxy-apim.$envName.peterlabs.net.pfx" --name "proxy-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
$certScm = az keyvault certificate import --file "\l\temp\pfx\scm-apim.$envName.peterlabs.net.pfx" --name "scm-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
$certConfig = az keyvault certificate import --file "\l\temp\pfx\config-apim.$envName.peterlabs.net.pfx" --name "config-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
$certAppGwListener = az keyvault certificate import --file "\l\temp\pfx\$envName-configuration.peterlabs.net.pfx" --name "$envName-configuration" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json

# Copy the certificate values for later use
$mgmtCertExpiry=(Get-Date $certMgmt.attributes.expires.ToUniversalTime() -Format "o") 
$mgmtCertSubject=$certMgmt.policy.x509CertificateProperties.subject 
$mgmtCertThumbprint=$certMgmt.x509Thumbprint
$mgmtCertId=$certMgmt.sid
$devCertExpiry=(Get-Date $certDev.attributes.expires.ToUniversalTime() -Format "o") 
$devCertSubject=$certDev.policy.x509CertificateProperties.subject 
$devCertThumbprint=$certDev.x509Thumbprint
$devCertId=$certDev.sid 
$portalCertExpiry=(Get-Date $certPortal.attributes.expires.ToUniversalTime() -Format "o") 
$portalCertSubject=$certPortal.policy.x509CertificateProperties.subject 
$portalCertThumbprint=$certPortal.x509Thumbprint 
$portalCertId=$certPortal.sid 
$proxyCertExpiry=(Get-Date $certProxy.attributes.expires.ToUniversalTime() -Format "o") 
$proxyCertSubject=$certProxy.policy.x509CertificateProperties.subject 
$proxyCertThumbprint=$certProxy.x509Thumbprint 
$proxyCertId=$certProxy.sid 
$scmCertExpiry=(Get-Date $certScm.attributes.expires.ToUniversalTime() -Format "o") 
$scmCertSubject=$certScm.policy.x509CertificateProperties.subject 
$scmCertThumbprint=$certScm.x509Thumbprint
$scmCertId=$certScm.sid
$configCertExpiry=(Get-Date $certconfig.attributes.expires.ToUniversalTime() -Format "o") 
$configCertSubject=$certconfig.policy.x509CertificateProperties.subject 
$configCertThumbprint=$certconfig.x509Thumbprint
$configCertId=$certconfig.sid
$appGwListenerCertExpiry=(Get-Date $certAppGwListener.attributes.expires.ToUniversalTime() -Format "o") 
$appGwListenerCertSubject=$certAppGwListener.policy.x509CertificateProperties.subject 
$appGwListenerCertThumbprint=$certAppGwListener.x509Thumbprint
$appGwListenerCertId=$certAppGwListener.sid

# Add role assignment for control plane identity
$aksIdentity=az identity show --name "$envName-aks-identity" --resource-group $resourceGroupName | ConvertFrom-Json
az role assignment create `
    --role Contributor `
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName `
    --assignee $aksIdentity.principalId

# Generate a parameter file as command line with all these parameters becomes too long.
$paramString = @"
{
    "`$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": { "value": "$location" },
        "envName": { "value": "$envName" },
        "apimPublisherEmail": { "value": "$apimPublisherEmail" },
        "apimPublisherName": { "value": "$apimPublisherName" },
        "mgmtCertExpiry": { "value": "$mgmtCertExpiry" },
        "mgmtCertSubject": { "value": "$mgmtCertSubject" },
        "mgmtCertThumbprint": { "value": "$mgmtCertThumbprint" },
        "mgmtCertId": { "value": "$mgmtCertId" },
        "devCertExpiry": { "value": "$devCertExpiry" },
        "devCertSubject": { "value": "$devCertSubject" },
        "devCertThumbprint": { "value": "$devCertThumbprint" },
        "devCertId": { "value": "$devCertId" },
        "portalCertExpiry": { "value": "$portalCertExpiry" },
        "portalCertSubject": { "value": "$portalCertSubject" },
        "portalCertThumbprint": { "value": "$portalCertThumbprint" },
        "portalCertId": { "value": "$portalCertId" },
        "proxyCertExpiry": { "value": "$proxyCertExpiry" },
        "proxyCertSubject": { "value": "$proxyCertSubject" },
        "proxyCertThumbprint": { "value": "$proxyCertThumbprint" },
        "proxyCertId": { "value": "$proxyCertId" },
        "scmCertExpiry": { "value": "$scmCertExpiry" },
        "scmCertSubject": { "value": "$scmCertSubject" },
        "scmCertThumbprint": { "value": "$scmCertThumbprint" },
        "scmCertId": { "value": "$scmCertId" },
        "configCertExpiry": { "value": "$configCertExpiry" },
        "configCertSubject": { "value": "$configCertSubject" },
        "configCertThumbprint": { "value": "$configCertThumbprint" },
        "configCertId": { "value": "$configCertId" },
        "configEndpointCertificateSecretId": { "value": "$appGwListenerCertId" },
        "clusterAdminName": { "value": "$clusterAdminName" },
        "sshRSAPublicKey": { "value": "$publicKey" }
    }
}
"@ | Out-File -FilePath "\l\temp\tempparams-main.json"

az deployment group create `
    --name "main-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -g $resourceGroupName `
    -f 'main.bicep' `
    -p "$tempFolder\tempparams-main.json"
```

### Set the A-records in the public DNS to the public ip of App GW

I manage `peterlabs.net` in another subscription, so I need to switch.

```PowerShell
# NOTE: Change subscription if you need to. If you are using the same subscription, either put the same subscription name in both variables or skip that part of the code
$sub1Name="" # Subscription name for the APIM instance you are configuring
$sub2Name="" # Subscription name for the public DNS zone you are using
$dnsResourceGroupName="" # Resource group name for the group the DNS zone is in

$appgwPublicIp = az network public-ip show -g $resourceGroupName -n "$envName-appgw-pip" | ConvertFrom-Json

az account set --name $sub2Name

# Add the A record in the public DNS. 
# NOTE: You need to change to a domain that you own. I.e. you need to change the information in public-dns.bicep.
az deployment group create `
    --name "peterlabs-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -g $dnsResourceGroupName `
    -f 'public-dns.bicep' `
    -p envName="$envName" appGwPublicIp="$($appgwPublicIp.ipAddress)"

# Reset the subscription to where we are configuring APIM
az account set --name $sub1Name
```

### Connect to the cluster

```PowerShell
az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing
```

### Create the shgw context in kube config if it does not exists
```PowerShell
$originalContextName=$clusterName
$shgwNamespace="shgw"
$shgwContext="$shgwNamespace-context"

kubectl config use-context $originalContextName

$foundNamespace=kubectl get namespaces | Select-String -Pattern $shgwNamespace
if($foundNamespace) {
    'Namespace already exists'
} else {
    'Creating namespace'
    kubectl create namespace $shgwNamespace
}

kubectl config set-context $shgwContext --namespace=$shgwNamespace --cluster=$originalContextName --user="clusterUser_$($resourceGroupName)_$originalContextName"
kubectl config use-context $shgwContext
```

### Create the Azure API Management Self-hosted gateway configuration if it does not exist
```PowerShell
# Add the gateway Azure resource if it does not exists
$uri="https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ApiManagement/service/$envName-apim/gateways/$envName-gateway?api-version=2020-12-01"
$bodyObject = [PSCustomObject]@{
    properties = [PSCustomObject]@{
        description = "$envName-gateway"
        locationData = [PSCustomObject]@{
            name = "$envName-gateway"
        }
    }
}
$body=$bodyObject | ConvertTo-Json -Compress
$body = $body -replace "`"", "\`""
az rest --method put --uri "$uri" --body $body --verbose
```

### Get the gateway token and create the K8s secret to use when gateway fetches config
```PowerShell
# Get the token for shgw to call back to APIM
$uri="https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ApiManagement/service/$envName-apim/gateways/$envName-gateway/generateToken?api-version=2021-04-01-preview"
$date=((Get-date).AddDays(29) | Get-Date -Format o)
$bodyObject = [PSCustomObject]@{
    keytype = "primary"
    expiry = "$date"
}
$body=$bodyObject | ConvertTo-Json -Compress
$body = $body -replace "`"", "\`""
$token=az rest --method 'post' --uri "$uri" --body "$body" --output tsv --verbose

# Create an AKS secret for the token
kubectl create secret generic "$envName-gateway-token" --from-literal=value="GatewayKey $token" --namespace="$shgwNamespace" --type=Opaque --dry-run=client --save-config -o yaml | kubectl apply --namespace="$shgwNamespace" -f -
```

### Deploy the self-hosted gateway pod
```PowerShell
# NOTE: Replace the path to one that works in your environment
$tempYmlFilename = ""
(Get-Content "aks-deployments\shgw-yml-template.txt").Replace("#envName#", $envName) | Set-Content $tempYmlFilename
kubectl apply -f $tempYmlFilename
```

### Check if it works
```PowerShell
kubectl get pods
kubectl logs <pod>
kubectl delete deployment $envName-gateway
kubectl delete configmap $envName-gateway-env
kubectl delete secret $envName-gateway-token
```


### _[Optional]_ Create the test vm in the vnet if needed for troubleshooting

```PowerShell
$location="swedencentral"
$envName=""
$resourceGroupName="$envName-poc"
$vmUsername=""
$vmPassword=""
# Run the initial deployment
az deployment group create `
    --name "vm-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -g $resourceGroupName `
    -f 'vm.bicep' `
    -p location=$location `
        envName=$envName `
        vmUsername=$vmUsername `
        vmPassword="""$vmPassword"""



```