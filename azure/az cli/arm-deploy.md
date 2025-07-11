# Deploy ARM Template

```powershell
az deployment group create -g <resource-group> --name <deployment-name> --template-file <template-file-name> --parameters <parameter-file-name> --mode incremental --verbose

az deployment group create -g <resource-group> --name <deployment-name> --template-file <template-file-name> --parameters <parameter-file-name> --parameters <key>=<value> --mode incremental --verbose

```
