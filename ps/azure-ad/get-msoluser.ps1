
$cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session;
Import-Module MSOnline;
Connect-MsolService -credential $cred


Get-MsolUser -UserPrincipalName peterlil@microsoft.com | Format-Table ObjectId