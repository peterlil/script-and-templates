
# --- Config ---
$EventSource = 'Updateme.Script'
$EventLogName = 'Application'
$Evt = @{
    SectionStart = 1000
    SectionOK    = 1001
    SectionWarn  = 1002
    SectionErr   = 1003
}

#region Helpers
# ================================
# Section: Helpers
# ================================
function Ensure-Admin {
    # Ensures the script is running with admin rights; if not, relaunches as admin 
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Elevation required. Relaunching as Administrator..."
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = (Get-Process -Id $PID).Path
        $args = @()
        if ($PSCommandPath) { $args += '-File', "`"$PSCommandPath`"" }
        if ($MyInvocation.UnboundArguments) { $args += $MyInvocation.UnboundArguments }
        $psi.Arguments = $args -join ' '
        $psi.Verb = 'runas'
        [Diagnostics.Process]::Start($psi) | Out-Null
        exit
    }
}

function Ensure-EventSource {
    # Ensures the event source exists; if not, creates it
    if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
        New-EventLog -LogName $EventLogName -Source $EventSource
    }
}

function Set-WindowTitle {
    # Sets the console window title if running interactively
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )
    try {
        $host.UI.RawUI.WindowTitle = $Title
    } catch {
        # Non-interactive host; ignore
    }
}

function Write-AppLog {
    <#
    .SYNOPSIS
        Writes a line to console and (best-effort) to Windows Application log.
    .PARAMETER Message
        The text to log.
    .PARAMETER Level
        Information | Warning | Error
    .PARAMETER EventId
        Integer event id to write.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Information','Warning','Error')]
        [string]$Level = 'Information',

        [int]$EventId = $script:Evt_SectionOK  # assumes you've defined this earlier
    )

    # Console echo (avoid "$Level: ..." parsing issue)
    Write-Host ("{0}: {1}" -f $Level, $Message)

    # Event log write (best effort)
    try {
        if ([System.Diagnostics.EventLog]::SourceExists($script:EventSource)) {
            $entryType = [System.Diagnostics.EventLogEntryType]::$Level
            Write-EventLog -LogName $script:EventLogName `
                           -Source  $script:EventSource `
                           -EventId $EventId `
                           -EntryType $entryType `
                           -Message $Message
        }
    } catch {
        # swallow to keep maintenance flow resilient
    }
}

<#
.SYNOPSIS
    Invokes a script block with logging and window title management.
.EXAMPLE
    Invoke-Step "Windows Update" { Upgrade-PSWindowsUpdate }
#>
function Invoke-Step {
    # Sets the window title, logs start, runs the script block, logs success or failure
    param([string]$Name,[scriptblock]$Script)
    Set-WindowTitle $Name
    Write-AppLog "$Name - Running..." 'Information' $Evt.SectionStart
    try {
        & $Script
        Write-AppLog "$Name - OK" 'Information' $Evt.SectionOK
    } catch {
        Write-AppLog "$Name - ERROR: $($_.Exception.Message)" 'Error' $Evt.SectionErr
    }
}
#endregion

#region SSH Profile Management
# ================================
# Section: SSH Profile Management
# ================================
<#
.SYNOPSIS
    Activates a named SSH profile by copying the corresponding key files to the default names and setting appropriate permissions.
.DESCRIPTION
    This function helps manage multiple SSH key pairs by allowing you to switch between them easily.
.PARAMETER Name
    The name of the SSH profile to activate. This corresponds to key files named id_rsa-<Name> and id_rsa-<Name>.pub in the .ssh directory.
.EXAMPLE
    Set-SshProfile -Name "work"
    Activates the SSH profile named "work" by copying id_rsa-work and id_rsa-work.pub to id_rsa and id_rsa.pub respectively, and sets permissions.
.NOTES
    Ensure that the .ssh directory and the specified key files exist before running this function.
#>
function Set-SshProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$Name
    )

    # 1) Determine your exact account name
    $account = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    # e.g. "AzureAD\PeterLiljenroth"

    # 2) Validate .ssh folder & named key files
    $sshFolder = Join-Path $env:USERPROFILE '.ssh'
    if (-not (Test-Path $sshFolder)) {
        Write-Error "Missing .ssh directory at $sshFolder"
        return
    }

    $srcPriv = Join-Path $sshFolder "id_rsa-$Name"
    $srcPub  = Join-Path $sshFolder "id_rsa-$Name.pub"
    $dstPriv = Join-Path $sshFolder 'id_rsa'
    $dstPub  = Join-Path $sshFolder 'id_rsa.pub'

    foreach ($f in @($srcPriv, $srcPub)) {
        if (-not (Test-Path $f)) {
            Write-Error "Key file not found: $f"
            return
        }
    }

    # 3) Copy into place
    try {
        Copy-Item $srcPriv -Destination $dstPriv -Force
        Copy-Item $srcPub  -Destination $dstPub  -Force
    }
    catch {
        Write-Error "Copy failed: $($_.Exception.Message)"
        return
    }

    $success = $false

    # 4) Primary: Set-Acl with your AzureAD identity
    try {
        $ErrorActionPreference = 'Stop'
        $acl = Get-Acl $dstPriv
        $acl.SetAccessRuleProtection($true, $false)

        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $account, 'FullControl', 'Allow'
        )
        $acl.SetAccessRule($rule)
        Set-Acl -Path $dstPriv -AclObject $acl

        Write-Host "Permissions set via Set-Acl for $account" -ForegroundColor Green
        $success = $true
    }
    catch {
        $ErrorActionPreference = 'Continue'
        Write-Warning "Set-Acl failed: $($_.Exception.Message)"
        Write-Host "Falling back to icacls for $account…" -ForegroundColor Yellow

        # 5a) Remove inheritance
        & icacls $dstPriv '/inheritance:r' | Write-Host

        # 5b) Grant FullControl to the same AzureAD account
        & icacls $dstPriv '/grant' "${account}:(F)" | ForEach-Object {
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "icacls grant failed: $_"
            } else {
                Write-Host $_
                $success = $true
            }
        }
    }

    # 6) Final feedback
    if ($success) {
        Write-Host "✅ SSH profile '$Name' activated for $account." -ForegroundColor Green
    }
    else {
        Write-Host "❌ SSH profile '$Name' activation failed for $account." -ForegroundColor Red
    }
}

function List-SshProfiles {
    $sshDir = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh"
    
    # Quit if the .ssh directory does not exist
    if (-not (Test-Path -Path $sshDir)) {
        Write-Error "The .ssh directory does not exist in your user profile."
        return
    }

    # Get all private key files matching the pattern
    $privateKeys = Get-ChildItem -Path $sshDir -Filter "id_rsa-*" | Where-Object { -not $_.Name.EndsWith(".pub") }

    if ($privateKeys.Count -eq 0) {
        Write-Host "No SSH profiles found."
        return
    }

    Write-Host "Available SSH Profiles:" -ForegroundColor Cyan
    foreach ($key in $privateKeys) {
        $profileName = $key.Name -replace "^id_rsa-", ""
        Write-Host "- $profileName"
    }
}
#endregion


#region Custom Prompt
# ================================
# Section: Custom Prompt
# ================================

<# Custom Prompt Function #>
function prompt {

    $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"
    $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    Write-Host ""
    Write-Host "`u{1F9D9} $($CmdPromptUser.Name.split("\")[1]) " -ForegroundColor Green -NoNewline
    Write-host ($(if ($IsAdmin) { '(as admin) ' } else { '' })) -ForegroundColor Red -NoNewLine
    Write-Host "on `u{1F4BB}" $env:COMPUTERNAME"."$env:USERDNSDOMAIN

    Write-Host "`u{1F4C1} $pwd"  -ForegroundColor Yellow 
    return "`u{25B6} "
} 
#endregion


function Try-Me {
    Write-Host "Works like a charm!🪄"
}

#region Profile Management
# ================================
# Section: Profile Management
# ================================

<#
.SYNOPSIS
    Reloads the current PowerShell profile.
#>
function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded." -ForegroundColor Green
}

<#
.SYNOPSIS
    Backs up the current PowerShell profile to a timestamped file within a Git-tracked directory.
#>
function Backup-Profile {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = "C:\src\github\peterlil\script-and-templates\ps\powershell\profiles-backup\profile_$timestamp.ps1"
    Copy-Item -Path $PROFILE -Destination $backupPath
    Write-Host "Profile backed up to $backupPath" -ForegroundColor Green
}
#endregion

#region Application and Package Management
# ================================
# Section: Software Management
# ================================
<#
.SYNOPSIS
    Lists VS Code extensions that have updates available.
.DESCRIPTION
    This function queries the VS Code marketplace to check which installed extensions have newer versions available.
.EXAMPLE
    Get-VSCodeExtensionUpdates
.NOTES
    Requires VS Code CLI (code or code-insiders) to be in PATH and internet connectivity to query the marketplace.
#>
function Get-VSCodeExtensionUpdates {
    try {
        # Determine which VS Code CLI is available
        $codeCmd = if (Get-Command code-insiders -ErrorAction SilentlyContinue) { 'code-insiders' } 
                   elseif (Get-Command code -ErrorAction SilentlyContinue) { 'code' }
                   else { 
                       Write-Host "VS Code CLI not found in PATH." -ForegroundColor Red
                       return
                   }

        Write-Host "Checking for extension updates..." -ForegroundColor Cyan
        
        # Get all installed extensions with versions
        $installed = & $codeCmd --list-extensions --show-versions | ForEach-Object {
            $parts = $_ -split '@'
            [PSCustomObject]@{
                Id = $parts[0]
                InstalledVersion = $parts[1]
            }
        }

        if (-not $installed) {
            Write-Host "No extensions installed." -ForegroundColor Yellow
            return
        }

        Write-Host "Checking $($installed.Count) extensions against marketplace..." -ForegroundColor Cyan
        
        $updatesAvailable = @()
        
        foreach ($ext in $installed) {
            try {
                # Query the VS Code marketplace API for latest version
                $publisher, $extensionName = $ext.Id -split '\.'
                $url = "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery"
                
                $body = @{
                    filters = @(
                        @{
                            criteria = @(
                                @{ filterType = 7; value = $ext.Id }
                            )
                            pageSize = 1
                        }
                    )
                    flags = 0x192
                } | ConvertTo-Json -Depth 10
                
                $headers = @{
                    'Content-Type' = 'application/json'
                    'Accept' = 'application/json;api-version=3.0-preview.1'
                }
                
                $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers -ErrorAction Stop
                
                if ($response.results[0].extensions.Count -gt 0) {
                    $latestVersion = $response.results[0].extensions[0].versions[0].version
                    
                    if ($latestVersion -ne $ext.InstalledVersion) {
                        $updatesAvailable += [PSCustomObject]@{
                            Extension = $ext.Id
                            Installed = $ext.InstalledVersion
                            Latest = $latestVersion
                        }
                    }
                }
            } catch {
                Write-Host "  Warning: Could not check $($ext.Id)" -ForegroundColor Yellow
            }
        }
        
        if ($updatesAvailable.Count -eq 0) {
            Write-Host "`nAll extensions are up to date!" -ForegroundColor Green
        } else {
            $updatesAvailable | ForEach-Object { $_.Extension }
        }
        
    } catch {
        Write-Host "Error retrieving extensions: $($_.Exception.Message)" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
    Runs Windows Update and installs all available updates.
.DESCRIPTION
    This function uses the PSWindowsUpdate module to check for, download, and install all available Windows updates.
    It requires administrative privileges to execute successfully. 
.EXAMPLE
    Upgrade-PSWindowsUpdate
#>
function Upgrade-PSWindowsUpdate {
    # Upgrades Windows via PSWindowsUpdate module. You should install it first.
    try {
        if (-not (Get-Module PSWindowsUpdate -ListAvailable)) {
            Install-Module PSWindowsUpdate -Scope CurrentUser -Force
        }
        Import-Module PSWindowsUpdate
        $updates = Get-WindowsUpdate
        if ($updates) { Install-WindowsUpdate -AcceptAll -IgnoreReboot } else { Write-AppLog "No Windows Updates" }
    } catch {
        Write-AppLog "PSWindowsUpdate failed: $($_.Exception.Message)" 'Warning'
    }
}

<# Updates Windows Subsystem for Linux #>
function Update-WSL {
    # Updates Windows Subsystem for Linux if installed
    if (Get-Command wsl -ErrorAction SilentlyContinue) { wsl --update } else { Write-AppLog "WSL not found" 'Warning' }
}
#endregion

#region File management
# ================================
# Section: File functions 
# ================================
function Robocopy-Fast {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )
    robocopy $Source $Destination /E /COPY:DAT /R:0 /W:0 /MT:12 /NP /LOG:NUL /DCOPY:DAT
}


#region Wrapper functions
# ================================
# Section: Wrapper functions 
# ================================
function Update-Windows {
    Ensure-Admin
    Ensure-EventSource
    Invoke-Step "Windows Update" { Upgrade-PSWindowsUpdate }
}

#endregion

function Add-LocalRoutes {
    route delete 192.168.1.0
    route delete 192.168.2.0
    route delete 192.168.4.0
    route delete 192.168.5.0
    route delete 192.168.7.0
    route add 192.168.1.0 mask 255.255.255.0 192.168.3.1
    route add 192.168.2.0 mask 255.255.255.0 192.168.3.1
    route add 192.168.4.0 mask 255.255.255.0 192.168.3.1
    route add 192.168.5.0 mask 255.255.255.0 192.168.3.1
    route add 192.168.7.0 mask 255.255.255.0 192.168.3.1
}

function Get-KeyVaultSecretToClipboard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name of the secret.")]
        [Alias('n')]
        [string]$name,
        [Parameter(Mandatory=$false)][string]$subscriptionId,
        [Parameter(Mandatory=$false)][string]$keyVaultName
    )
    
    # If subscriptionId is not provided, get id from the env variable PersonalAzureSubscriptionId
    if (-not $subscriptionId) {
        $subscriptionId = $env:PersonalAzureSubscriptionId
    }

    # If keyVaultName is not provided, get it from the env variable PersonalKeyVaultName
    if (-not $keyVaultName) {
        $keyVaultName = $env:PersonalKeyVaultName
    }

    $value = az keyvault secret show -n $name `
        --subscription $subscriptionId `
        --vault-name $keyVaultName `
        --query "value" `
        -o tsv

    Set-Clipboard -Value $value

    Write-Host "Secret added to clipboard"

}