# https://stackoverflow.com/questions/26049033/upload-files-to-one-drive-using-powershell


# get authorize code
Function Get-AuthroizeCode
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)][String]$ClientId,
        [Parameter(Mandatory=$true)][String]$RedirectURI
    )
    # the login url
    $loginUrl = "https://login.live.com/oauth20_authorize.srf?client_id=$ClientId&scope=onedrive.readwrite offline_access&response_type=code&redirect_uri=$RedirectURI";

    # open ie to do authentication
    $ie = New-Object -ComObject "InternetExplorer.Application"
    $ie.Navigate2($loginUrl) | Out-Null
    $ie.Visible = $True

    While($ie.Busy -Or -Not $ie.LocationURL.StartsWith($RedirectURI)) {
        Start-Sleep -Milliseconds 500
    }

    # get authorizeCode
    $authorizeCode = $ie.LocationURL.SubString($ie.LocationURL.IndexOf("=") + 1).Trim();
    $ie.Quit() | Out-Null

    RETURN $authorizeCode
}

# get access token and refresh token
Function New-AccessTokenAndRefreshToken
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)][String]$ClientId,
        [Parameter(Mandatory=$true)][String]$RedirectURI,
        [Parameter(Mandatory=$true)][String]$SecrectKey
    )
    # get authorize code firstly
    $AuthorizeCode = Get-AuthroizeCode -ClientId $ClientId -RedirectURI $RedirectURI

    $redeemURI = "https://login.live.com/oauth20_token.srf"
    $header = @{"Content-Type"="application/x-www-form-urlencoded"}

    $postBody = "client_id=$ClientId&redirect_uri=$RedirectURI&client_secret=$SecrectKey&code=$AuthorizeCode&grant_type=authorization_code"
    $response = Invoke-RestMethod -Headers $header -Method Post -Uri $redeemURI -Body $postBody

    $AccessRefreshToken = New-Object PSObject
    $AccessRefreshToken | Add-Member -Type NoteProperty -Name AccessToken -Value $response.access_token
    $AccessRefreshToken | Add-Member -Type NoteProperty -Name RefreshToken -Value $response.refresh_token

    RETURN $AccessRefreshToken
}

# get autheticate header
Function Get-AuthenticateHeader
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)][String]$AccessToken
    )

    RETURN @{"Authorization" = "bearer $AccessToken"}
}