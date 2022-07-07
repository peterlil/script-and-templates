# Git/GitHub basics

## Set the git username and email

The git username and email is information that are bundled with the commits you make. So don't add your "real" e-mail.

Setting the attributes globally

```powershell
git config --global user.name "<username>"
git config --global user.email "<email@example.com>"
```

Setting the attributes for the current repo only

```powershell
git config user.name "<username>"
git config user.email "<email@example.com>"
```

List current settings

```powershell
git config -l
```

## Revert `git add`

```bash
git restore --staged
```

## Undo last commit

To undo the last commit, and preserve the files in the current repo so you don't loose the changes, run the following command.

```powershell
git reset --soft HEAD~1
```

## List local branches

```powershell
git branch
```

## Create a branch

Create a branch locally.

```powershell
git branch <new-branch-name>
```

Create a branch locally and check it out.

```powershell
git checkout -b <new-branch-name>
```

Create a branch in the remote (by pushing from local)

```powershell
git push -u <remote-name> <branch-name>
```

## Delete a local branch

It's common to want to delete a local branch, for instance after a pull request.

```powershell
git branch -d <local-branch>
```

## Delete a file from git, but not from disk

```powershell
git rm --cached <path-to-file>
git commit -m "Remove file <file> from git."
```

## Sync remote main with local feature branch

```shell
git pull origin main
```
