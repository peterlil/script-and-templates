# App roles

## Create the roles

# create user-role for the app users for each appreg
displayNames=('appv2' 'api1v2' 'api2v2')
roleName='appv2-user'
role=$(jq -n '[
        {"allowedMemberTypes": [
            "User"
        ],
        "description": "'$appDisplayName' users can use the application/api",
        "displayName": "'$appDisplayName' user",
        "isEnabled": "true",
        "value": "'$roleName'"}]')

for appName in ${displayNames[@]}; do
	echo "Creating role $appName"
	
    oid=$(az ad app list --query "[?displayName=='$appName'].id" -o tsv)
	
    az ad app update --id $oid --app-roles "$role"
 
done
		
#oid=$(az ad app list --query "[?displayName=='$appDisplayName'].id" -o tsv)
#az ad app update --id $oid --app-roles "$roles"
#az ad app list --query "[?not_null(appRoles)].appRoles"
```

## Create the Azure AD group

```bash
az ad group create --display-name 'app-users' \
                   --mail-nickname 'app-users'
```

## Add the user to the group

```bash
userName=appuser@mngenv319828.onmicrosoft.com
az ad group member add --group 'app-users' \
                       --member-id $(az ad user show --id $userName --query "id" -o tsv)
```

## Assign roles to groups

```shell
#oid=$(az ad user show --id "appuser@mngenv319828.onmicrosoft.com" --query "id" --output tsv)

groupName=app-users
roleName=appv2-user

goid=$(az ad group show --group "$groupName" --query "id" --output tsv)

displayNames=('appv2' 'api1v2' 'api2v2')
for appName in ${displayNames[@]}; do
    appid=$(az ad app list --query "[?displayName=='$appName'].appId" -o tsv)
    roid=$(az ad app show --id $appid --query "appRoles[?value=='$roleName'].id" -o tsv)
    spid=$(az ad sp list --all --query "[?appId=='$appid'].id" -o tsv)
    az rest -m POST -u https://graph.microsoft.com/v1.0/groups/$goid/appRoleAssignments -b "{\"principalId\": \"$goid\", \"resourceId\": \"$spid\",\"appRoleId\": \"$roid\"}"
done


```