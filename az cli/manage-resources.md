# Manage resources

## List resources

### List resources in a resource group

```Powershell
az resource list -g devboxes --query [*].[name,type] -o table
```
