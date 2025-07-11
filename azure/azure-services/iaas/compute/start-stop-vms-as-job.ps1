Login-AzureRmAccount

Get-AzureRmVm | Start-AzureRmVm -AsJob


Get-AzureRmVm | Stop-AzureRmVm -AsJob -Force


Get-Job 

Get-Job -Id 8 | Receive-Job 