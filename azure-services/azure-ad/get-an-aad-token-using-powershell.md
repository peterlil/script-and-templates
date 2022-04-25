# Get an Azure AD token using PowerShell and Azure CLI

## User's delegated token

```powershell
# Well-known client id of PowerShell
$ClientID = '1950a258-227b-4e31-a9cf-717495945fc2'
# Setting the tenant id to common makes use of the user's home tenant
$TenantID = 'common'
# A resource to request access to
$Resource = "https://graph.microsoft.com/"

$DeviceCodeRequestParams = @{
    Method = 'POST'
    Uri    = "https://login.microsoftonline.com/$TenantID/oauth2/devicecode"
    Body   = @{
        client_id = $ClientId
        resource  = $Resource
    }
}

$DeviceCodeRequest = Invoke-RestMethod @DeviceCodeRequestParams
Write-Host $DeviceCodeRequest.message -ForegroundColor Yellow
```

```powershell
$TokenRequestParams = @{
    Method = 'POST'
    Uri    = "https://login.microsoftonline.com/$TenantId/oauth2/token"
    Body   = @{
        grant_type = "urn:ietf:params:oauth:grant-type:device_code"
        code       = $DeviceCodeRequest.device_code
        client_id  = $ClientId
    }
}
$TokenRequest = Invoke-RestMethod @TokenRequestParams

$TokenRequest.access_token
```

# References

https://blog.simonw.se/getting-an-access-token-for-azuread-using-powershell-and-device-login-flow/
https://github.com/slavizh/OMSSearch/blob/master/OMSSearch.psm1