# On-behalf-of OAuth 2.0 flow sample

## Generate the code for the apis

Using dotnet 6.0. [Protected web API: Code configuration](https://learn.microsoft.com/en-us/azure/active-directory/develop/scenario-protected-web-api-app-configuration)
Generate both apis. The api (client) that calls the second api (server).
dotnet new webapi --auth SingleOrg -o obo-api-client
dotnet new webapi --auth SingleOrg -o obo-api-server

Generate the webapp
dotnet new webapp --auth SingleOrg -o obo-web-client

## Starting with the obo-api-server

### Create an appreg

Use Azure CLI with [`create-for-rbac`](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) to cretae an app registration (an Application Object) with an attached Service Principal (Enterprise App).

```PowerShell
$appRegDisplayName='obo-api-server-sample'

$appReg = az ad sp create-for-rbac --display-name $appRegDisplayName
```

Make sure to store the content of `appReg` somewhere safe.

### Set the Application ID URI

Go to the Azure Portal -> Azure Active Directory -> App registrations -> Expose an API -> Click on _Set_ next to _Application ID URI_ and then _Save_ to save the suggested value.

### Expose a scope

Go to the Azure Portal -> Azure Active Directory -> App registrations -> Expose an API -> Click on _Add a scope_.

UseApi
Admins and users
UseApi
UseApi
UseApi
UseApi

### Copy details to the obo-api-server project

Change `appsettings.json`to this:

```json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "Domain": "<my-own-domain>.onmicrosoft.com",
    "TenantId": "<tenant id of <my-own-domain>.onmicrosoft.com<",
    "ClientId": "<client id of the app reg created above>",

    "Scopes": "access_as_user",
    "CallbackPath": "/signin-oidc"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

## Configuring with the obo-web-client

Create the appreg for the web client. This appreg will be used to first call the api-server and then to call the api-client.

```PowerShell
$appRegDisplayName='obo-web-client--both--sample'

$appReg = az ad sp create-for-rbac --display-name $appRegDisplayName
```

Make sure to store the content of `appReg` somewhere safe.

Assign the API permission to the appreg.
Go to the Azure Portal -> Azure Active Directory -> App registrations -> API permissions -> Add a permission (My APIs->obo-api-server-sample).

Front-channel logout URL: https://localhost:44321/signout-oidc

Go to the Azure Portal -> Azure Active Directory -> App registrations -> Authentication -> Add a platform (Web, https://localhost:7286/signin-oidc, Access Token (check), ID Tokens (check))

(Add the client secret to application.json)










// TODO: Create a new appreg for the client, which only can access the client api and see how that goes.



