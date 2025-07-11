# Certificates

## Create a certificate using acme.sh

```bash
fqdn=<fqdn>
# Create cert
acme.sh --issue --dns dns_azure -d $fqdn
# Create pfx
password=<password>
acme.sh --toPkcs -d $fqdn --password $password
```

## Create a certificate using Posh-ACME

```powershell
$appSecret = ConvertTo-SecureString 'Irm7Q~hKUuLTYnOfQyC1hCkwkQ4ejvwS5TK4Q' -AsPlainText -Force
$appCred = New-Object System.Management.Automation.PSCredential ('179c60cf-8b7c-4c63-986a-b32076b07481', $appSecret)

$pfxPassword = ConvertTo-SecureString -String 'scAm1()3@WCz5sSKVI82' -Force -AsPlainText
$pArgs = @{
    AZSubscriptionId = '40399d07-37b5-4eef-be3e-e5e68dd0edef'
    AZTenantId = 'dadbab4a-34fa-4b93-bd9d-ab85899c6a9f'
    AZAppCred = $appCred
}
New-PACertificate -Domain app.peterlabs.net -Plugin Azure -PluginArgs $pArgs -PfxPassSecure $pfxPassword -UseModernPfxEncryption -AcceptTOS -Verbose
```