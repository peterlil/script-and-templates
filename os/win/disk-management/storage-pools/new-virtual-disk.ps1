[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Enumerate', 'Create')]
    [string]$Mode,

    [string]$SelectionFile = '.\virtual-disk-selection.json',

    [string]$DefaultVirtualDiskFriendlyName = 'datafiles-vdisk',

    [ValidateSet('Simple', 'Mirror', 'Parity')]
    [string]$DefaultResiliency = 'Simple',

    [ValidateRange(4096, 268435456)]
    [int]$AllocationUnitSize = 65536,

    [string]$FileSystem = 'NTFS'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PoolInventory {
    $pools = Get-StoragePool -IsPrimordial $false | Sort-Object FriendlyName

    foreach ($pool in $pools) {
        [PSCustomObject]@{
            FriendlyName = $pool.FriendlyName
            HealthStatus = $pool.HealthStatus
            SizeGB       = [math]::Round($pool.Size / 1GB, 2)
            AllocatedGB  = [math]::Round($pool.AllocatedSize / 1GB, 2)
            FreeGB       = [math]::Round(($pool.Size - $pool.AllocatedSize) / 1GB, 2)
            OperationalStatus = ($pool.OperationalStatus -join ',')
        }
    }
}

function Assert-DriveLetterAvailable {
    param(
        [Parameter(Mandatory)]
        [string]$DriveLetter
    )

    $normalized = $DriveLetter.Trim().TrimEnd(':').ToUpper()
    if ($normalized.Length -ne 1 -or $normalized -notmatch '^[A-Z]$') {
        throw "Drive letter '$DriveLetter' is invalid. Use a single letter like M."
    }

    $used = Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -eq $normalized }
    if ($used) {
        throw "Drive letter '$normalized' is already in use."
    }
}

function Assert-SelectionShape {
    param(
        [Parameter(Mandatory)]
        [object]$Plan
    )

    $required = @('StoragePoolFriendlyName', 'VirtualDiskFriendlyName', 'DriveLetter', 'VolumeLabel', 'ResiliencySettingName', 'UseMaximumSize', 'SizeGB')
    foreach ($name in $required) {
        if (-not ($Plan.PSObject.Properties.Name -contains $name)) {
            throw "Selection file is missing required property '$name'."
        }
    }
}

if ($Mode -eq 'Enumerate') {
    $poolInventory = @(Get-PoolInventory)
    if ($poolInventory.Count -eq 0) {
        throw 'No non-primordial storage pools were found.'
    }

    Write-Host ''
    Write-Host 'Storage pools available for virtual disk creation:' -ForegroundColor Cyan
    $poolInventory | Format-Table FriendlyName, HealthStatus, SizeGB, AllocatedGB, FreeGB, OperationalStatus -AutoSize

    Write-Host ''
    $poolName = Read-Host 'Enter StoragePool FriendlyName'
    $pool = Get-StoragePool -FriendlyName $poolName -IsPrimordial $false -ErrorAction SilentlyContinue
    if (-not $pool) {
        throw "Storage pool '$poolName' was not found."
    }

    $virtualDiskFriendlyName = Read-Host "Enter VirtualDisk FriendlyName (default: $DefaultVirtualDiskFriendlyName)"
    if ([string]::IsNullOrWhiteSpace($virtualDiskFriendlyName)) {
        $virtualDiskFriendlyName = $DefaultVirtualDiskFriendlyName
    }

    $driveLetterInput = Read-Host 'Enter DriveLetter (single letter, example: M)'
    $driveLetter = $driveLetterInput.Trim().TrimEnd(':').ToUpper()
    Assert-DriveLetterAvailable -DriveLetter $driveLetter

    $volumeLabel = Read-Host "Enter VolumeLabel (default: $virtualDiskFriendlyName)"
    if ([string]::IsNullOrWhiteSpace($volumeLabel)) {
        $volumeLabel = $virtualDiskFriendlyName
    }

    Write-Host ''
    Write-Host "Resiliency options: Simple, Mirror, Parity (default: $DefaultResiliency)" -ForegroundColor Cyan
    $resiliencyInput = Read-Host 'Enter ResiliencySettingName or press Enter for default'
    $resiliency = if ([string]::IsNullOrWhiteSpace($resiliencyInput)) { $DefaultResiliency } else { $resiliencyInput }
    if (@('Simple', 'Mirror', 'Parity') -notcontains $resiliency) {
        throw "Invalid resiliency setting '$resiliency'."
    }

    $sizeChoice = Read-Host 'Use maximum available size? (Y/N, default Y)'
    $useMaximumSize = if ([string]::IsNullOrWhiteSpace($sizeChoice) -or $sizeChoice.ToUpper() -eq 'Y') { $true } else { $false }

    $sizeGB = 0
    if (-not $useMaximumSize) {
        $sizeInput = Read-Host 'Enter virtual disk size in GB (integer)'
        $sizeGB = [int]$sizeInput
        if ($sizeGB -le 0) {
            throw 'SizeGB must be greater than zero.'
        }

        $freeGB = [math]::Floor(($pool.Size - $pool.AllocatedSize) / 1GB)
        if ($sizeGB -gt $freeGB) {
            throw "Requested size ($sizeGB GB) exceeds estimated free capacity ($freeGB GB)."
        }
    }

    Write-Host ''
    Write-Host 'Selection summary (verify carefully):' -ForegroundColor Yellow
    [PSCustomObject]@{
        StoragePoolFriendlyName = $pool.FriendlyName
        VirtualDiskFriendlyName = $virtualDiskFriendlyName
        DriveLetter             = $driveLetter
        VolumeLabel             = $volumeLabel
        ResiliencySettingName   = $resiliency
        UseMaximumSize          = $useMaximumSize
        SizeGB                  = $sizeGB
        PartitionStyle          = 'GPT'
        FileSystem              = $FileSystem
        AllocationUnitSize      = $AllocationUnitSize
    } | Format-List

    $confirm = Read-Host "Type SAVE to save this selection into $SelectionFile"
    if ($confirm -ne 'SAVE') {
        throw 'Selection not saved.'
    }

    $payload = [PSCustomObject]@{
        CreatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        ComputerName = $env:COMPUTERNAME
        StoragePoolFriendlyName = $pool.FriendlyName
        VirtualDiskFriendlyName = $virtualDiskFriendlyName
        DriveLetter             = $driveLetter
        VolumeLabel             = $volumeLabel
        ResiliencySettingName   = $resiliency
        UseMaximumSize          = $useMaximumSize
        SizeGB                  = $sizeGB
        PartitionStyle          = 'GPT'
        FileSystem              = $FileSystem
        AllocationUnitSize      = $AllocationUnitSize
    }

    $payload | ConvertTo-Json -Depth 5 | Set-Content -Path $SelectionFile -Encoding UTF8
    Write-Host "Selection saved to $SelectionFile" -ForegroundColor Green
    Write-Host 'Next step: run with -Mode Create using the same selection file.'
    return
}

if ($Mode -eq 'Create') {
    if (-not (Test-Path -Path $SelectionFile -PathType Leaf)) {
        throw "Selection file not found: $SelectionFile"
    }

    $plan = Get-Content -Path $SelectionFile -Raw | ConvertFrom-Json
    Assert-SelectionShape -Plan $plan

    $pool = Get-StoragePool -FriendlyName $plan.StoragePoolFriendlyName -IsPrimordial $false -ErrorAction SilentlyContinue
    if (-not $pool) {
        throw "Storage pool '$($plan.StoragePoolFriendlyName)' was not found."
    }

    Assert-DriveLetterAvailable -DriveLetter $plan.DriveLetter

    $existingVirtualDisk = Get-VirtualDisk -FriendlyName $plan.VirtualDiskFriendlyName -ErrorAction SilentlyContinue
    if ($existingVirtualDisk) {
        throw "Virtual disk '$($plan.VirtualDiskFriendlyName)' already exists."
    }

    Write-Host ''
    Write-Host 'Final verification before create:' -ForegroundColor Yellow
    [PSCustomObject]@{
        StoragePoolFriendlyName = $plan.StoragePoolFriendlyName
        VirtualDiskFriendlyName = $plan.VirtualDiskFriendlyName
        DriveLetter             = $plan.DriveLetter
        VolumeLabel             = $plan.VolumeLabel
        ResiliencySettingName   = $plan.ResiliencySettingName
        UseMaximumSize          = [bool]$plan.UseMaximumSize
        SizeGB                  = [int]$plan.SizeGB
        PartitionStyle          = 'GPT'
        FileSystem              = $plan.FileSystem
        AllocationUnitSize      = [int]$plan.AllocationUnitSize
    } | Format-List

    $approval = Read-Host 'Type CREATE VDISK to proceed'
    if ($approval -ne 'CREATE VDISK') {
        throw 'Virtual disk creation cancelled.'
    }

    if ([bool]$plan.UseMaximumSize) {
        New-VirtualDisk -StoragePoolFriendlyName $plan.StoragePoolFriendlyName -FriendlyName $plan.VirtualDiskFriendlyName -ResiliencySettingName $plan.ResiliencySettingName -UseMaximumSize | Out-Null
    }
    else {
        New-VirtualDisk -StoragePoolFriendlyName $plan.StoragePoolFriendlyName -FriendlyName $plan.VirtualDiskFriendlyName -ResiliencySettingName $plan.ResiliencySettingName -Size ([uint64]([int]$plan.SizeGB * 1GB)) | Out-Null
    }

    $virtualDisk = Get-VirtualDisk -FriendlyName $plan.VirtualDiskFriendlyName
    $disk = $virtualDisk | Get-Disk

    if ($disk.PartitionStyle -eq 'RAW') {
        $disk = $disk | Initialize-Disk -PartitionStyle GPT -PassThru
    }

    $partition = $disk | New-Partition -DriveLetter $plan.DriveLetter -UseMaximumSize
    $null = $partition | Format-Volume -FileSystem $plan.FileSystem -NewFileSystemLabel $plan.VolumeLabel -AllocationUnitSize ([int]$plan.AllocationUnitSize) -Confirm:$false

    Write-Host "Virtual disk created and formatted: $($plan.VirtualDiskFriendlyName)" -ForegroundColor Green
    Write-Host "Mounted as drive $($plan.DriveLetter):" -ForegroundColor Green
}

# Step 1, enumerate and save selection:
# .\new-virtual-disk.ps1 -Mode Enumerate -SelectionFile .\virtual-disk-selection.json
#
# Step 2, verify again and create:
# .\new-virtual-disk.ps1 -Mode Create -SelectionFile .\virtual-disk-selection.json
