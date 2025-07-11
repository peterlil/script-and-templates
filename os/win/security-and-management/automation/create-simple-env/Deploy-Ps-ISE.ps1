# Variables
$ResourceGroupName = 'automation-playground'
$scriptBasePath = 'c:\src\github\peterlil\script-and-templates\security-and-management\automation\create-simple-env'
$TemplateParametersFile = "$($scriptBasePath)\Templates\azuredeploy.parameters.json"
$location = "West Europe"
$StorageAccountName = "saillivedeploywe"
$NoOfMonthsUntilExpired = 12

###############################################################################
# STEP 1: Sign-in to Azure via Azure Resource Manager
###############################################################################

Login-AzureRmAccount

###############################################################################
# STEP 2: Select Azure Subscription
###############################################################################
$subscriptionId = 
    ( Get-AzureRmSubscription |
        Out-GridView `
          -Title "Select an Azure Subscription" `
          -PassThru
    ).Id

Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

Set-Location $scriptBasePath

###############################################################################
#STEP 3: Create the storage account used for deployment
###############################################################################
Import-Module AzureRM.Resources

# Create the resourcegroup if it does not exists
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Force -ErrorAction SilentlyContinue

# Create the deployment storage account if it does not exists
New-AzureStorageAccount -StorageAccountName $StorageAccountName -Location $location -ErrorAction SilentlyContinue

###############################################################################
#STEP 4: Deploy the templates
###############################################################################

.\Deploy-AzureResourceGroup.ps1 `
	-StorageAccountName $StorageAccountName `
	-ResourceGroupName $ResourceGroupName `
	-ResourceGroupLocation $location `
	-TemplateFile "$($scriptBasePath)\templates\azuredeploy.json" `
	-TemplateParametersFile  $TemplateParametersFile `
	-ArtifactStagingDirectory '.' `
	-DSCSourceFolder '.\DSC' `
	-UploadArtifacts

###############################################################################
#STEP 5: Prepare for the Automation Run As account
###############################################################################

#Get hold of the JSON parameters
$TemplateParameters = ((Get-Content -Raw $TemplateParametersFile) | ConvertFrom-Json)
$AutomationAccountName = $TemplateParameters.parameters.automationAccountName.value
$ApplicationDisplayName = $AutomationAccountName

$CurrentDate = Get-Date
$EndDate = $CurrentDate.AddMonths($NoOfMonthsUntilExpired)
$KeyId = (New-Guid).Guid
$CertName = (New-Guid).Guid
$CertPath = Join-Path $env:TEMP ($CertName + ".pfx")
$CertPlainPasswordCredential = Get-Credential -Message "Enter the certificate password." -UserName "no-username-required"

$Cert = New-SelfSignedCertificate -DnsName $CertName -CertStoreLocation cert:\LocalMachine\My -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

$CertPassword = $CertPlainPasswordCredential.Password
Export-PfxCertificate -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) -FilePath $CertPath -Password $CertPassword -Force | Write-Verbose

# c:\Users\peterlil\AppData\Local\Temp\f8159f81-92c0-4978-93d4-3259a753edc9.pfx 
$PFXCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate -ArgumentList @($CertPath, ($CertPlainPasswordCredential.GetNetworkCredential().Password))
$KeyValue = [System.Convert]::ToBase64String($PFXCert.GetRawCertData())

# Use Key credentials
$Application = New-AzureRmADApplication `
    -DisplayName $ApplicationDisplayName `
    -HomePage ("http://" + $ApplicationDisplayName) `
    -IdentifierUris ("http://" + $KeyId) `
    -CertValue $keyValue `
    -EndDate $EndDate `
    -StartDate $CurrentDate 

#$ToBeRemoved = Get-AzureRmADApplication -IdentifierUri ("http://" + $KeyId)
#Remove-AzureRmADApplication -ObjectId $ToBeRemoved.ObjectId

New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId 
Get-AzureRmADServicePrincipal | Where-Object {$_.ApplicationId -eq $Application.ApplicationId} 


$NewRole = $null
$Retries = 0;
While ($NewRole -eq $null -and $Retries -le 6)
{
   # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
   Start-Sleep 5
   New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
   Start-Sleep 10
   $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
   $Retries++;
} 

# Get the tenant id for this subscription
$SubscriptionInfo = Get-AzureRmSubscription -SubscriptionId $subscriptionId
$TenantID = $SubscriptionInfo | Select-Object TenantId -First 1

# Create the automation resources
New-AzureRmAutomationCertificate -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
	-Path $CertPath -Name AzureRunAsCertificate -Password $CertPassword -Exportable | write-verbose

# Create a Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal.
$ConnectionAssetName = "AzureRunAsConnection"
Remove-AzureRmAutomationConnection -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $ConnectionAssetName -Force -ErrorAction SilentlyContinue
$ConnectionFieldValues = @{"ApplicationId" = $Application.ApplicationId; "TenantId" = $TenantID.TenantId; "CertificateThumbprint" = $Cert.Thumbprint; "SubscriptionId" = $SubscriptionId}
New-AzureRmAutomationConnection -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $ConnectionAssetName -ConnectionTypeName AzureServicePrincipal -ConnectionFieldValues $ConnectionFieldValues


# AzureRunAsConnection