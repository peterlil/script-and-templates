fqdn=peterlil444-tmp.trafficmanager.net

# Pre-reqisite: The certificate needs to be uploaded to the App Service once prior to running this script
certName=styleboards-test-trafficmanager-net
rgName=styleboards-test-weu-rg
webapp=styleboards-test-weu-as

# Read the thumbprint of the certificate from App Service
thumbprint=$(az webapp config ssl show --certificate-name $certName -g $rgName --query "thumbprint" -o tsv)

# Bind the certificate to the webapp
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name $webapp -g $rgName

echo "You can now browse to https://$fqdn"
