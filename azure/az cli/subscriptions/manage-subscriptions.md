# Manage tenants and subscriptions

List all tenants (requires the extension _Accounts_)\
`az account tenant list -o table`

List all subscriptions \
`az account list`

List only the names of the subscriptions \
`az account list --query "[].name"`

List only specific subscriptions by name \
`az account list --query "[?name=='Personal Azure Training' || name=='Personal Azure Training']"`

List the default subscription \
`az account list --query "[?isDefault]"`

## Show the current subscription in different ways

```shell
# Only show name
az account show --query "name" -o tsv
# Only show id
az account show --query "id" -o tsv
# Show name,id
az account show --query "[name, id]" -o tsv | paste - -
```