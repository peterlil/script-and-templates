param(
	[Parameter(Mandatory=$true)][string] $aadClientSecret,
	[Parameter(Mandatory=$true)][string] $keyVaultName,
	[Parameter(Mandatory=$true)][string] $keyVaultResourceGroupName,
	[Parameter(Mandatory=$true)][string] $vmEncryptionKeyName,
	[Parameter(Mandatory=$true)][string] $appDisplayName,
	[Parameter(Mandatory=$true)][ref] $aadClientId,
	[Parameter(Mandatory=$true)][ref] $aadServicePrincipalId
)

## STEP 1) CREATE A CLIENT ID IN AZURE AD
# Create the Azure AD Application if it does not exist
$azureAdApplication = Get-AzureRmADApplication -DisplayNameStartWith $appDisplayName
if( !$azureAdApplication )
{
	Write-Host 'Creating a new AAD Application.'
	$azureAdApplication = New-AzureRmADApplication -DisplayName $appDisplayName `
		-HomePage "https://www.microsoft.com/$appDisplayName" `
		-IdentifierUris "https://www.microsoft.com/$appDisplayName" -Password $aadClientSecret
}
$aadClientID.Value = $azureAdApplication.ApplicationId
Write-Host "AAD Application: $($azureAdApplication.ApplicationId)"

# Create the service principal, the principal to access KeyVault..., if it does not exist
$aadServicePrincipal = Get-AzureRmADServicePrincipal -SearchString $appDisplayName
if( !$aadServicePrincipal ) {
	Write-Host 'Creating a new AAD Service Principal.'
	$aadServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId
}
$aadServicePrincipalId = $aadServicePrincipal.Id
Write-Host "AAD Service Principal: $($aadServicePrincipal.Id)"

## STEP 2) SET THE Key Vault Access Policy on the service principal
$rgname = $keyVaultResourceGroupName
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $azureAdApplication.ApplicationId -PermissionsToKeys 'WrapKey' -PermissionsToSecrets 'Set' -ResourceGroupName $rgname
Write-Host 'KeyVault access updated.'

## STEP 3) Set up an encryption key if one does not exists.
$keyVaultKey = Get-AzureKeyVaultKey -VaultName $keyVaultName -Name $vmEncryptionKeyName
if( !$keyVaultKey )
{
	Write-Host 'Creating KeyVault key.'
	$keyVaultKey = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name $vmEncryptionKeyName -Destination Software
}

## STEP 4) Set keyvault permissions - No need here since this was set in the ARM template
#Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $rgname -EnabledForDiskEncryption
