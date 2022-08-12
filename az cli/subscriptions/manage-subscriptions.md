# Manage tenants and subscriptions

List all tenants (requires the extension _Accounts_)\
`az account tenant list -o table`

List all subscriptions \
`az account list`

List only the names of the subscriptions \
`az account list --query "[].name"`

List only specific subscriptions by name \
`az account list --query "[?name=='Personal Azure Training' || name=='Personal Azure Training']"`

List only the current subscription \
`az account list --query "[?isDefault]"`

## Get current subscription name/id

```shell
az account show --query "name" -o tsv
az account show --query "id" -o tsv
```