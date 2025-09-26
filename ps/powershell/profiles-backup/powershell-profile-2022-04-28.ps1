################################################################################
# Get the FQDN of the
################################################################################
function Get-VmFqdn {
    param(
        $ResourceGroupName,
        $VirtualMachineName
    )
    $ipName = (az vm list-ip-addresses -g $ResourceGroupName --name $VirtualMachineName --query "[0].virtualMachine.network.publicIpAddresses[0].name") -replace "`"", ""
    $vmId = (az vm list-ip-addresses -g $ResourceGroupName --name $VirtualMachineName --query "[0].virtualMachine.network.publicIpAddresses[0].name") -replace "`"", ""
    $fqdn = (az network public-ip show -g $ResourceGroupName -n $ipName --query "dnsSettings.fqdn") -replace "`"", ""
    $fqdn
}

################################################################################
# Request just-in-time access
# Inspiration taken from: 
# - https://www.improvescripting.com/how-to-create-custom-powershell-cmdlet-step-by-step/
# - https://wahlnetwork.com/2017/07/10/powershell-aliases/
################################################################################

#region help
<#
.SYNOPSIS
Requests Just-in-time access to a virtual machine in Azure.
.DESCRIPTION
Requests Just-in-time access to a virtual machine in Azure.
If the current session is not already logged in to Azure, it starts an interactive login process first. 

.PARAMETER ResourceGroupName
Name of the resource group containing the VM.

.PARAMETER VirtualMachineName
Name of the virtual machine

.EXAMPLE
Request-JitAccess -ResourceGroupName "myRg" -VirtualMachineName "myVm"

.EXAMPLE
Request-JitAccess -resource-group "myRg" -name "myVm"

.EXAMPLE
Request-JitAccess -g "myRg" -n "myVm"

.INPUTS
System.String

InputObject parameters are strings. 
.OUTPUTS
Outputs to console.

.NOTES
FunctionName : Request-JitAccess
Created by   : Peter Liljenroth
Date Coded   : 09/03/2021
More info    : https://github.com/peterlil/script-and-templates

#>
#endregion
Function Request-JitAccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Name of the resource group for the VM.")]
        [Alias('resource-group', 'g')]
        [string]$ResourceGroupName,

        [Parameter(Mandatory=$true, 
            HelpMessage="Name of the VM.")]
        [Alias('name', 'n')]
        [string]$VirtualMachineName
    )
    BEGIN {
        
    }

    PROCESS {
        
        # Check that the session is logged in
        $subscriptions = az account list --output table
        if($subscriptions.Length -lt 3) {
            Write-Verbose "Session is not logged in to Azure. Logging in."
            $subscriptions = az login --output table
            if($subscriptions.Length -lt 3) {
                Write-Error "Log in error or user has no subscription access. Terminating."
                return ""
            }
        }

        Write-Verbose "Session is logged in, looking for resource group."
        # Check that the resource group exists
        $groups = az group list --query "[?name=='$ResourceGroupName']" -o table
        if($groups.Length -eq 0 ) {
            Write-Error "The resource group $ResourceGroupName does not exist."
            return ""
        }
        
        Write-Verbose "Resource group $ResourceGroupName exists, looking for VM."
        # Check that the VM exists
        $vms = az vm list -g $ResourceGroupName --query "[?name=='$VirtualMachineName']" -o table
        if($vms.Length -eq 0) {
            Write-Error "The virtual machine $VirtualMachineName does not exist."
            return ""
        }
        Write-Verbose "Virtual machine  $VirtualMachineName exists, proceeding."

        $ip = (Invoke-WebRequest -Uri https://ifconfig.me/ip | Select-Object Content).Content
        Write-Verbose "Local ip: $ip"
        $vmInfo = (az vm show -g $ResourceGroupName -n $VirtualMachineName -o tsv --query "[id, location]")
        # Reg exp to find a GUID: (?<SubscriptionId>[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})
        $null = $vmInfo[0] -match "(?<SubscriptionId>[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})"
        Write-Verbose "Subscription ID: $($matches.SubscriptionId)"
        $requestName = New-Guid

        $EndPoint = "https://management.azure.com/subscriptions/$($matches.SubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/$($vmInfo[1])/jitNetworkAccessPolicies/default/initiate?api-version=2015-06-01-preview"
        $Body = "{""requests"":[{""content"":{""virtualMachines"":[{""id"":""$($vmInfo[0])"",""ports"":[{""number"":3389,""duration"":""PT10H"",""allowedSourceAddressPrefix"":""$ip""}]}]},""httpMethod"":""POST"",""name"":""$requestName"",""requestHeaderDetails"":{""commandName"":""Microsoft_Azure_Compute.""},""url"":""$EndPoint""}]}" | ConvertTo-Json
        $Url="https://management.azure.com/batch?api-version=2020-06-01"

        Write-Verbose "Endpoint: $EndPoint"
        Write-Verbose "Body: $Body"
        Write-Verbose "Uri: $Url"
        
        # Send the jit-request
        $response = az rest --method post --uri "$Url" --body "$Body" --query "responses[0].[httpStatusCode,content.virtualMachines[0].ports[0].status]" -o table
        
        if($response[2] -eq "202") {
            Write-Verbose "Request status: $($response[3])"
        }

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
            Write-Host "Jit request is granted."
            $ipName = (az vm list-ip-addresses -g $ResourceGroupName --name $VirtualMachineName --query "[0].virtualMachine.network.publicIpAddresses[0].name") -replace "`"", ""
            $fqdn = (az network public-ip show -g $ResourceGroupName -n $ipName --query "dnsSettings.fqdn") -replace "`"", ""
        
            Write-Host "Execute this command to start the remote session: mstsc.exe /v:$fqdn"
        }
    }

    END {

    }
}

Function Get-VmPassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Name of the VM.")]
        [Alias('n')]
        [string]$name
    )
    
    if( $env:DefaultSubscriptionId -eq $null ) {
        $env:DefaultSubscriptionId = az account list --query "[?isDefault].id" | ConvertFrom-Json
    }

    $value = az keyvault secret show -n $name `
        --subscription $env:DefaultSubscriptionId `
        --vault-name devboxes-vm-encrypt `
        --query "value" `
        -o tsv

    Set-Clipboard -Value $value

    Write-Host "VM password added to clipboard"

}

Function Get-UserPassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Username")]
        [Alias('n')]
        [string]$name
    )
    
    if( $env:DefaultSubscriptionId -eq $null ) {
        $env:DefaultSubscriptionId = az account list --query "[?isDefault].id" | ConvertFrom-Json
    }

    $value = az keyvault secret show -n $name `
        --subscription $env:DefaultSubscriptionId `
        --vault-name devboxes-vm-encrypt `
        --query "value" `
        -o tsv

    Set-Clipboard -Value $value

    Write-Host "User password added to clipboard"

}

Function Disable-Gtx {
    $GtxId = (Get-PnpDevice -FriendlyName "*GTX*").InstanceId
    echo "  DeviceID = $GtxId"

    echo "Disabling GTX."
    Disable-PnpDevice -Confirm:$false -InstanceId $GtxId

    # Wait for user to click detach button
    Read-Host -Prompt "Safe to detach. Try detach button now. Hit enter to re-enable GTX." 

    echo "Enabling GTX."
    Enable-PnpDevice -Confirm:$false -InstanceId $GtxId
}

Function Enable-Gtx {
    $GtxId = (Get-PnpDevice -FriendlyName "*GTX*").InstanceId
    echo "  DeviceID = $GtxId"

    echo "Enabling GTX."
    Enable-PnpDevice -Confirm:$false -InstanceId $GtxId
}

Function Start-VM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Name of the VM.")]
        [Alias('n')]
        [string]$name
    )
    $rgNameUC = (az vm list --query "[?name=='$name'].resourceGroup" -o tsv)
    
    $rgName = (az group show -n $rgNameUC --query "name" -o tsv)

    az vm start -g $rgName -n $name

    Request-JitAccess -g $rgName -n $name

    $ipName = (az vm list-ip-addresses -g $rgName --name $name --query "[0].virtualMachine.network.publicIpAddresses[0].name") -replace "`"", ""
    $fqdn = (az network public-ip show -g $rgName -n $ipName --query "dnsSettings.fqdn") -replace "`"", ""

    Get-VmPassword -n $name

    mstsc.exe /v:$fqdn
}

Function ConnectTo-VM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Name of the VM.")]
        [Alias('n')]
        [string]$name,
        [Parameter(Mandatory=$false, 
            HelpMessage="Do a Jit request.")]
        [Alias('jr')]
        [Switch]$JitRequest
    )
    $rgNameUC = (az vm list --query "[?name=='$name'].resourceGroup" -o tsv)
    
    $rgName = (az group show -n $rgNameUC --query "name" -o tsv)

    if($JitRequest -eq $true) {
        Request-JitAccess -g $rgName -n $name
    }

    $ipName = (az vm list-ip-addresses -g $rgName --name $name --query "[0].virtualMachine.network.publicIpAddresses[0].name") -replace "`"", ""
    $fqdn = (az network public-ip show -g $rgName -n $ipName --query "dnsSettings.fqdn") -replace "`"", ""

    Get-VmPassword -n $name

    mstsc.exe /v:$fqdn
}

Function Stop-VM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
            HelpMessage="Name of the VM.")]
        [Alias('n')]
        [string]$name
    )
    $rgNameUC = (az vm list --query "[?name=='$name'].resourceGroup" -o tsv)
    
    $rgName = (az group show -n $rgNameUC --query "name" -o tsv)

    az vm deallocate -g $rgName -n $name

}

Function DisableEnable-GPU {
    $GtxId = (Get-PnpDevice -FriendlyName "*GTX*").InstanceId
    echo "  DeviceID = $GtxId"

    echo "Disabling GTX."
    Disable-PnpDevice -Confirm:$false -InstanceId $GtxId

    # Wait for user to click detach button
    Read-Host -Prompt "Safe to detach. Try detach button now. Hit enter to re-enable GTX." 

    echo "Enabling GTX."
    Enable-PnpDevice -Confirm:$false -InstanceId $GtxId
}

Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme Fish