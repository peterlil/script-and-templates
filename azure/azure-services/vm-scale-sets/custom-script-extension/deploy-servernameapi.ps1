# Download published ServerNameAPI zip from Azure Storage or GitHub
Invoke-WebRequest -Uri "https://<your-storage-or-github-url>/ServerNameApi.zip" -OutFile "C:\ServerNameApi.zip"
Expand-Archive -Path "C:\ServerNameApi.zip" -DestinationPath "C:\ServerNameApi"

# Install .NET if needed (example for .NET 8)
$dotnetInstaller = "https://dotnet.microsoft.com/download/dotnet/thank-you/runtime-8.0.0-windows-x64-installer"
Invoke-WebRequest -Uri $dotnetInstaller -OutFile "C:\dotnet-installer.exe"
Start-Process "C:\dotnet-installer.exe" -ArgumentList "/quiet" -Wait

# Start the API (as a background process)
Start-Process "dotnet" -ArgumentList "C:\ServerNameApi\ServerNameApi.dll" -WindowStyle Hidden