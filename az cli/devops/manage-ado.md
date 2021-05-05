# Azure DevOps CLI extension

Syntax for the Work Item Query Language (WIQL)
https://docs.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax?view=azure-devops

Add the azure devops extension with `az extension add --name azure-devops`.

Confirm the installation with either `az extension list` or `az extension show --name azure-devops`.

Sign in using `az login`.

Configure the defaults after signing in to simplify scripting by issuing `az devops configure --defaults organization=https://dev.azure.com/contoso project=ContosoWebApp`.´

To get help and to navigate the CLI extension, run this command `az devops -h`.

## Working with Boards

`az boards -h`
`az boards work-item -h`
`az boards work-item show -h`

`az boards work-item show --id <id>`

### Query examples

Query for work items using wiql. This is somewhat limited, I have not got it working when single quotes are in the where clause.
`az boards query --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [Microsoft.VSTS.Scheduling.FinishDate] FROM workitems"`
Query for work items using id. 
`az boards query --id 3511046e-c3ca-4d9b-b054-a9e22c4106cc`

### Update examples

Update a work item's iteration.
`az boards work-item update --id 7062 --iteration '<project>\FY20'`


