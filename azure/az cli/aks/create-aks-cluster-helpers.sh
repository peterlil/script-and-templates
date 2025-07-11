# Get started with SQL Server Big Data Clusters - https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-get-started?view=sql-server-ver15
# Install SQL Server 2019 big data tools - https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-big-data-tools?view=sql-server-ver15
# Quickstart: Deploy an Azure Kubernetes Service cluster using the Azure CLI - https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
# az aks - https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create
# How to Install Python 3.6.1 in Ubuntu 16.04 LTS - http://ubuntuhandbook.org/index.php/2017/07/install-python-3-6-1-in-ubuntu-16-04-lts/
# Workshop: SQL Server Big Data Clusters - Architecture - https://github.com/microsoft/sqlworkshops/tree/master/sqlserver2019bigdataclusters
#                                                         https://github.com/Microsoft/sqlworkshops/blob/master/sqlserver2019bigdataclusters/SQL2019BDC/02%20-%20SQL%20Server%20BDC%20Components.md
# How to deploy SQL Server 2019 Big Data Clusters - https://cloudblogs.microsoft.com/sqlserver/2019/11/19/how-to-deploy-sql-server-2019-big-data-clusters/

# Kubernetes Service Principal: https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal

#To use kubectl with a previously deployed cluster on Azure Kubernetes Service (AKS), you must set the cluster context with the following Azure CLI command:
# az aks get-credentials --name <aks_cluster_name> --resource-group <azure_resource_group_name>

#
#aks
#northeurope
#Standard_DS3_v2
#3
#sqlbigdata
#pladmin


PS C:\l\temp\bdc-deploy-ps> az ad sp create-for-rbac --skip-assignment --name AKS_sqlbigdata2
Changing "AKS_sqlbigdata2" to a valid URI of "http://AKS_sqlbigdata2", which is the required format used for service principal names
{
  "appId": "",
  "displayName": "AKS_sqlbigdata2",
  "name": "http://AKS_sqlbigdata2",
  "password": "",
  "tenant": ""
}
PS C:\l\temp\bdc-deploy-ps> az aks create --name sqlbigdata2 --resource-group bdc2 --ssh-key-value c:\l\home\.ssh\id_rsa.pub --node-vm-size Standard_DS3_v2 --node-count 3 --service-principal  --client-secret 
 - Running ..

PS C:\l\temp\bdc-deploy-ps> az aks create --name sqlbigdata2 --resource-group bdc2 --ssh-key-value c:\l\home\.ssh\id_rsa.pub --node-vm-size Standard_DS3_v2 --node-count 3 --service-principal  --client-secret 
{
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "count": 3,
      "maxPods": 110,
      "name": "nodepool1",
      "osDiskSizeGb": 100,
      "osType": "Linux",
      "storageProfile": "ManagedDisks",
      "vmSize": "Standard_DS3_v2",
      "vnetSubnetId": null
    }
  ],
  "dnsPrefix": "sqlbigdata-bdc2-05c25b",
  "enableRbac": true,
  "fqdn": "sqlbigdata-bdc2-05c25b-8a3f4892.hcp.northeurope.azmk8s.io",
  "id": "/subscriptions//resourcegroups/bdc2/providers/Microsoft.ContainerService/managedClusters/sqlbigdata2",
  "kubernetesVersion": "1.14.8",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9DxeMjSL0W5KGVl7FVoepwciNuk85Lu9ZI72h1+cvhSpNN9c+bJ7GLIfc4UKuVjA/oVI1aAZaS3ZRxGbTg1Ow4WGGjtwy4eDZiFbp/5up+jJzrirVw7JLCs84PWhGonEzQjhjgH+ps79bgTTJkfwVtk7z+N5YkHtC+TtL+Ed7Kq6oVUKA5xSgDd8uUBXzuSpv6JT3ZZ6xHUpalgdCTHdPX0AXDF6GuOe3Nwla7t8lBi21ycsImm7Wwh7nlxbxOvKslRXixaSuRBJffBtIET0TT2G5RsCNsyv3eRCkua9qgHjLgOMefFArL5BaBTgQP8hQLZSVfzTNHX3JQd9644/H"
        }
      ]
    }
  },
  "location": "northeurope",
  "name": "sqlbigdata2",
  "networkProfile": {
    "dnsServiceIp": "10.0.0.10",
    "dockerBridgeCidr": "172.17.0.1/16",
    "networkPlugin": "kubenet",
    "networkPolicy": null,
    "podCidr": "10.244.0.0/16",
    "serviceCidr": "10.0.0.0/16"
  },
  "nodeResourceGroup": "MC_bdc2_sqlbigdata2_northeurope",
  "provisioningState": "Succeeded",
  "resourceGroup": "bdc2",
  "servicePrincipalProfile": {
    "clientId": "",
    "secret": null
  },
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters"
}

PS C:\l\temp\bdc-deploy-ps> az aks get-credentials --overwrite-existing --name sqlbigdata2 --resource-group bdc2 --admin
Merged "sqlbigdata2-admin" as current context in C:\Users\peterlil\.kube\config

PS C:\l\temp\bdc-deploy-ps> azdata bdc config init --source aks-dev-test --target custom --force
"Created configuration profile in custom"

PS C:\l\temp\bdc-deploy-ps> azdata bdc config replace -c custom/bdc.json -j "metadata.name=sqlbigdata2"

PS C:\l\temp\bdc-deploy-ps> azdata bdc create -c custom --accept-eula yes
The privacy statement can be viewed at:
https://go.microsoft.com/fwlink/?LinkId=853010

The license terms for SQL Server Big Data Cluster can be viewed at:
Enterprise: https://go.microsoft.com/fwlink/?linkid=2104292
Standard: https://go.microsoft.com/fwlink/?linkid=2104294
Developer: https://go.microsoft.com/fwlink/?linkid=2104079


Cluster deployment documentation can be viewed at:
https://aka.ms/bdc-deploy

Please provide a value for AZDATA_USERNAME:pladmin
Please provide a value for AZDATA_PASSWORD:

NOTE: Cluster creation can take a significant amount of time depending on
configuration, network speed, and the number of nodes in the cluster.

Starting cluster deployment.
Waiting for cluster controller to start.
Waiting for cluster controller to start.
Waiting for cluster controller to start.
Waiting for cluster controller to start.
Waiting for cluster controller to start.
Waiting for cluster controller to start.
Cluster controller endpoint is available at 40.112.92.246:30080.
Cluster control plane is ready.
Data pool is ready.
Storage pool is ready.
Compute pool is ready.
Master pool is ready.
Cluster deployed successfully.

PS C:\l\temp\bdc-deploy-ps> azdata login -n sqlbigdata2
Username: pladmin
Password:
Logged in successfully to `https://40.112.92.246:30080` in namespace `sqlbigdata2`. Setting active context to `sqlbigdata2`.

PS C:\l\temp\bdc-deploy-ps> azdata bdc endpoint list -o table
Description                                             Endpoint                                                  Name               Protocol
------------------------------------------------------  --------------------------------------------------------  -----------------  ----------
Gateway to access HDFS files, Spark                     https://52.169.13.251:30443                               gateway            https
Spark Jobs Management and Monitoring Dashboard          https://52.169.13.251:30443/gateway/default/sparkhistory  spark-history      https
Spark Diagnostics and Monitoring Dashboard              https://52.169.13.251:30443/gateway/default/yarn          yarn-ui            https
Application Proxy                                       https://52.169.236.27:30778                               app-proxy          https
Management Proxy                                        https://52.178.188.165:30777                              mgmtproxy          https
Log Search Dashboard                                    https://52.178.188.165:30777/kibana                       logsui             https
Metrics Dashboard                                       https://52.178.188.165:30777/grafana                      metricsui          https
Cluster Management Service                              https://40.112.92.246:30080                               controller         https
SQL Server Master Instance Front-End                    13.79.21.80,31433                                         sql-server-master  tds
HDFS File System Proxy                                  https://52.169.13.251:30443/gateway/default/webhdfs/v1    webhdfs            https
Proxy for running Spark statements, jobs, applications  https://52.169.13.251:30443/gateway/default/livy/v1       livy               https




Workshop
# Execute this in a Command Prompt (not in PowerShell)
.\bootstrap-sample-db.cmd sqlbigdata 52.156.253.96 MinaStektaSt0r@Data 52.156.255.125 MinaStektaSt0r@Data