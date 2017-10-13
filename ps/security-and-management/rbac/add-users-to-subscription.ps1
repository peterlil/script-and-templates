## Log in to the subscription
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

## Add the user

# List available roles
#Get-AzureRmRoleDefinition | FT Name, Description
Get-AzureRmRoleAssignment -RoleDefinitionName Contributor

Connect-AzureAD
New-AzureADMSInvitation -InvitedUserDisplayName 'Sailor Man' -InvitedUserEmailAddress 'sail@live.se' -SendInvitationMessage $True -InviteRedirectUrl "http://portal.azure.com"

New-Azure

Get-Command -Module AzureAD
New-AzureRmRoleAssignment -SignInName 'sail@live.se' -RoleDefinitionName "Contributor" -Scope "/subscriptions/b777d777-59d9-4ef0-8532-725b550c2eaa"