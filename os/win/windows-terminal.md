# Windows Terminal

## Run Windows Terminal with elevated privileges at login
This is based on [this awesome post from eddex at stack overflow](https://stackoverflow.com/questions/58014981/how-can-i-open-a-new-instance-of-windows-terminal-from-windows-terminal)

When following the recommendations in *eddex* post, it's very simple to create a scheduled task in *Task Scheduler* and tick the box *Run with highest privileges*. I used the following command line to launch *Windows Terminal*: 
```ps
C:\Windows\explorer.exe shell:AppsFolder\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe!App
```