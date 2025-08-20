# VM Scale Sets

## Project vmss-infra-test

### Creation

Create the project. 

```powershell
dotnet new webapi -n ServerNameApi
```

Add the using `using System.Net;` to `Program.cs`, and also replace the weather api with this code:
```csharp
app.MapGet("/servername", () =>
{
    return Dns.GetHostName();
})
.WithName("GetServerName");
```


### Provision

```bash
rgName="vmss-infra-test"
adminUsername=""
adminPassword=""
az group create -n $rgName -l "sweden central"
az deployment group create --resource-group $rgName --template-file bicep/vmss-servernameapi.bicep --parameters adminUsername="$adminUsername" adminPassword="$adminPassword" --debug
```
