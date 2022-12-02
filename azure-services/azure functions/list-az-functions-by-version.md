# Azure Functions Inventory

1. Create a file called functions.ps1, copy + paste the code below.
2. Azure CLI with az graph query is required. 
3. Log in to Azure using az login

Note: Be aware if not providing subscriptionId this will query all subscriptions that the user has access to.  

```PowerShell
[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)]
    [string] $subscriptionId

    )
# If $subscriptionId is not provided the query will span over all subscriptions that the user has access to. 

if($subscriptionId -ne ""){
    "Subscription ID"
    $query = "resources | where type == 'microsoft.web/sites' and kind == 'functionapp' and subscriptionId == '"+$subscriptionId+"' | project name, resourceGroup, subscriptionId"
}
else {
    "No 
    Subscription ID"
    $query = "resources | where type == 'microsoft.web/sites' and kind == 'functionapp' | project name, resourceGroup, subscriptionId"
}

$functions = az graph query -q $query  | ConvertFrom-Json

foreach($function in $functions.data)
{
    $uri = "/subscriptions/"+$function.subscriptionId+"/resourceGroups/"+$function.resourceGroup+"/providers/Microsoft.Web/sites/"+$function.name+"/config/appsettings/list?api-version=2022-03-01"
    $version = (az rest --method POST --uri $uri --query properties.FUNCTIONS_EXTENSION_VERSION -o tsv )
    Write-Host ("SubscriptionId: " + $function.subscriptionId + " Resourcegroup: " + $function.resourceGroup + " Name: "+ $function.name + " Version: " + $version )
}

```