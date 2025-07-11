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
