# Create the app registrations for on-behalf-of flow

## Scenario: Web App (App) -> Middleware Api (Api1) -> Backend Api (Api2)


### Create an appreg for App

```shell
appRegAppDisplayName=app

appRegApp=$(az ad sp create-for-rbac --display-name $appRegAppDisplayName)
appIdApp=$(echo $appRegApp | jq -r '.appId')
appSecretApp=$(echo $appRegApp | jq -r '.password')
objectIdAppRegApp=$(az ad app show --id $appIdApp --query '{id: id}' -o tsv)
echo $appRegApp
```

Make sure to store the content of `appRegApp` somewhere safe.

### Create an appreg for Api1

```shell
appRegApi1DisplayName=api1

appRegApi1=$(az ad sp create-for-rbac --display-name $appRegApi1DisplayName)
appIdApi1=$(echo $appRegApi1 | jq -r '.appId')
appSecretApi1=$(echo $appRegApi1 | jq -r '.password')
objectIdAppRegApi1=$(az ad app show --id $appIdApi1 --query '{id: id}' -o tsv)
echo $appRegApi1
```

Make sure to store the content of `appRegApi1` somewhere safe.

### Create an appreg for Api2

```shell
appRegApi2DisplayName=api2

appRegApi2=$(az ad sp create-for-rbac --display-name $appRegApi2DisplayName)
appIdApi2=$(echo $appRegApi2 | jq -r '.appId')
objectIdAppRegApi2=$(az ad app show --id $appIdApi2 --query '{id: id}' -o tsv)
echo $appRegApi2
```

Make sure to store the content of `appRegApi2` somewhere safe.


## Configure Backend Api (Api2)

### Set the sign in audience and Application ID URI for Api2

```shell
az ad app update --id $appIdApi2 \
    --sign-in-audience 'AzureADMyOrg' \
    --identifier-uris api://$appIdApi2
```

### Expose scopes

```shell
scopeNameApi2=UseApi
scopes=$( jq -n \
    --arg id $(uuidgen) \
    --arg scope $scopeNameApi2 \
    '{"api":{"oauth2PermissionScopes":[{"adminConsentDescription":"Allow access to the dummy api","adminConsentDisplayName":"Dummy Api Access","id":$id,"isEnabled":true,"type":"User","userConsentDescription":"Allow access to the dummy api","userConsentDisplayName":"Dummy Api Access","value":$scope}]}}' )

# This should be the way to do it, but az cli lags behind
#$oauth2Permissions | Out-File -FilePath .\oauth2Permissions.json
#az ad app update --id $appIdApi2 --set api.oauth2PermissionScopes=@oauth2Permissions.json

# use this instead
az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi2 \
    --body "$scopes"


```


## Middleware Api (Api1)

### Set the sign in audience and Application ID URI for Api2

```shell
az ad app update --id $appIdApi1 \
    --sign-in-audience 'AzureADMyOrg' \
    --identifier-uris api://$appIdApi1
```

### Expose scopes

```shell
scopeNameApi1=UseApi
scopes=$( jq -n \
    --arg id $(uuidgen) \
    --arg scope $scopeNameApi1 \
    '{"api":{"oauth2PermissionScopes":[{"adminConsentDescription":"Allow access to the dummy api","adminConsentDisplayName":"Dummy Api Access","id":$id,"isEnabled":true,"type":"User","userConsentDescription":"Allow access to the dummy api","userConsentDisplayName":"Dummy Api Access","value":$scope}]}}' )

# This should be the way to do it, but az cli lags behind
#$oauth2Permissions | Out-File -FilePath .\oauth2Permissions.json
#az ad app update --id $appIdApi2 --set api.oauth2PermissionScopes=@oauth2Permissions.json

# use this instead
az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi1 \
    --body "$scopes"

```

### Set API permissions

```shell
# Get the scopes for Api2
appsWithScopes=$(az rest --method GET \
    --uri https://graph.microsoft.com/v1.0/myorganization/me/ownedObjects/$/Microsoft.Graph.Application)


appScope=$(echo $appsWithScopes | jp "value[?(api.oauth2PermissionScopes[0].value=='$scopeNameApi2' && appId=='$appIdApi2')].{appId:appId,scopeId:api.oauth2PermissionScopes[0].id,value:api.oauth2PermissionScopes[0].value}")

permissions=$(jq -n \
    --arg appId $(echo $appScope | jq -r .[0].appId) \
    --arg scopeId $(echo $appScope | jq -r .[0].scopeId) \
    '[{"resourceAppId":$appId,"resourceAccess":[{"id":$scopeId,"type":"Scope"}]}]')

az ad app update --id $objectIdAppRegApi1 \
    --required-resource-accesses "$permissions"

```

### Set the knownClientApplications

```shell
knownClientApps=$( jq -n \
    --arg appId $appIdApp \
    '{"api":{"knownClientApplications":[$appId]}}' )
	
az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi1 \
    --body "$knownClientApps"
```

## Configure the Web App (App)


### Set the sign in audience and Application ID URI for App

```shell
az ad app update --id $appIdApp \
    --sign-in-audience 'AzureADMyOrg'
```

### Add the web platform and reply to address

```shell
# NOTE: Change the web address to address for the web app
appWebUris='https://localhost:7286/signin-oidc'

az ad app update --id $objectIdAppRegApp \
    --web-redirect-uris $appWebUris \
    --enable-access-token-issuance true \
    --enable-id-token-issuance true
```


### Set API permissions

```shell
# Get the scopes for Api1 & Api2
appsWithScopes=$(az rest --method GET \
    --uri https://graph.microsoft.com/v1.0/myorganization/me/ownedObjects/$/Microsoft.Graph.Application)

# This adds the scopes for both Api1 and Api2, while only 2 should be required. 
# appScope=$(echo $appsWithScopes | jp "value[?(api.oauth2PermissionScopes[0].value=='$scopeNameApi1' && (appId=='$appIdApi1' || appId=='$appIdApi2'))].{appId:appId,scopeId:api.oauth2PermissionScopes[0].id,value:api.oauth2PermissionScopes[0].value}")

#permissions=$(jq -n \
#    --arg appId1 $(echo $appScope | jq -r .[0].appId) \
#    --arg scopeId1 $(echo $appScope | jq -r .[0].scopeId) \
#    --arg appId2 $(echo $appScope | jq -r .[1].appId) \
#    --arg scopeId2 $(echo $appScope | jq -r .[1].scopeId) \
#    '[{"resourceAppId":$appId1,"resourceAccess":[{"id":$scopeId1,"type":"Scope"}]},{"resourceAppId":$appId2,"resourceAccess":[{"id":$scopeId2,"type":"Scope"}]}]')

appScope=$(echo $appsWithScopes | jp "value[?(api.oauth2PermissionScopes[0].value=='$scopeNameApi1' && appId=='$appIdApi1')].{appId:appId,scopeId:api.oauth2PermissionScopes[0].id,value:api.oauth2PermissionScopes[0].value}")

permissions=$(jq -n \
    --arg appId1 $(echo $appScope | jq -r .[0].appId) \
    --arg scopeId1 $(echo $appScope | jq -r .[0].scopeId) \
    '[{"resourceAppId":$appId1,"resourceAccess":[{"id":$scopeId1,"type":"Scope"}]}]')


az ad app update --id $objectIdAppRegApp \
    --required-resource-accesses "$permissions"

```


## Show configuration information

```shell
instance=https://login.microsoftonline.com/
domain=$(az rest --method get --url https://graph.microsoft.com/v1.0/domains --query 'value[?isDefault].id' -o tsv)
tenantId=$(az account show --query tenantId -o tsv)
echo ''
echo '=====Backend Api (Api2) appsettings.json====='
echo ''
echo '  "AzureAd": {'
echo '    "Instance": "'$instance'",'
echo '    "Domain": "'$domain'",'
echo '    "TenantId": "'$tenantId'",'
echo '    "ClientId": "'$appIdApi2'",'
echo '    "Scopes": "'$scopeNameApi2'",'
echo '    "CallbackPath": "/signin-oidc"'
echo '  }'
echo ''
echo '=====Middleware Api (Api1) appsettings.json====='
echo ''
echo '  "AzureAd": {'
echo '    "Instance": "'$instance'",'
echo '    "Domain": "'$domain'",'
echo '    "TenantId": "'$tenantId'",'
echo '    "ClientId": "'$appIdApi1'",'
echo '    "ClientSecret": "'$appSecretApi1'",'
echo '    "Scopes": "'$scopeNameApi1'",'
echo '    "CallbackPath": "/signin-oidc"'
echo '  },'
echo '  "<api2>": { // Replace <api2> with the name of the backend api used in code'
echo '    "Scopes": "api://'$appIdApi2'/.default",'
echo '    "ApiBaseAddress": "https://localhost:7090" // Replace with the base address of the backend api'
echo '  }'
echo ''
echo '=====Web App (App) appsettings.json====='
echo ''
echo '  "AzureAd": {'
echo '    "Instance": "'$instance'",'
echo '    "Domain": "'$domain'",'
echo '    "TenantId": "'$tenantId'",'
echo '    "ClientId": "'$appIdApp'",'
echo '    "ClientSecret": "'$appSecretApp'",'
echo '    "CallbackPath": "/signin-oidc",'
echo '    "SignedOutCallbackPath": "/signout-oidc"'
echo '  },'
echo '  "<api1>": { // Replace <api1> with the name of the middleware api used in code'
echo '    "Scopes": "api://'$appIdApi1'/.default",'
echo '    "ApiBaseAddress": "https://localhost:7287" // Replace with the base address of the backend api'
echo '  }'
echo ''


```