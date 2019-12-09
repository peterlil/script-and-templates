# Get started with SQL Server Big Data Clusters - https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-get-started?view=sql-server-ver15
# Install SQL Server 2019 big data tools - https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-big-data-tools?view=sql-server-ver15
# Quickstart: Deploy an Azure Kubernetes Service cluster using the Azure CLI - https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
# az aks - https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create
# How to Install Python 3.6.1 in Ubuntu 16.04 LTS - http://ubuntuhandbook.org/index.php/2017/07/install-python-3-6-1-in-ubuntu-16-04-lts/
# Workshop: SQL Server Big Data Clusters - Architecture - https://github.com/microsoft/sqlworkshops/tree/master/sqlserver2019bigdataclusters
#                                                         https://github.com/Microsoft/sqlworkshops/blob/master/sqlserver2019bigdataclusters/SQL2019BDC/02%20-%20SQL%20Server%20BDC%20Components.md
# How to deploy SQL Server 2019 Big Data Clusters - https://cloudblogs.microsoft.com/sqlserver/2019/11/19/how-to-deploy-sql-server-2019-big-data-clusters/



#05c25b78-003c-49ef-8f02-b24ca4aca086
#aks
#northeurope
#Standard_DS3_v2
#3
#sqlbigdata
#pladmin



az aks create --resource-group aks --name sqlbigdata --node-count 3 --enable-addons monitoring --generate-ssh-keys --admin-username pladmin --location northeurope --node-vm-size Standard_DS3_v2 --ssh-key-value ~/azure-vms-ssh-key.pub

az aks create --resource-group aks --name sqlbigdata --node-count 3 --enable-addons monitoring --generate-ssh-keys --admin-username pladmin --location northeurope --node-vm-size Standard_DS3_v2 --generate-ssh-keys