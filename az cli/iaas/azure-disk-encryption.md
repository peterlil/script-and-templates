# Azure Disk Encryption 

## Windows VMs

Use this command to check whether Azure Disk Encryption is enabled for the VM or not: `az vm encryption show -n <vmname> -g <rgname>`.

If disk encryption is not enabled, use the script below to enable it.
```powershell
function Encrypt-VM
{
    param(
        [string] $kekName,
        [string] $keyVaultName,
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

    if($kekName)
    {
        # Create a key encryption key if it does not exist
        $key = az keyvault key show --vault-name $keyVaultName --name $kekName
        if(!$key)
        {
            # Generate the key encryption key and store it in Key Vault
            az keyvault key create --name $kekName --vault-name $keyVaultName --kty RSA
        }

        Write-Information "Encrypting with KEK"
        az vm encryption enable -g $rgName -n $vmName --disk-encryption-keyvault $keyVaultName `
            --key-encryption-key $kekName --key-encryption-keyvault $keyVaultName `
            --volume-type All

    }
    else
    {
        Write-Information "Encrypting"
        az vm encryption enable -g $rgName -n $vmName --disk-encryption-keyvault `
            $keyVaultName --volume-type All
    }

    az vm encryption show -n $vmName -g $rgName

    Write-Information "Done encrypting."
}
```

If you want to disable disk encryption on a VM, use the script below to do that.
```powershell
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
```

