# STEP 1: Sign-in to Azure via Azure Resource Manager

Login-AzureRmAccount

# STEP 2: Select Azure Subscription

$subscriptionId = 
    ( Get-AzureRmSubscription |
        Out-GridView `
          -Title "Select an Azure Subscription …" `
          -PassThru
    ).Id

Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/upload-generalized-managed

$vmName = "vgw10vsee"
$computerName = "vgw10vsee"
$vmSize = "Standard_DS2_v3"
$location = "West Europe" 
$imageName = "vgw10vsee"
$urlOfUploadedImageVhd = ""
$rgName = ""

$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $urlOfUploadedImageVhd
$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig