Login-AzureRmAccount;

$Location = "West Europe";

Get-AzureRmVMSize -Location $Location | Format-Table Name

