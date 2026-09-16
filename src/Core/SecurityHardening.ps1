<#
.SYNOPSIS
    Security hardening and advanced tweaks
    
.DESCRIPTION
    Advanced security configurations:
    - Spectre/Meltdown mitigation
    - UAC elevation
    - Firewall management
    - BitLocker control
    - Windows Defender optimization
#>

<#
.DESCRIPTION
    Check Spectre and Meltdown vulnerability status
#>
function Get-VulnerabilityStatus {
    try {
        Write-WinPurgeSectionHeader "Checking Vulnerability Mitigations"
        
        $spectre = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' `
            -Name 'FeatureSettingsOverride' -ErrorAction SilentlyContinue
        
        $mitigations = @{
            SpectreMeltdownEnabled = if ($spectre.'FeatureSettingsOverride' -eq 0) { $true } else { $false }
            UAC                    = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' `
                -Name 'EnableLUA' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableLUA' -ErrorAction SilentlyContinue
        }
        
        Write-WinPurgeSuccess "Vulnerability check complete" -Category 'Security'
        return $mitigations
    }
    catch {
        Write-WinPurgeError "Failed to check vulnerability status: $_" -Category 'Security'
        return $null
    }
}

<#
.DESCRIPTION
    Enable Spectre/Meltdown mitigation
#>
function Enable-SpectreMitigation {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Enabling Spectre/Meltdown Mitigation"
    
    Assert-AdminRights
    
    try {
        if ($DryRun) {
            Write-WinPurgeWarning "[DRY-RUN] Would enable Spectre/Meltdown mitigations" -Category 'Security'
            return $true
        }
        
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' `
            -Name 'FeatureSettingsOverride' -Value 0 -Force
        
        Write-WinPurgeSuccess "Spectre/Meltdown mitigation enabled" -Category 'Security'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to enable Spectre mitigation: $_" -Category 'Security'
        return $false
    }
}

<#
.DESCRIPTION
    Disable Spectre/Meltdown mitigation (for performance, not recommended)
#>
function Disable-SpectreMitigation {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Spectre/Meltdown Mitigation"
    Write-WinPurgeWarning "WARNING: Disabling CPU mitigations reduces security!" -Category 'Security'
    
    Assert-AdminRights
    
    try {
        if ($DryRun) {
            Write-WinPurgeWarning "[DRY-RUN] Would disable Spectre/Meltdown mitigations (NOT RECOMMENDED)" -Category 'Security'
            return $true
        }
        
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' `
            -Name 'FeatureSettingsOverride' -Value 3 -Force
        
        Write-WinPurgeWarning "Spectre/Meltdown mitigation DISABLED (security reduced)" -Category 'Security'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to disable Spectre mitigation: $_" -Category 'Security'
        return $false
    }
}

<#
.DESCRIPTION
    Enable Windows Defender real-time protection
#>
function Enable-DefenderProtection {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Enabling Windows Defender Protection"
    
    Assert-AdminRights
    
    try {
        if (-not $DryRun) {
            # Re-enable Defender
            Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
            Start-Service -Name WinDefend -ErrorAction SilentlyContinue
        }
        
        Write-WinPurgeSuccess "Windows Defender protection enabled" -Category 'Security'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to enable Defender: $_" -Category 'Security'
        return $false
    }
}

<#
.DESCRIPTION
    Run Windows Defender quick scan
#>
function Start-DefenderQuickScan {
    param(
        [switch]$FullScan
    )
    
    Write-WinPurgeSectionHeader "Starting Windows Defender Scan"
    
    Assert-AdminRights
    
    try {
        if ($FullScan) {
            Write-WinPurgeInfo "Starting full scan (this may take a while)..." -Category 'Defender'
            Start-MpScan -ScanType FullScan -AsJob | Out-Null
        }
        else {
            Write-WinPurgeInfo "Starting quick scan..." -Category 'Defender'
            Start-MpScan -ScanType QuickScan -AsJob | Out-Null
        }
        
        Write-WinPurgeSuccess "Scan started in background" -Category 'Defender'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to start scan: $_" -Category 'Defender'
        return $false
    }
}

Export-ModuleMember -Function @(
    'Get-VulnerabilityStatus',
    'Enable-SpectreMitigation',
    'Disable-SpectreMitigation',
    'Enable-DefenderProtection',
    'Start-DefenderQuickScan'
)
