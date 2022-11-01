# On-behalf-of OAuth 2.0 flow sample

## Generate the code for the apis

This walk-through is based on ASP.NET for .NET 6.0, and consist of one web app and two apis, api1 and api2. The web app calls api1, and api1 calls api2. The web app is configured to use the on-behalf-of flow.

Generate the code for the three projects. The project generation code can be executed in PowerShell or Bash, but .NET 6.0 needs to be installed in the environment is run.

_(PowerShell)_
```dotnetcli
# web app
dotnet new webapp --auth SingleOrg -o obo-web-client
# api1
dotnet new webapi --auth SingleOrg -o obo-api-client
# api2
dotnet new webapi --auth SingleOrg -o obo-api-server
```

Open a bash shell and navigate to the directory where the `dotnet new...` commands were executed.

_(bash)_
```bash
# get the application url for the web app
IFS=';' read -ra URL <<< "$(cat obo-web-client/Properties/launchSettings.json | jq -r ".profiles.obo_web_client.applicationUrl")"
appApplicationUrl=${URL[0]}
# get the application url for api 1
IFS=';' read -ra URL <<< "$(cat obo-api-client/Properties/launchSettings.json | jq -r ".profiles.obo_api_client.applicationUrl")"
api1ApplicationUrl=${URL[0]}
# get the application url for api 2
IFS=';' read -ra URL <<< "$(cat obo-api-server/Properties/launchSettings.json | jq -r ".profiles.obo_api_server.applicationUrl")"
api2ApplicationUrl=${URL[0]}
```

## Code changes

Now, add all projects to one solution in Visual Studio, and make the following changes.

### In the web app (obo-web-client project)

#### Add packages and change code

Run `dotnet add package Microsoft.Identity.Web` in _Developer PowerShell_ to add the Microsoft.Identity.Web package to the web app. Make sure you are in the same folder as the .csproj file when you run it.

In the `Program.cs` file, modify the file to look like the following:

```csharp
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Azure.Identity;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;

var builder = WebApplication.CreateBuilder(args);

string[] scopes = new string[]
{
    builder.Configuration.GetValue<string>("obo-api-client-sample:Scopes")
};

// Add services to the container.
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"), "OpenIdConnect", "Cookies", true)
        .EnableTokenAcquisitionToCallDownstreamApi(scopes)
            .AddInMemoryTokenCaches();

// If using Azure App Configuration instead of appsettings.json
//string appConfigCnStr = builder.Configuration.GetConnectionString("AppConfig");
//builder.Configuration.AddAzureAppConfiguration(options =>
//{
//    options.Connect(appConfigCnStr)
//        .ConfigureKeyVault(async kv =>
//        {
//            kv.SetCredential(new DefaultAzureCredential());
//        });
//});

builder.Services.AddAuthorization(options =>
{
    // By default, all incoming requests will be authorized according to the default policy.
    options.FallbackPolicy = options.DefaultPolicy;
});

builder.Services.AddRazorPages()
    .AddMicrosoftIdentityUI();

// Add HttpClient to the container.
builder.Services.AddHttpClient();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapRazorPages();
app.MapControllers();

// Below from https://stackoverflow.com/questions/51921885/why-claimsprincipal-current-is-returned-null-even-when-the-user-is-authenticated
// Populates System.Security.Claims.ClaimsPrincipal.Current
app.Use((context, next) =>
{
    Thread.CurrentPrincipal = context.User;
    return next(context);
});

app.Run();
```

Add a folder `Model` and create the file `TemperatureSample.cs` in it and add the following content in the file.

```csharp
using System.Text.Json.Serialization;
namespace obo_web_client
{
    public class TemperatureSample
    {
        [JsonPropertyName("date")]
        public DateTime Date { get; set; }
        [JsonPropertyName("temperatureC")]
        public int TemperatureC { get; set; }
        [JsonPropertyName("summary")]
        public string Summary { get; set; }
    }
}
```

Open `Index.cshtml` and make it look like this:

```html	
@page
@model IndexModel
@{
    ViewData["Title"] = "Home page";
}

<div class="text-center">
    <h1 class="display-4">Welcome</h1>
    <p>
        <table class="table table-dark table-striped">
            <thead>
                <tr>
                    <th scope="col">Date</th>
                    <th scope="col">Temperature (C)</th>
                    <th scope="col">Summary</th>
                </tr>
            </thead>
            <tbody>
                @if (ViewData.Keys.Contains("WeatherForecast"))
                {
                    foreach (var forecast in (List<TemperatureSample>?)(ViewData["WeatherForecast"]))
                    {
                        <tr>
                            <td>@forecast.Date.ToShortDateString()</td>
                            <td>@forecast.TemperatureC</td>
                            <td>@forecast.Summary</td>
                        </tr>
                    }
                }
            </tbody>
        </table>
    </p>
</div>
```

Open `Index.cshtml.cs` and make it look like this:

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Net.Http.Headers;
using Microsoft.Identity.Web;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Diagnostics;

namespace obo_web_client.Pages;

[Authorize]
public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    readonly ITokenAcquisition _tokenAcquisition;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public IndexModel(ILogger<IndexModel> logger,
        IConfiguration configuration,
        ITokenAcquisition tokenAcquisition,
        IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _configuration = configuration;
        _tokenAcquisition = tokenAcquisition;
        _httpClientFactory = httpClientFactory;
    }

    public void OnGet()
    {
        // debug claims
        var claims = System.Security.Claims.ClaimsPrincipal.Current.Claims;
        
        var client = _httpClientFactory.CreateClient();
        string scope = _configuration["obo-api-client-sample:Scopes"];
        var accessToken = _tokenAcquisition.GetAccessTokenForUserAsync(new[] { scope }).Result; // Must have client secret to call an api
        Debug.WriteLine(accessToken);
        client.BaseAddress = new Uri(_configuration["obo-api-client-sample:ApiBaseAddress"]);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        var response = client.GetAsync("weatherforecast").Result;
        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content.ReadAsStringAsync().Result;
            var weatherForecast = JsonSerializer.Deserialize<List<TemperatureSample>>(responseContent);
            ViewData["WeatherForecast"] = weatherForecast;
            return;
        }

        throw new ApplicationException($"Status code: {response.StatusCode}, Error: {response.ReasonPhrase}");
    }

}
```

### In the api1 (obo-api-client project)

#### Change the code

In the `Program.cs` file, change the following lines:

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));
```

To this:

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"))
        .EnableTokenAcquisitionToCallDownstreamApi()
            .AddInMemoryTokenCaches();
```

Open the file `WeatherForecast.cs` and make it look like this:

```csharp
namespace obo_api_client;
using System.Text.Json.Serialization;

public class WeatherForecast
{
    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("temperatureC")]
    public int TemperatureC { get; set; }

    [JsonPropertyName("temperatureF")]
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);

    [JsonPropertyName("summary")]
    public string? Summary { get; set; }
}
```

Open the file `WeatherForecastController.cs` and make it look like this:

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.Resource;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using obo_api_client;
using Azure.Core;
using Microsoft.Identity.Client;
using System.Diagnostics;

namespace obo_api_client.Controllers;

[Authorize]
[ApiController]
[Route("[controller]")]
[RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;
    readonly ITokenAcquisition _tokenAcquisition;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public WeatherForecastController(ILogger<WeatherForecastController> logger,
        IConfiguration configuration,
        ITokenAcquisition tokenAcquisition,
        IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _configuration = configuration;
        _tokenAcquisition = tokenAcquisition;
        _httpClientFactory = httpClientFactory;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        var client = _httpClientFactory.CreateClient();
        var scope = _configuration["obo-api-server-sample:Scopes"];
        string accessToken = string.Empty;

        try
        {
            accessToken = _tokenAcquisition.GetAccessTokenForUserAsync(new[] { scope }).Result; // Must have client secret to call an api
            Debug.WriteLine(accessToken);
        }
        catch (MicrosoftIdentityWebChallengeUserException ex)
        {
            _tokenAcquisition.ReplyForbiddenWithWwwAuthenticateHeader(new[] { scope }, ex.MsalUiRequiredException);
            return new List<WeatherForecast>();
        }
        catch (MsalUiRequiredException ex)
        {
            _tokenAcquisition.ReplyForbiddenWithWwwAuthenticateHeader(new[] { scope }, ex);
            return new List<WeatherForecast>();
        }


        client.BaseAddress = new Uri(_configuration["obo-api-server-sample:ApiBaseAddress"]);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        var response = client.GetAsync("weatherforecast").Result;
        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content.ReadAsStringAsync().Result;
            var weatherForecast = JsonSerializer.Deserialize<List<WeatherForecast>>(responseContent);
            
            return weatherForecast;
        }

        throw new ApplicationException($"Status code: {response.StatusCode}, Error: {response.ReasonPhrase}");
    }
}

```

Done with the code changes, no need to change anything in api2 (obo-api-server project).

## Creating the Azure AD app registrations

_(bash)_
```shell
# Create the app regs for the app and apis. 
appRegAppDisplayName=app
appRegApi1DisplayName=api1
appRegApi2DisplayName=api2

exposedScope=UseApi

echo "Creating app registration $appRegAppDisplayName"
appRegApp=$(az ad sp create-for-rbac --display-name $appRegAppDisplayName)
appIdApp=$(echo $appRegApp | jq -r '.appId')
appSecretApp=$(echo $appRegApp | jq -r '.password')
objectIdAppRegApp=$(az ad app show --id $appIdApp --query '{id: id}' -o tsv)

echo "Creating app registration $appRegApi1DisplayName"
appRegApi1=$(az ad sp create-for-rbac --display-name $appRegApi1DisplayName)
appIdApi1=$(echo $appRegApi1 | jq -r '.appId')
appSecretApi1=$(echo $appRegApi1 | jq -r '.password')
objectIdAppRegApi1=$(az ad app show --id $appIdApi1 --query '{id: id}' -o tsv)

echo "Creating app registration $appRegApi2DisplayName"
appRegApi2=$(az ad sp create-for-rbac --display-name $appRegApi2DisplayName)
appIdApi2=$(echo $appRegApi2 | jq -r '.appId')
objectIdAppRegApi2=$(az ad app show --id $appIdApi2 --query '{id: id}' -o tsv)

echo "Configuring app registration $appRegApi2DisplayName"
# Set the sign in audience and Application ID URI for Api2
az ad app update --id $appIdApi2 \
    --sign-in-audience 'AzureADMyOrg' \
    --identifier-uris api://$appIdApi2

# Expose scopes
scopeNameApi2=$exposedScope
scopes=$( jq -n \
    --arg id $(uuidgen) \
    --arg scope $scopeNameApi2 \
    '{"api":{"oauth2PermissionScopes":[{"adminConsentDescription":"Allow access to the dummy api","adminConsentDisplayName":"Dummy Api Access","id":$id,"isEnabled":true,"type":"User","userConsentDescription":"Allow access to the dummy api","userConsentDisplayName":"Dummy Api Access","value":$scope}]}}' )

# This should be the way to do it, but feels like az cli lags behind
#$oauth2Permissions | Out-File -FilePath .\oauth2Permissions.json
#az ad app update --id $appIdApi2 --set api.oauth2PermissionScopes=@oauth2Permissions.json

# use this rest call instead
az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi2 \
    --body "$scopes"

echo "Configuring app registration $appRegApi1DisplayName"

# Set the sign in audience and Application ID URI for Api2
az ad app update --id $appIdApi1 \
    --sign-in-audience 'AzureADMyOrg' \
    --identifier-uris api://$appIdApi1

# Expose scopes
scopeNameApi1=$exposedScope
scopes=$( jq -n \
    --arg id $(uuidgen) \
    --arg scope $scopeNameApi1 \
    '{"api":{"oauth2PermissionScopes":[{"adminConsentDescription":"Allow access to the dummy api","adminConsentDisplayName":"Dummy Api Access","id":$id,"isEnabled":true,"type":"User","userConsentDescription":"Allow access to the dummy api","userConsentDisplayName":"Dummy Api Access","value":$scope}]}}' )

az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi1 \
    --body "$scopes"

# Set API permissions
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

# Set the knownClientApplications
knownClientApps=$( jq -n \
    --arg appId $appIdApp \
    '{"api":{"knownClientApplications":[$appId]}}' )
	
az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi1 \
    --body "$knownClientApps"


echo "Configuring app registration $appRegAppDisplayName"
# Set the sign in audience and Application ID URI for App
az ad app update --id $appIdApp \
    --sign-in-audience 'AzureADMyOrg'

# Add the web platform and reply to address
az ad app update --id $objectIdAppRegApp \
    --web-redirect-uris "$appApplicationUrl/signin-oidc" \
    --enable-access-token-issuance true \
    --enable-id-token-issuance true

# Set API permissions
# Get the scopes for Api1 & Api2
appsWithScopes=$(az rest --method GET \
    --uri https://graph.microsoft.com/v1.0/myorganization/me/ownedObjects/$/Microsoft.Graph.Application)

appScope=$(echo $appsWithScopes | jp "value[?(api.oauth2PermissionScopes[0].value=='$scopeNameApi1' && appId=='$appIdApi1')].{appId:appId,scopeId:api.oauth2PermissionScopes[0].id,value:api.oauth2PermissionScopes[0].value}")

permissions=$(jq -n \
    --arg appId1 $(echo $appScope | jq -r .[0].appId) \
    --arg scopeId1 $(echo $appScope | jq -r .[0].scopeId) \
    '[{"resourceAppId":$appId1,"resourceAccess":[{"id":$scopeId1,"type":"Scope"}]}]')

az ad app update --id $objectIdAppRegApp \
    --required-resource-accesses "$permissions"

echo "#####   Configuration information   #####"

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
echo '  "obo-api-server-sample": { '
echo '    "Scopes": "api://'$appIdApi2'/.default",'
echo '    "ApiBaseAddress": "'$api2ApplicationUrl'"'
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
echo '  "obo-api-client-sample": { '
echo '    "Scopes": "api://'$appIdApi1'/.default",'
echo '    "ApiBaseAddress": "'$api1ApplicationUrl'"'
echo '  }'
echo ''

```

## Create the app roles

_(bash)_
```bash
# create user-role for the app users for each appreg (necessary to get the roles claim in the token)
displayNames=('app' 'api1' 'api2')
roleName='app-user'

role=$(jq -n '[
        {"allowedMemberTypes": [
            "User"
        ],
        "description": "'$appDisplayName' users can use the application/api",
        "displayName": "'$appDisplayName' user",
        "isEnabled": "true",
        "value": "'$roleName'"}]')

for appName in ${displayNames[@]}; do
	echo "Creating role $appName"
	
    oid=$(az ad app list --query "[?displayName=='$appName'].id" -o tsv)
	
    az ad app update --id $oid --app-roles "$role"
 
done

# make sure app role assignements are mandatory on the web app
az ad sp update --id $appIdApp --set appRoleAssignmentRequired=true

```

## Create the Azure AD group and add a user to the group

_(bash)_
```bash
# Create the Azure AD group
az ad group create --display-name 'app-users' \
                   --mail-nickname 'app-users'

# Add the user to the group
userName=appuser@mngenv319828.onmicrosoft.com
az ad group member add --group 'app-users' \
                       --member-id $(az ad user show --id $userName --query "id" -o tsv)
```

## Assign roles to groups

_(bash)_
```shell
groupName=app-users
roleName=app-user
displayNames=('app' 'api1' 'api2')

goid=$(az ad group show --group "$groupName" --query "id" --output tsv)

for appName in ${displayNames[@]}; do
    appId=$(az ad app list --query "[?displayName=='$appName'].appId" -o tsv)
    roId=$(az ad app show --id $appId --query "appRoles[?value=='$roleName'].id" -o tsv)
    spId=$(az ad sp list --all --query "[?appId=='$appId'].id" -o tsv)
    az rest -m POST -u https://graph.microsoft.com/v1.0/groups/$goid/appRoleAssignments -b "{\"principalId\": \"$goid\", \"resourceId\": \"$spId\",\"appRoleId\": \"$roId\"}"
done
```

## Done with web client
You may now test the apps.

## Now let's make a console app the client instead of the web app

Add an app registration for a native app .

_(bash)_
```bash
appRegNativeAppDisplayName=NativeApp

echo "Creating app registration $appRegNativeAppDisplayName"
appRegNativeApp=$(az ad sp create-for-rbac --display-name $appRegNativeAppDisplayName)
appIdNativeApp=$(echo $appRegNativeApp | jq -r '.appId')
objectIdAppRegNativeApp=$(az ad app show --id $appIdNativeApp --query '{id: id}' -o tsv)

# Set the known client applications on Api1
knownClientApps=$( jq -n \
    --arg appId $appIdApp \
    --arg appIdNative $appIdNativeApp \
    '{"api":{"knownClientApplications":[$appId,$appIdNative]}}' )

az rest --method PATCH \
    --headers 'Content-Type=application/json' \
    --uri https://graph.microsoft.com/v1.0/applications/$objectIdAppRegApi1 \
    --body "$knownClientApps"

echo "Configuring app registration $appRegNativeAppDisplayName"
# Set the sign in audience and Application ID URI for App
az ad app update --id $appIdNativeApp \
    --sign-in-audience 'AzureADMyOrg'

# Add the native app platform and reply to address
az ad app update --id $objectIdAppRegNativeApp \
    --is-fallback-public-client \
    --public-client-redirect-uris "http://localhost"

# Set API permissions
# Get the scopes for Api1 & Api2
appsWithScopes=$(az rest --method GET \
    --uri https://graph.microsoft.com/v1.0/myorganization/me/ownedObjects/$/Microsoft.Graph.Application)

appScope=$(echo $appsWithScopes | jp "value[?(api.oauth2PermissionScopes[0].value=='$scopeNameApi1' && appId=='$appIdApi1')].{appId:appId,scopeId:api.oauth2PermissionScopes[0].id,value:api.oauth2PermissionScopes[0].value}")

permissions=$(jq -n \
    --arg appId1 $(echo $appScope | jq -r .[0].appId) \
    --arg scopeId1 $(echo $appScope | jq -r .[0].scopeId) \
    '[{"resourceAppId":$appId1,"resourceAccess":[{"id":$scopeId1,"type":"Scope"}]}]')

az ad app update --id $objectIdAppRegNativeApp \
    --required-resource-accesses "$permissions"

# Create the app role on the app registration
echo "Creating role for $appRegNativeAppDisplayName"
az ad app update --id $objectIdAppRegNativeApp --app-roles "$role"

# make sure app role assignements are mandatory on the console app
az ad sp update --id $appIdNativeApp --set appRoleAssignmentRequired=true

# assign the app-user role to the app-users group
goId=$(az ad group show --group "$groupName" --query "id" --output tsv)
roId=$(az ad app show --id $appIdNativeApp --query "appRoles[?value=='$roleName'].id" -o tsv)
spId=$(az ad sp list --all --query "[?appId=='$appIdNativeApp'].id" -o tsv)
az rest -m POST -u https://graph.microsoft.com/v1.0/groups/$goid/appRoleAssignments -b "{\"principalId\": \"$goId\", \"resourceId\": \"$spId\",\"appRoleId\": \"$roId\"}"

```


Generate the code for the console app. 

_(PowerShell)_
```dotnetcli
# console app (native app)
dotnet new console -o obo-console-client
```

Add the `Microsoft.Identity.Client` nuget package to the console app.
Execute this in the same folder as the console app project file.

_(PowerShell)_
```dotnetcli
cd obo-console-client
dotnet add package Microsoft.Identity.Client
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extensions.Configuration.Json
cd ..
```

Add an `appsettings.json` file to the console app project. Add the output from the script below to the `appsettings.json` file.

_(bash)_
```bash
echo ''
echo '{'
echo '  "AzureAd": {'
echo '    "TenantId": "'$tenantId'",'
echo '    "ClientId": "'$appIdApp'",'
echo '    "RedirectUrl": "http://localhost"'
echo '  },'
echo '  "Api1": { '
echo '    "Scope": "api://'$appIdApi1'/.default",'
echo '    "BaseUrl": "'$api1ApplicationUrl'"'
echo '  }'
echo '}'
```

Open the project file in VSCode and add the following `ItemGroup` to the project file.

```xml
  <ItemGroup>
    <None Update="appsettings.json">
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </None>
  </ItemGroup>
```

Add a file named `TemperatureSamples.cs` to the same directory as the console app project file. Add the following code to the file.

```csharp
using System.Text.Json.Serialization;
namespace ConsoleApp1
{
    public class TemperatureSample
    {
        [JsonPropertyName("date")]
        public DateTime Date { get; set; }
        [JsonPropertyName("temperatureC")]
        public int TemperatureC { get; set; }
        [JsonPropertyName("summary")]
        public string Summary { get; set; }
    }
}
```

Replace the content of the `Program.cs` file with the following code.

```csharp
using Microsoft.Identity.Client;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class Program
    {
        private static HttpClient _sharedClient = new();

        static async Task Main(string[] args)
        {
            var configuration =  new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile($"appsettings.json");

            var config = configuration.Build();

            var app = PublicClientApplicationBuilder.Create(config["AzureAD:ClientId"])
                .WithAuthority(AzureCloudInstance.AzurePublic, config["AzureAD:TenantId"])
                .WithRedirectUri(config["AzureAD:RedirectUri"])
                .Build();
            
            string[] scopes = { config["Api1:Scope"] };

            AuthenticationResult result = await app.AcquireTokenInteractive(scopes).ExecuteAsync();

            Console.WriteLine($"Token:\t{result.AccessToken}");
            _sharedClient.BaseAddress = new Uri(config["Api1:BaseUrl"]);
            _sharedClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            _sharedClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            using HttpResponseMessage response = await _sharedClient.GetAsync("weatherforecast");

            if (response.IsSuccessStatusCode)
            {
                var responseContent = response.Content.ReadAsStringAsync().Result;
                var weatherForecast = JsonSerializer.Deserialize<List<TemperatureSample>>(responseContent);
                foreach (var sample in weatherForecast)
                {
                    Console.WriteLine($"Date: {sample.Date}, Temperature: {sample.TemperatureC}, Summary: {sample.Summary}");
                }
            }
        }
    }
}
```



Run and test the console app.

## References
[Protected web API: Code configuration](https://learn.microsoft.com/en-us/azure/active-directory/develop/scenario-protected-web-api-app-configuration) \
[How to implement Interactive Authentication using MSAL dotNET](https://techdirectarchive.com/2022/06/06/how-to-implement-interactive-authentication-by-using-msal-net/comment-page-1/)

