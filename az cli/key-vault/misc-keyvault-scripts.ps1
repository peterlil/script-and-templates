az keyvault secret list --subscription <subscription> --vault-name devboxes-vm-encrypt

$value = az keyvault secret show -n swevm `
    --subscription <subscription> `
    --vault-name devboxes-vm-encrypt `
    --query "value" `
    -o tsv

Set-Clipboard -Value $value

