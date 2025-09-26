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

function Try-Me {
    Write-Host "Works like a charm!🪄"
}

function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded." -ForegroundColor Green
}

function Backup-Profile {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = "C:\src\github\peterlil\script-and-templates\ps\powershell\profiles-backup\profile_$timestamp.ps1"
    Copy-Item -Path $PROFILE -Destination $backupPath
    Write-Host "Profile backed up to $backupPath" -ForegroundColor Green
}