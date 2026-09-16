<#
.SYNOPSIS
    Windows telemetry and data collection removal
    
.DESCRIPTION
    Disables Windows telemetry, diagnostic data, activity history,
    and cloud data sync. Includes undo functions for all changes.
#>

<#
.DESCRIPTION
    Disable Windows telemetry services
#>
function Disable-Telemetry {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Verbose = $Script:VerboseMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Telemetry"
    
    $changes = @()
    
    # Telemetry services to disable
    $telemetryServices = @(
        'DiagTrack',              # Diagnostic Tracking Service
        'dmwappushservice',       # dmwappushservice
        'ServicesTelemetry',      # Connected User Experiences and Telemetry
        'ScheduledInstallation'   # Scheduled
    )
    
    foreach ($service in $telemetryServices) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            $result = Set-DryRunService -ServiceName $service -State 'Disabled'
            $changes += $result
            
            Add-AuditLogEntry -Category 'Telemetry' -Target $service `
                -OldValue "$($svc.StartType)" -NewValue 'Disabled' `
                -Command "Set-Service -Name $service -StartupType Disabled" `
                -Reversible $true -Success $result.Success
        }
    }
    
    # Disable telemetry via registry
    $telemetryRegs = @(
        @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowDiagnosticData'; Value = 0 },
        @{ Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'AllowDiagnosticData'; Value = 0 },
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; Name = 'TailoredExperiencesWithDiagnosticDataEnabled'; Value = 0 }
    )
    
    foreach ($reg in $telemetryRegs) {
        $result = Set-DryRunRegistry -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWORD
        $changes += $result
        
        Add-AuditLogEntry -Category 'Telemetry' -Target "$($reg.Path)\$($reg.Name)" `
            -OldValue $null -NewValue $reg.Value `
            -Command "Set-ItemProperty -Path '$($reg.Path)' -Name '$($reg.Name)' -Value $($reg.Value)" `
            -Reversible $true -Success $result.Success
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Telemetry disabled ($($changes.Count) changes)" -Category 'Telemetry'
    }
    
    return $changes
}

<#
.DESCRIPTION
    Undo telemetry disabling
#>
function Undo-Telemetry {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Undoing Telemetry Changes"
    
    # Re-enable services
    $telemetryServices = @('DiagTrack', 'dmwappushservice')
    
    foreach ($service in $telemetryServices) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            Set-DryRunService -ServiceName $service -State 'Running'
        }
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Telemetry changes reverted" -Category 'Telemetry'
    }
}

Export-ModuleMember -Function @(
    'Disable-Telemetry',
    'Undo-Telemetry'
)
