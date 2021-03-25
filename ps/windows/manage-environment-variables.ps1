# Add a path to PATH

$oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
$newPath = "$oldPath;C:\Program Files\apache-maven-3.6.3\bin"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path -Value $newPath

# Set the JAVA_HOME environment variable permanent
[Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
[Environment]::SetEnvironmentVariable("JAVA_HOME", 'C:\Program Files\Zulu\zulu-8', 'Machine')

