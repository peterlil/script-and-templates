# References
# Monitor and troubleshoot - https://docs.microsoft.com/en-us/sql/big-data-cluster/cluster-troubleshooting-commands?view=sql-server-ver15


# Manage AKS
kubectl get pods --all-namespaces
kubectl get pods --namespace sqlbigdata2
kubectl describe pod  master-0 -n sqlbigdata2
# Get pod logs
kubectl logs master-0 --all-containers=true -n sqlbigdata2 > master-0-pod-logs.txt
# Get status of services
# Service	                Description
#   master-svc-external	    Provides access to the master instance.
#                           (EXTERNAL-IP,31433 and the SA user)
#   controller-svc-external	Supports tools and clients that manage the cluster.
#   gateway-svc-external	Provides access to the HDFS/Spark gateway.
#                           (EXTERNAL-IP and the root user)
#   appproxy-svc-external	Support application deployment scenarios.

kubectl get svc -n sqlbigdata2


# Manage BDC
### Login ###
# This one works in PowerShell
azdata login --namespace sqlbigdata2 --username <username>

## Det verkar som om man måste ge endpoint i bash
azdata login --endpoint <endpoint> --username <username>

# Check the status of the bdc
azdata bdc endpoint list -o table

# View specific resource status: master, control, compute-0, storage-0, gateway
azdata bdc status show --all --resource storage-0

# To see the status of all components that are running a specific service you must use the corresponding command group (sql, hdfs, spark)
azdata bdc sql status show --all
azdata bdc hdfs status show --all
azdata bdc spark status show --all


azdata bdc control --help