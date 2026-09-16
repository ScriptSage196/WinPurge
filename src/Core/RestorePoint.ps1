<#
.SYNOPSIS
    System restore point management for WinPurge
    
.DESCRIPTION
    Creates and manages system restore points before applying batch changes.
    Allows users to easily rollback to previous state if needed.
#>

<#
.DESCRIPTION
    Create a system restore point
#>
function New-WinPurgeRestorePoint {
    param(
        [string]$Description = "WinPurge Restore Point",
        [ValidateSet('MODIFY_SETTINGS', 'INSTALL_APPLICATION', 'UNDO_ACTION')]
        [string]$Type = 'MODIFY_SETTINGS'
    )
    
    try {
        Assert-AdminRights
        
        Write-WinPurgeInfo "Creating system restore point: $Description" -Category 'RestorePoint'
        
        # Check if System Restore is enabled
        $restoreStatus = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        if (-not $restoreStatus) {
            Write-WinPurgeWarning "System Restore appears to be disabled" -Category 'RestorePoint'
            return $false
        }
        
        # Create restore point using WMI
        $restorePoint = New-Object -ComObject 'System.Restore.RestorePoint'
        $restorePoint.CreateRestorePoint($Description, 0, [System.Restore.RestoreEventType]::$Type)
        
        Write-WinPurgeSuccess "Restore point created successfully" -Category 'RestorePoint'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to create restore point: $_" -Category 'RestorePoint'
        return $false
    }
}

<#
.DESCRIPTION
    Get latest restore points
#>
function Get-WinPurgeRestorePoints {
    param(
        [int]$Count = 10
    )
    
    try {
        $points = Get-ComputerRestorePoint -ErrorAction Stop | Sort-Object -Property CreationTime -Descending | Select-Object -First $Count
        return $points
    }
    catch {
        Write-WinPurgeError "Failed to retrieve restore points: $_" -Category 'RestorePoint'
        return @()
    }
}

<#
.DESCRIPTION
    Restore system to a specific restore point
#>
function Restore-WinPurgePoint {
    param(
        [Parameter(Mandatory = $true)]
        [int]$SequenceNumber,
        
        [switch]$Force
    )
    
    try {
        Assert-AdminRights
        
        if (-not $Force) {
            Write-WinPurgeWarning "System restore will restart your computer" -Category 'RestorePoint'
            Write-WinPurgeInfo "Use -Force to proceed without confirmation" -Category 'RestorePoint'
            return $false
        }
        
        Write-WinPurgeInfo "Initiating system restore to point $SequenceNumber" -Category 'RestorePoint'
        
        # This requires admin and will restart
        $rp = Get-ComputerRestorePoint -SequenceNumber $SequenceNumber -ErrorAction Stop
        Restore-Computer -RestorePoint $SequenceNumber -Confirm:$false
        
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to restore system: $_" -Category 'RestorePoint'
        return $false
    }
}

<#
.DESCRIPTION
    Enable system restore if disabled
#>
function Enable-WinPurgeRestorePoint {
    param(
        [string]$Drive = 'C:'
    )
    
    try {
        Assert-AdminRights
        
        Write-WinPurgeInfo "Enabling System Restore on $Drive" -Category 'RestorePoint'
        
        # Enable restore point via COM object
        $restorePoint = New-Object -ComObject 'System.Restore.RestorePoint'
        $restorePoint.EnableRestore($Drive)
        
        Write-WinPurgeSuccess "System Restore enabled on $Drive" -Category 'RestorePoint'
        return $true
    }
    catch {
        Write-WinPurgeWarning "Could not enable System Restore: $_" -Category 'RestorePoint'
        return $false
    }
}

<#
.DESCRIPTION
    Check if System Restore is enabled
#>
function Test-RestorePointEnabled {
    param(
        [string]$Drive = 'C:'
    )
    
    try {
        $points = Get-ComputerRestorePoint -ErrorAction Stop
        return $points.Count -gt 0
    }
    catch {
        return $false
    }
}

Export-ModuleMember -Function @(
    'New-WinPurgeRestorePoint',
    'Get-WinPurgeRestorePoints',
    'Restore-WinPurgePoint',
    'Enable-WinPurgeRestorePoint',
    'Test-RestorePointEnabled'
)
