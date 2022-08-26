# Manage SSH Keys

## Windows - PowerShell

Before generating an ssh key pair, make sure the `.ssh` folder exists. An easy way of doing that is to just use this command to generate a default key pair, which you will not use.
```PowerShell
ssh-keygen `
    -m PEM `
    -t rsa `
    -b 4096 `
    -C "bogus@user" `
    -N "bogus-password"
```

Use this script to generate ssh keys in PowerShell.

```PowerShell
$computername='<computername>'
$os='win'
$username='<username>'
$password=''
$certpath="$($env:USERPROFILE)\.ssh\$($os)-$($computername)"
ssh-keygen `
    -m PEM `
    -t rsa `
    -b 4096 `
    -C "$($username)@$($os).$($computername)" `
    -f $certpath `
    -N $password
```