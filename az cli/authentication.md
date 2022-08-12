# Authentication

## Check who is logged in

```shell
az account show --query "user.name" -o tsv

user=$(az account show --query "user.name" -o tsv)
```

