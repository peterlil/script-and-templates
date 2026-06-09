[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Enumerate', 'Create')]
    [string]$Mode,

    [string]$StoragePoolFriendlyName = 'datafiles-selected',

    [string]$SelectionFile = '.\storage-pool-selection.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-DiskNumberMap {
    $ns = 'root/microsoft/windows/storage'
    $map = @{}

    $msftPhysicalDisks = Get-CimInstance -Namespace $ns -ClassName MSFT_PhysicalDisk
    foreach ($mpd in $msftPhysicalDisks) {
        $associatedDisk = Get-CimAssociatedInstance -InputObject $mpd -ResultClassName MSFT_Disk -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($associatedDisk -and $mpd.UniqueId) {
            $map[$mpd.UniqueId] = [int]$associatedDisk.Number
        }
    }

    return $map
}

function Get-PhysicalDiskInventory {
    $diskNumberMap = Get-DiskNumberMap
    $physicalDisks = Get-PhysicalDisk | Sort-Object DeviceId

    $inventory = foreach ($pd in $physicalDisks) {
        [PSCustomObject]@{
            DiskNumber   = if ($diskNumberMap.ContainsKey($pd.UniqueId)) { $diskNumberMap[$pd.UniqueId] } else { $null }
            DeviceId     = [int]$pd.DeviceId
            FriendlyName = $pd.FriendlyName
            SerialNumber = $pd.SerialNumber
            UniqueId     = $pd.UniqueId
            SizeGB       = [math]::Round($pd.Size / 1GB, 2)
            CanPool      = [bool]$pd.CanPool
            HealthStatus = $pd.HealthStatus
            MediaType    = $pd.MediaType
            BusType      = $pd.BusType
        }
    }

    return $inventory
}

function Resolve-SelectedPhysicalDisks {
    param(
        [Parameter(Mandatory)]
        [array]$SelectionRows
    )

    $allPhysicalDisks = Get-PhysicalDisk
    $selected = @()

    foreach ($row in $SelectionRows) {
        $match = $allPhysicalDisks | Where-Object { $_.UniqueId -eq $row.UniqueId }
        if (-not $match -and $null -ne $row.DeviceId) {
            $match = $allPhysicalDisks | Where-Object { [int]$_.DeviceId -eq [int]$row.DeviceId }
        }
        if (-not $match) {
            throw "Could not resolve selected disk. UniqueId='$($row.UniqueId)', DeviceId='$($row.DeviceId)'"
        }
        $selected += $match
    }

    $selected = $selected | Sort-Object UniqueId -Unique

    $notPoolable = $selected | Where-Object { -not $_.CanPool }
    if ($notPoolable) {
        throw "One or more selected disks are not poolable: $($notPoolable.FriendlyName -join ', ')"
    }

    return $selected
}

if ($Mode -eq 'Enumerate') {
    $inventory = Get-PhysicalDiskInventory

    Write-Host ''
    Write-Host 'All physical disks (review before selection):' -ForegroundColor Cyan
    $inventory | Format-Table DiskNumber, DeviceId, SizeGB, CanPool, FriendlyName, SerialNumber, UniqueId -AutoSize

    Write-Host ''
    Write-Host 'Selection method:' -ForegroundColor Cyan
    Write-Host '1 = DiskNumber'
    Write-Host '2 = DeviceId (recommended)'
    Write-Host '3 = UniqueId'
    $method = Read-Host 'Choose 1, 2, or 3'

    if ($method -eq '1') {
        $raw = Read-Host 'Enter DiskNumber values separated by comma (example: 2,3,7,8)'
        $requested = ($raw -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } | ForEach-Object { [int]$_ }

        if (-not ($inventory | Where-Object { $null -ne $_.DiskNumber })) {
            throw 'DiskNumber mapping is unavailable in this environment. Use DeviceId selection method instead.'
        }

        $selectedRows = $inventory | Where-Object {
            ($_.DiskNumber -ne $null) -and ($requested -contains $_.DiskNumber)
        }
    }
    elseif ($method -eq '2') {
        $raw = Read-Host 'Enter DeviceId values separated by comma (example: 2,3,7,8)'
        $requested = ($raw -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } | ForEach-Object { [int]$_ }

        $selectedRows = $inventory | Where-Object { $requested -contains $_.DeviceId }
    }
    elseif ($method -eq '3') {
        $raw = Read-Host 'Enter UniqueId values separated by comma'
        $requested = ($raw -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

        $selectedRows = $inventory | Where-Object { $requested -contains $_.UniqueId }
    }
    else {
        throw 'Invalid selection method.'
    }

    if (-not $selectedRows) {
        throw 'No disks matched your selection. Verify that you selected the identifier type (DiskNumber/DeviceId/UniqueId) that matches your input values.'
    }

    Write-Host ''
    Write-Host 'Selected disks (verification):' -ForegroundColor Yellow
    $selectedRows | Format-Table DiskNumber, DeviceId, SizeGB, CanPool, FriendlyName, SerialNumber, UniqueId -AutoSize

    $confirm = Read-Host "Type SAVE to save this selection into $SelectionFile"
    if ($confirm -ne 'SAVE') {
        throw 'Selection not saved.'
    }

    $payload = [PSCustomObject]@{
        CreatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        ComputerName = $env:COMPUTERNAME
        PoolName     = $StoragePoolFriendlyName
        SelectedDisks = @($selectedRows | Select-Object DiskNumber, DeviceId, FriendlyName, SerialNumber, UniqueId, SizeGB)
    }

    $payload | ConvertTo-Json -Depth 5 | Set-Content -Path $SelectionFile -Encoding UTF8
    Write-Host "Selection saved to $SelectionFile" -ForegroundColor Green
    Write-Host "Next step: run with -Mode Create using the same selection file."
    return
}

if ($Mode -eq 'Create') {
    if (-not (Test-Path -Path $SelectionFile -PathType Leaf)) {
        throw "Selection file not found: $SelectionFile"
    }

    $saved = Get-Content -Path $SelectionFile -Raw | ConvertFrom-Json
    if (-not $saved.SelectedDisks -or $saved.SelectedDisks.Count -eq 0) {
        throw 'Selection file contains no selected disks.'
    }

    $selectedRows = @($saved.SelectedDisks)
    $selectedPhysicalDisks = Resolve-SelectedPhysicalDisks -SelectionRows $selectedRows

    $verification = $selectedPhysicalDisks | Select-Object `
        @{Name='DeviceId';Expression={[int]$_.DeviceId}},
        FriendlyName,
        SerialNumber,
        UniqueId,
        @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 2)}},
        CanPool,
        HealthStatus

    Write-Host ''
    Write-Host 'Final verification before create:' -ForegroundColor Yellow
    $verification | Format-Table -AutoSize

    $storage = Get-StorageSubSystem
    Write-Host ''
    Write-Host "Storage Subsystem: $($storage.FriendlyName)"
    Write-Host "Pool Name: $StoragePoolFriendlyName"
    Write-Host "Disk Count: $($selectedPhysicalDisks.Count)"

    $approval = Read-Host 'Type CREATE POOL to proceed'
    if ($approval -ne 'CREATE POOL') {
        throw 'Pool creation cancelled.'
    }

    New-StoragePool -FriendlyName $StoragePoolFriendlyName -StorageSubSystemUniqueId $storage.UniqueId -PhysicalDisks $selectedPhysicalDisks
    Write-Host "Storage pool created: $StoragePoolFriendlyName" -ForegroundColor Green
}

# Step 1, enumerate and save selection:
# .\new-storage-pool-safe.ps1 -Mode Enumerate -StoragePoolFriendlyName datafiles-selected -SelectionFile .\pool-selection.json
# 
# Step 2, verify again and create:
# .\new-storage-pool-safe.ps1 -Mode Create -StoragePoolFriendlyName datafiles-selected -SelectionFile .\pool-selection.json