# Some examples of how to start apps from PowerShell

## Visual Studio

Make sure you have the path to the desired VS version in the registry (`Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\devenv.exe`)

Start VS
```powershell
start devenv
```

Start VS and load solution
```powershell
start devenv <path to solution>
```