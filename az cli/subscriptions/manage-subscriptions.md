# Manage tenants and subscriptions

List all tenants \
`az account tenant list`

List all subscriptions \
`az account list`

List only the names of the subscriptions \
`az account list --query "[].name"`

List only specific subscriptions by name \
`az account list --query "[?name=='Personal Azure Training' || name=='Personal Azure Training']"`

List only the current subscription \
`az account list --query "[?isDefault]"`