# Git/GitHub basics

## Git configuration order

Prio | File | Description
-----|------|------------
3 | `[path]/etc/gitconfig` | System wide
2 | ` ~/.gitconfig` or `~/.config/git/config` | Specific to each user.
1 | The Git directory (`.git/config`) | Specific to each repo.

[Reference](https://www.git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)

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

## List current settings

```powershell
# all settings
git config -l

# setting per scope
git config -l --local
git config -l --global
git config -l --system
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
# Get the changes into the local branch
git pull origin main
# Push the branch changes to the github rep
git push
```

## Committed to main when you really wanted to work in a branch?

Make the new branch off main.

```PowerShell
git branch <new-branch-name> main
```

Move main back to last valid commit for main.

```PowerShell
git checkout main
git reset --hard <last main commit>
```

Now, [gently force push](https://blog.developer.atlassian.com/force-with-lease/) the reset to remote main branch.

```PowerShell
git push --force-with-lease
```

## Remove Git Ignore Files from Git Repository

### Remove a few files

```shell
git rm --cached file1 file2 dir/file3
```

### Remove Many Files (Linux)

Using one rm command

```shell
git rm --cached `git ls-files -i -c --exclude-from=.gitignore`
```

Using many rm commands

```shell
git ls-files -i -c --exclude-from=.gitignore | xargs git rm --cached  
```

### Remove Many Files (Windows)

```PowerShell
git ls-files -i -c --exclude-from=.gitignore | %{git rm --cached $_}
```

## Make a shell script executable

```shell
git update-index --chmod=+x .\filename.sh
```

## Make your local repo look exactly like a new clone from GitHub

```bash
git reset --hard origin/main
git clean -fdX
```

# Authentication issues

## Fix when git has lost auth token for Enterprise account

The symptom is that you are trying to push/pull from a remote and you get an error like this: `remote: Repository not found.`

Solution:
Set the enterprise username in the remote url, this will force a new login next time when you try to push/pull.

```PowerShell
git remote set-url origin https://<username>@<url to repo>
```


# Troubleshooting
```PowerShell


## git problems with vscode

### Fix the _the folder currently open doesn't have a git repository_ problem

Issue explaning the problem and solution [here](https://github.com/microsoft/vscode/issues/147358).

Run this command to fix it. 

```PowerShell
git config --global safe.directory *
```
