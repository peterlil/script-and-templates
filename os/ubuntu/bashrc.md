# Great .bashrc stuff

## Some aliases
```bash
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls -G1'

alias kgsapi='kubectl config use-context gcp-sapi'
alias kgshgw='kubectl config use-context gcp-shgw'
alias k='kubectl'
```

## Functions for Azure VM operations

```bash
request_jit_access() {
    rgname=${rgname:-devboxes}
    vmname=${vmname:-swevm}

    while [ $# -gt 0 ]; do
        if [[ $1 == *"--"* ]]; then
                param="${1/--/}"
                declare $param="$2"
                # echo $1 $2 // Optional to see the parameter:value result
        fi
        shift
    done

    subscriptions=$(az account list)
    if [ $(echo $subscriptions | jq length) -eq 0 ]
    then 
        echo "Session is not logged in to Azure. Logging in."
        subscriptions=$(az login --output table)
        if [ $subscriptions.Length -lt 3 ]
        then
            echo "Log in error or user has no subscription access. Terminating."
            return
        fi
    fi

    echo "Session is logged in, looking for resource group."
    # Check that the resource group exists
    groups=$(az group list --query "[?name=='$rgname']")

    if [ $(echo $groups | jq length) -eq 0 ] 
    then
        echo "The resource group $rgname does not exist."
        return
    fi
    echo "Resource group $rgname exists, looking for VM."
        
    # Check that the VM exists
    $vms=$(az vm list -g $rgname --query "[?name=='$vmname']")
    if [ $(echo $groups | jq length) -eq 0 ] 
    then
        echo "The virtual machine $vmname does not exist."
        return
    fi
    echo "Virtual machine  $vmname exists, proceeding."

    ip=$(curl https://ifconfig.me/ip)
    echo "Local ip: $ip"
    vmInfo=$(az vm show -g $rgname -n $vmname --query "[id, location]")
    vmResourceId=$(echo $vmInfo | jq '.[0]' | tr -d \")
    vmLocation=$(echo $vmInfo | jq '.[1]' | tr -d \")
    # Reg exp to find a GUID: (?<SubscriptionId>[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})
    match=$(echo $vmResourceId | grep -oP "(?<SubscriptionId>[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})")
    echo "Subscription ID: $match"
    requestName=$(uuidgen)

    EndPoint="https://management.azure.com/subscriptions/$match/resourceGroups/$rgname/providers/Microsoft.Security/locations/$vmLocation/jitNetworkAccessPolicies/default/initiate?api-version=2015-06-01-preview"
    Body=$( jq -n \
            --arg vmResourceId "$vmResourceId" \
            --arg ip "$ip" \
            --arg requestName "$requestName" \
            --arg EndPoint "$EndPoint" \
            '{
                "requests": 
                [
                    {
                        "content": 
                        {
                            "virtualMachines": 
                            [
                                {
                                    "id": $vmResourceId, 
                                    "ports": 
                                    [
                                        {
                                            "number": 3389, 
                                            "duration": "PT10H", 
                                            "allowedSourceAddressPrefix":$ip
                                        }
                                    ]
                                }
                            ]
                        },
                        "httpMethod": "POST", 
                        "name": $requestName,
                        "requestHeaderDetails": 
                        {
                            "commandName": "Microsoft_Azure_Compute."
                        },
                        "url": $EndPoint
                    }
                ]
            }'
        )
    Url="https://management.azure.com/batch?api-version=2020-06-01"

    echo "Endpoint: $EndPoint"
    echo "Body: $Body"
    echo "Uri: $Url"

    # Send the jit-request
    response=$(az rest --method post --uri "$Url" --body "$Body" --query "responses[0].[httpStatusCode,content.virtualMachines[0].ports[0].status]")

    # Construct the request to check status.While a request is in 'Initiating' status, the request is still being applied.
    requestName=$(uuidgen)
    Url2="https://management.azure.com/subscriptions/$match/resourceGroups/$rgname/providers/Microsoft.Security/locations/$vmLocation/jitNetworkAccessPolicies/default?api-version=2015-06-01-preview"
    Body2=$( jq -n \
            --arg requestName "$requestName" \
            --arg Url2 "$Url2" \
            '{
                "requests": [
                    {
                        "httpMethod": "GET",
                        "name": $requestName,
                        "requestHeaderDetails":
                        {
                            "commandName": "Microsoft_Azure_Compute."
                        },
                        "url": $Url2
                    }
                ]
            }')
    response=$(az rest --method post --uri "$Url" --body "$Body2")
    
    while($response.Length -gt 0) {
        
        Start-Sleep -Seconds 2
        $response = az rest --method post --uri "$Url" --body "$Body2" --query "responses[].content.properties.requests[?virtualMachines[?ports[?status=='Initiating']]].startTimeUtc" | ConvertFrom-Json
    }

           
}
```
