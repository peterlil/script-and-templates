@description('Assignee')
param principalId string

@description('Scope on to which to assign the role')
param scope object

@description('Built-in role to assign')
@allowed([
  'Owner'
  'Contributor'
  'Reader'
])
param builtInRoleType string

@description('A new GUID used to identify the role assignment')
param roleNameGuid string = newGuid()

var owner = '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var contributor = '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var reader = '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'

var roleDefId = builtInRoleType == 'Owner' ? owner : (builtInRoleType == 'Contributor' ? contributor : reader)

resource ra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleNameGuid
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefId
  }
  //scope: scope
}

output NewRoleNameGuid string = roleNameGuid
