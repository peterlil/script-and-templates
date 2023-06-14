# Deployment commands for bicep files in this folder

## API Managagement Developer instance

Create the API Management instance.

```PowerShell
$location="swedencentral"
$envName="pluto"
$resourceGroupName="$envName-poc"
$apimPublisherName="Jane Doe"
$apimPublisherEmail="jd@anon.dev"

az deployment sub create `
    --location 'swedencentral' `
    --name "full-deployment-$(Get-Date -Format 'yyyyMMddThhmm')" `
    -f 'main.bicep' `
    -p location=$location `
        resourceGroupName=$resourceGroupName `
        envName=$envName `
        apimPublisherEmail=$apimPublisherEmail `
        apimPublisherName=$apimPublisherName
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