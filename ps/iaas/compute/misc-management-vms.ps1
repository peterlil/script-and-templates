#
# Login to Azure
#
az login
# or use 'az login --use-device-code'

#
# Check power state for each VM
#
az vm list -d -o table

#
# Check the power state for a particular vm.
#
az vm list -d -o table --query "[?name=='pljava']"

#
# Get a list of the running vms.
#
az vm list -d -o table --query "[?powerState=='VM running']"




# Embryo's
$vmlist = az vm list | ConvertFrom-Json
$vmlist | ft name, provisioningState
az vm list --help


