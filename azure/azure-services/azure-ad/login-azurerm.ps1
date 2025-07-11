Login-AzureRmAccount

# STEP 2: Select Azure Subscription
$subscriptionId = 
    ( Get-AzureRmSubscription |
        Out-GridView `
          -Title "Select an Azure Subscription …" `
          -PassThru
    ).Id

Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

