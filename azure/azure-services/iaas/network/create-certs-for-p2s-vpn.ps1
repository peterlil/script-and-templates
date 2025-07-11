# Info from: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site#clientcert

# Use the following example to create the self-signed root certificate. 
# The following example creates a self-signed root certificate named 'P2SRootCert' 
# that is automatically installed in 'Certificates-Current User\Personal\Certificates'. 
# You can view the certificate by opening certmgr.msc, or Manage User Certificates.

$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=T4P2SRootCert" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign




# This example uses the declared '$cert' variable from the previous section. 
# If you closed the PowerShell console after creating the self-signed root certificate, 
# or are creating additional client certificates in a new PowerShell console session, use the steps in Example 2.

#Example 1
# Modify and run the example to generate a client certificate. If you run the following
# example without modifying it, the result is a client certificate named 'P2SChildCert'.
# If you want to name the child certificate something else, modify the CN value.
# Do not change the TextExtension when running this example. The client certificate that
# you generate is automatically installed in 'Certificates - Current User\Personal\Certificates'
# on your computer.
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
    -Subject "CN=T4P2SChildCert" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")


# Generate the VPN client configuration files
Login-AzureRmAccount
$profile=New-AzureRmVpnClientConfiguration -ResourceGroupName "Test4" -Name "t4vpngw" -AuthenticationMethod "EapTls"
$profile.VPNProfileSASUrl