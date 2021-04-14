
# https://ucstatus.com/2017/09/19/how-to-change-the-display-name-of-a-guest-in-microsoft-teams/#:~:text=%20How%20to%20change%20the%20display%20name%20of,in%20the%20Azure%20AD%20Admin%20portal.%20More%20

# Microsoft Online Services Sign-In Assistant for IT Professionals RTW - https://www.microsoft.com/en-sa/download/details.aspx?id=28177

# https://docs.microsoft.com/en-us/answers/questions/259835/powershell-login-error.html
# In PowerShell 5       -> Import-Module AzureAD
# In PowerShell 7+/Core -> Import-Module AzureAD -UseWindowsPowerShell

Import-Module AzureAD -UseWindowsPowerShell
Connect-AzureAD

$SearchString = ""
$upn = ""
$DisplayName = ""
$SurName = ""
$GivenName = ""

Get-AzureADUser -ObjectId $upn
Get-AzureADUser -SearchString $SearchString

Set-AzureADUser -ObjectId $ObjectId -DisplayName $DisplayName -Surname $SurName -GivenName $GivenName
