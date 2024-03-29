# Basic VM Operations

Check if one VM is running
```bash
vmName=<vmname>
az vm list -d --query "[?powerState=='VM running' && name=='${vmName}'].{name:name,powerState:powerState}" -o table
```

Get the powerstate of all VMs in the subscription
```bash
az vm list -d --query "[*].{name:name,powerState:powerState}" -o table
```

Get all the running VMS in the subscription
```bash
az vm list -d --query "[?powerState=='VM running'].{name:name,powerState:powerState}" -o table
```


```powershell
# List the names of all VMs in a subscription
az vm list --query "[].name | {Names: join(', ', @)}"
az vm list --query "[*].[name,resourceGroup]"
az vm list --query "[*].[name,resourceGroup]" -o table

# List details of a VM
az vm show -n <name> -g <rg>

# List the names of the VMs in a resource group
az vm list -g Test --query "[].name | {Names: join(', ', @)}"

# List the os disk names for the vms in a resource group
az vm list -g Test --query "[*].storageProfile[].osDisk[].name"

# Check if a VM is running
az vm list -d --query "[?powerState=='VM running' && name=='<vmname>']" | ConvertFrom-Json

# Detach an os disk - NO CAN DO! NEED TO DELETE THE VM FIRST!
az vm disk detach --name "peterlil57_OsDisk_1_4b40e0412cb84d35b42e4fa77008598f" --resource-group Test --vm-name peterlil57

# Delete a VM
az vm delete --name peterlil57 --resource-group Test --yes

# attach a disk to a vm
az vm disk attach --disk peterlil57_OsDisk_1_4b40e0412cb84d35b42e4fa77008598f --resource-group Test --vm-name peterlil56

# start a vm
az vm start -n <vmname> -g <rg>

# List the NICs on the VM
az vm nic list -g <rg> --vm-name <vm>

# Show details of a NIC on a VM
az vm nic show --nic <nic> -g <rg> --vm-name <vm>

# List ip addresses on a VM
az vm list-ip-addresses -g <rg> --name <vm>

# List the public ip address for a VM.
az vm list-ip-addresses -g <rg> --name <vm> --query "[*].virtualMachine.network.publicIpAddresses"

################################################################################
# Request just-in-time access
################################################################################
function Request-JitAccess {
    param(
        $ResourceGroupName,
        $VirtualMachineName
    )

    $ip = (curl -s https://ifconfig.me/ip)
    $vmInfo = (az vm show -g $ResourceGroupName -n $VirtualMachineName -o tsv --query "[id, location]")
    # Reg exp to find a GUID: (?<SubscriptionId>[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})
    $null = $vmInfo[0] -match "(?<SubscriptionId>[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})"
    $requestName = New-Guid

    $EndPoint = "https://management.azure.com/subscriptions/$($matches.SubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/$($vmInfo[1])/jitNetworkAccessPolicies/default/initiate?api-version=2015-06-01-preview"
    $Body = "{""requests"":[{""content"":{""virtualMachines"":[{""id"":""$($vmInfo[0])"",""ports"":[{""number"":3389,""duration"":""PT10H"",""allowedSourceAddressPrefix"":""$ip""}]}]},""httpMethod"":""POST"",""name"":""$requestName"",""requestHeaderDetails"":{""commandName"":""Microsoft_Azure_Compute.""},""url"":""$EndPoint""}]}" | ConvertTo-Json
    $Url="https://management.azure.com/batch?api-version=2020-06-01"

    # Send the jit-request #
    $response = az rest --method post --uri "$Url" --body "$Body" # --verbose 

    # Construct the request to check status.While a request is in 'Initiating' status, the request is still being applied.
    $requestName = New-Guid
    $Body2 = "{""requests"":[{""httpMethod"":""GET"",""name"":""$requestName"",""requestHeaderDetails"":{""commandName"":""Microsoft_Azure_Compute.""},""url"":""https://management.azure.com/subscriptions/$($matches.SubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/$($vmInfo[1])/jitNetworkAccessPolicies/default?api-version=2015-06-01-preview""}]}" | ConvertTo-Json
    $response = az rest --method post --uri "$Url" --body "$Body2" --query "responses[].content.properties.requests[?virtualMachines[?ports[?status=='Initiating']]].startTimeUtc" | ConvertFrom-Json
    while($response.Length -gt 0) {
        Start-Sleep -Seconds 2
        $response = az rest --method post --uri "$Url" --body "$Body2" --query "responses[].content.properties.requests[?virtualMachines[?ports[?status=='Initiating']]].startTimeUtc" | ConvertFrom-Json
    }

    $response = az rest --method post --uri "$Url" --body "$Body2" --query "responses[].content.properties.requests[?virtualMachines[?ports[?status=='Initiated']]].startTimeUtc" | ConvertFrom-Json
    if( $response.Length -eq 0) {
        Write-Error "Something went wrong"
    }
    else {
        Write-Information "Request is granted."
    }
}

################################################################################
# Get the DNS name for a VM that has only one public ip
################################################################################
function Get-VmFqdn {
    param(
        $ResourceGroupName,
        $VirtualMachineName
    )
    $ipName = (az vm list-ip-addresses -g $ResourceGroupName --name $VirtualMachineName --query "[0].virtualMachine.network.publicIpAddresses[0].name") -replace "`"", ""
    $fqdn = (az network public-ip show -g $ResourceGroupName -n $ipName --query "dnsSettings.fqdn") -replace "`"", ""
    $fqdn
}

################################################################################
# start rd session
mstsc.exe /v: $fqdn
```