# Get the valye of path
Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path

# Add a path to PATH
$oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
$newPath = "$oldPath;C:\Program Files\apache-maven-3.6.3\bin"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path -Value $newPath

# Replace a path to PATH
$oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
$newPath = $oldPath.Replace("C:\Program Files\Zulu\zulu-8\bin\", "C:\Program Files\Zulu\zulu-11\bin")
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path -Value $newPath

# Set the JAVA_HOME environment variable permanent
[Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
[Environment]::SetEnvironmentVariable("JAVA_HOME", 'C:\Program Files\Zulu\zulu-11', 'Machine')

