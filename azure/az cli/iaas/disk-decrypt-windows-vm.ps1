param(
    [string] $rgName,
    [string] $vmName
)

# Start the VM if it's deallocated
$running = az vm list -d --query "[?powerState=='VM running' && name=='$($vmName)']" | ConvertFrom-Json
if(!$running) {
    Write-Information "VM is stopped. Starting to perform encryption."
    az vm start -n $vmName -g $rgName
    while (!$running) {
        $running = az vm list -d --query "[?powerState=='VM running' && name=='$($vmName)']" | ConvertFrom-Json
        Start-Sleep -Seconds 5
    }
}

# Decrypt
az vm encryption disable -n $vmName -g $rgName --volume-type "all"

#Query status
az vm encryption show -n $vmName -g $rgName

Write-Information "Done decrypting."