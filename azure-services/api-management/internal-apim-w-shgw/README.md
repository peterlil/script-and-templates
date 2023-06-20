# Deployment commands for bicep files in this folder

## API Managagement Developer instance

Generate the certificate in WSL.

```bash
#!/bin/bash

# Generate the certificates
password='scAm1()3@WCz5sSKVI82'
envName='goofy'

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

fqdn=$(echo $envName)-configuration.peterlabs.net
acme.sh --issue --dns dns_azure -d $fqdn
acme.sh --toPkcs -d $fqdn --password $password

# copy the certificates to a location where PowerShell can access them
mkdir /mnt/c/l/temp/pfx
cp .acme.sh/mgmt-apim.$(echo $envName).peterlabs.net/mgmt-apim.$(echo $envName).peterlabs.net.pfx /mnt/c/l/temp/pfx
cp .acme.sh/dev-apim.$(echo $envName).peterlabs.net/dev-apim.$(echo $envName).peterlabs.net.pfx /mnt/c/l/temp/pfx
cp .acme.sh/portal-apim.$(echo $envName).peterlabs.net/portal-apim.$(echo $envName).peterlabs.net.pfx /mnt/c/l/temp/pfx
cp .acme.sh/proxy-apim.$(echo $envName).peterlabs.net/proxy-apim.$(echo $envName).peterlabs.net.pfx /mnt/c/l/temp/pfx
cp .acme.sh/scm-apim.$(echo $envName).peterlabs.net/scm-apim.$(echo $envName).peterlabs.net.pfx /mnt/c/l/temp/pfx
cp .acme.sh/$(echo $envName)-configuration.peterlabs.net/$(echo $envName)-configuration.peterlabs.net.pfx /mnt/c/l/temp/pfx
```

Create the API Management instance from PowerShell.

```PowerShell
$pfxPassword=""
$location="swedencentral"
$envName="goofy"
$resourceGroupName="$envName-poc"
$apimPublisherName="Jane Doe"
$apimPublisherEmail="jd@anon.dev"
$objectIdOfUser=(az ad signed-in-user show --query id -o tsv)

# Get the name of the key vault if it exists. If the key vault does not exists, some extra work needs to be done after first deployment.
$kv = az keyvault list -g $resourceGroupName --query "[].name" -o tsv
if(!$kv) { $secondRun=$true } else { $secondRun=$false }

# Run the initial deployment
az deployment sub create `
    --location 'swedencentral' `
    --name "full-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -f 'main.bicep' `
    -p location=$location `
        resourceGroupName=$resourceGroupName `
        envName=$envName `
        apimPublisherEmail=$apimPublisherEmail `
        apimPublisherName=$apimPublisherName `
        objectIdOfUser=$objectIdOfUser `
        initRun=$secondRun

# Deploy the private dns
az deployment group create `
    --name "dns-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -g $resourceGroupName `
    -f 'modules\private-dns-zones.bicep' `
    -p envName=$envName

if($secondRun) {
    # the key vault exists now, upload the certificates
    $kv = az keyvault list -g $resourceGroupName --query "[].name" -o tsv
    $certMgmt = az keyvault certificate import --file "\l\temp\pfx\mgmt-apim.$envName.peterlabs.net.pfx" --name "mgmt-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
    $certDev = az keyvault certificate import --file "\l\temp\pfx\dev-apim.$envName.peterlabs.net.pfx" --name "dev-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
    $certPortal = az keyvault certificate import --file "\l\temp\pfx\portal-apim.$envName.peterlabs.net.pfx" --name "portal-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
    $certProxy = az keyvault certificate import --file "\l\temp\pfx\proxy-apim.$envName.peterlabs.net.pfx" --name "proxy-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
    $certScm = az keyvault certificate import --file "\l\temp\pfx\scm-apim.$envName.peterlabs.net.pfx" --name "scm-apim" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json
    $certAppGwListener = az keyvault certificate import --file "\l\temp\pfx\$envName-configuration.peterlabs.net.pfx" --name "$envName-configuration" --vault-name $kv --password """$pfxPassword""" | ConvertFrom-Json

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
    $appGwListenerCertExpiry=(Get-Date $certAppGwListener.attributes.expires.ToUniversalTime() -Format "o") 
    $appGwListenerCertSubject=$certAppGwListener.policy.x509CertificateProperties.subject 
    $appGwListenerCertThumbprint=$certAppGwListener.x509Thumbprint
    $appGwListenerCertId=$certAppGwListener.sid 
    

$paramString = @"
{
    "`$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": { "value": "$location" },
        "resourceGroupName": { "value": "$resourceGroupName" },
        "envName": { "value": "$envName" },
        "apimPublisherEmail": { "value": "$apimPublisherEmail" },
        "apimPublisherName": { "value": "$apimPublisherName" },
        "objectIdOfUser": { "value": "$objectIdOfUser" },
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
        "scmCertId": { "value": "$scmCertId" }
    }
}
"@ | Out-File -FilePath "\l\temp\tempparams.json"

    az deployment sub create `
        --location 'swedencentral' `
        --name "full-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
        -f 'main.bicep' `
        -p "\l\temp\tempparams.json"
}
```

Create the Application Gateway
```PowerShell
$paramString = @"
{
    "`$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": { "value": "$location" },
        "envName": { "value": "$envName" },
        "configEndpointCertificateSecretId": { "value": "$appGwListenerCertId" }
    }
}
"@ | Out-File -FilePath "\l\temp\tempparams-appgw.json"

az deployment group create `
    --name "appgw1-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -g $resourceGroupName `
    -f 'modules\appgw.bicep' `
    -p "\l\temp\tempparams-appgw.json"
```

Create the AKS cluster for the self-hosted gw
```PowerShell
$clusterName="$envName-aks-cluster"
$clusterAdminName="vmhero"
$publicKey=cat ~\.ssh\id_rsa__vmhero.pub
$subscriptionId=az account show --query id -o tsv

$aksIdentity=az identity show --name "$envName-aks-identity" --resource-group $resourceGroupName | ConvertFrom-Json

# Add role assignment for control plane identity
az role assignment create `
    --role Contributor `
    --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName `
    --assignee $aksIdentity.principalId

# Create the aks cluster
az deployment group create `
    -g $resourceGroupName `
    -n "aks-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -f 'aks-main.bicep' `
    -p location=$location `
        envName=$envName `
        clusterAdminName=$clusterAdminName `
        sshRSAPublicKey="$publicKey"
```

Connect to the cluster and deploy SHGW
```PowerShell
az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing

kubectl get nodes
kubectl get pods

```



```
# Helper
az deployment group create `
    --name "mi-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -g $resourceGroupName `
    -f 'modules\managed-identities.bicep' `
    -p envName=$envName location=$location

```
















Create an Azure AD App Registration for the Developer Portal
```PowerShell
$appName="$envName-apim-poc-appreg"
$appHomepage="https://$envName-apim-poc.developer.azure-api.net/"
$appReplyUrls=@("https://$envName-apim-poc.developer.azure-api.net/signin", 
                "https://$envName-apim-poc.developer.azure-api.net/aad-signin")

$app = az ad app create --display-name $appName `
    --web-home-page-url $appHomepage | ConvertFrom-Json
Write-Host "SPA App $($app.appId) Created."

Write-Host "SPA App Updating.."
# there is no CLI support to add reply urls to a SPA, so we have to patch manually via az rest
$appPatchUri = "https://graph.microsoft.com/v1.0/applications/{0}" -f $app.objectId
$appReplyUrlsString = "'{0}'" -f ($appReplyUrls -join "','")
$appPatchBody = "{spa:{redirectUris:[$appReplyUrlsString]}}"
az rest --method PATCH --uri $appPatchUri --headers 'Content-Type=application/json' `
    --body $appPatchBody
Write-Host "SPA App Updated."

```


Create the test vm if needed

```PowerShell
$location="swedencentral"
$envName="goofy"
$resourceGroupName="$envName-poc"
$vmUsername="peter"
$vmPassword="NBbu;5{jD1<5.r#voJ%z"
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