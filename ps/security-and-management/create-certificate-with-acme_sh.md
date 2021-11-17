# Create a certificate using acme.sh

The first thing you need to do is to get a service principal with permissions to manage your Azure DNS.

Then in your console run this:
```
export AZUREDNS_SUBSCRIPTIONID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AZUREDNS_TENANTID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AZUREDNS_APPID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AZUREDNS_CLIENTSECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Then run this to create the certificate:
```
acme.sh --issue --dns dns_azure -d <fqdn>
```

If you need a pfx-file with the keys, run the below, otherwise you're done.
acme.sh --toPkcs -d <fqdn> --password ############