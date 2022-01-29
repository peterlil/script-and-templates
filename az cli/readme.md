# Az CLI
## Install in WSL (Ubuntu)
Docs [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-1-install-with-one-command).

`curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

## Install in Powershell (Windows)

Docs [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-powershell).

`$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi`
