# Windows Terminal

## Run Windows Terminal (or preview) with elevated privileges at login
Create a .bat-file with `wt.exe` and execute it using a scheduled task in *Task Scheduler* and tick the box *Run with highest privileges*.


## Run Windows Terminal with elevated privileges at login if you have Preview version installed side-by-side
This is based on [this awesome post from eddex at stack overflow](https://stackoverflow.com/questions/58014981/how-can-i-open-a-new-instance-of-windows-terminal-from-windows-terminal)

When following the recommendations in *eddex* post, it's very simple to create a scheduled task in *Task Scheduler* and tick the box *Run with highest privileges*. I used the following command line to launch *Windows Terminal*: 
```ps
C:\Windows\explorer.exe shell:AppsFolder\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe!App
```

## Run Windows Terminal with PowerShell and Ubuntu

```
wt -M -p "Powershell" -d \src\github; split-pane -p "Ubuntu" -d /mnt/c/src/github
```