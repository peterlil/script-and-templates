### Login with service principal by prompting user for username and password { ###

# Login with ApplicationID (ClientId) and the client secret
$cred = Get-Credential 

Add-AzureRmAccount -Credential $cred -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47 -ServicePrincipal

Select-AzureRmSubscription -SubscriptionId 05c25b78-003c-49ef-8f02-b24ca4aca086

### } Login with service principal by prompting user for username and password ###



### Login with service principal without prompting user for username and password { ###

$aadApplicationlId = '550c939f-d25b-47dd-a11a-55195bef2a47'

# Service Principal Secret
$password = ConvertTo-SecureString -String 'to.find.in.secret.store' -AsPlainText -Force

# Create the credential object
$cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $aadApplicationlId, $password

Add-AzureRmAccount -Credential $cred -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47 -ServicePrincipal

Select-AzureRmSubscription -SubscriptionId 05c25b78-003c-49ef-8f02-b24ca4aca086

### } Login with service principal without prompting user for username and password ###
