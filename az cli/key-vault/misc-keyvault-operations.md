# Key Vault Operations

## Common Key Vault Operations
List the Key Vaults with `az keyvault list -o table`.

List secrets in a Key Vault using `az keyvault secret list --vault-name <name> -o table`.

Update a secret with `az keyvault secret set --vault-name <vault-name> --name <name> --value <value>`.

## Misc
```ps1
az keyvault secret list --subscription <subscription> --vault-name <vault-name>

$value = az keyvault secret show -n swevm `
    --subscription <subscription> `
    --vault-name <vault-name> `
    --query "value" `
    -o tsv

Set-Clipboard -Value $value
```
