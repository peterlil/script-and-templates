# Manage SSH Keys

## SSH directory permissions

Object | Permission
-------|-----------
`.ssh` directory | 700 (`drwx------`)
`id_rsa.pub` | 644 (`-rw-r--r--`)
`id_rsa` | 600 (`-rw-------`)

```bash
chmod 700 ~/.ssh
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
```

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