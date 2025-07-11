# Script for creating public static IP addresses in Azure.
#
# Further reading: https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-deploy-static-pip-arm-ps


# Log in to Azure and select an Azure subscription.
Login-AzureRmAccount
$subscriptionId = 
    ( Get-AzureRmSubscription |
        Out-GridView `
          -Title "Select an Azure Subscription …" `
          -PassThru
    ).Id
Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

# Set variables 
$rgName   = "<rg-name>"
$location = "North Europe"

$dnsNameFormat  = "ws{0}"
# pip = Public IP
$pipNameFormat = "pip-ws{0}"
# How many addresses do you want to generate?
$addressCount = 20


for($i = 1; $i -le $addressCount; $i++) {
    $dnsName = [System.String]::Format($dnsNameFormat, $i.ToString("D2"))
    $pipName = [System.String]::Format($pipNameFormat, $i.ToString("D2"))
    $pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rgName -AllocationMethod Static -DomainNameLabel $dnsName -Location $location
}
