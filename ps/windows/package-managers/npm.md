# NPM helpers

## Common Commands

Get all the remote versions for a package \
`npm info <package> versions`

Show the installed version of a package \
`npm show <package> version`

Show all remote versions of a package \
`npm view <package> versions`

Show the newest remote version of a package \
`npm view <package> version`

List globally installed packages \
`npm list -g`

Install a package globally \
`npm install -g <package>`

Install the latest package \
`npm install <package>@latest`

Show global packages that has newer versions. Remove -g for local packages. \
`npm outdated -g`

Show direct dependencies of remote packages. \
`npm view <package> dependencies`

Uninstall a package \
`npm uninstall <package>`

Uninstall a global package \
`npm uninstall -g <package>`

Update all global packages \

`npm update -g`

Update specific global package

`npm update -g <package>`

## Packages that I use

```powershell
unzipper
https-proxy-agent
azure-functions-core-tools@latest # This does not give the latest version!!!
```

## Strange behaviors

This command removes older sticky versions of azure-functions-core-tools \
`npm update -g azure-functions-core-tools@latest` \
without installing the specified package. It also removes all other globally installed packages.
