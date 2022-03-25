# Set the git username and email
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

# Undo last commit
To undo the last commit, and preserve the files in the current repo so you don't loose the changes, run the following command.
```powershell
git reset --soft HEAD~1
```

# List local branches
```powershell
git branch
```

# Delete a local branch
It's common to want to delete a local branch, for instance after a pull request.
```powershell
git branch -d <local-branch>
```
