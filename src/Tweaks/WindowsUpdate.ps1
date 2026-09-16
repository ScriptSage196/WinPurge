<#
.SYNOPSIS
    Windows Update management and control
    
.DESCRIPTION
    Provides granular control over Windows Update behavior,
    including scheduled scans and automatic restarts.
#>

<#
.DESCRIPTION
    Disable automatic Windows Update restart
#>
function Disable-AutomaticRestart {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Automatic Restart"
    
    Set-DryRunRegistry -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' `
        -Name 'NoAutoRebootWithLoggedOnUsers' -Value 1 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Automatic Windows Update restart disabled" -Category 'WindowsUpdate'
    }
}

<#
.DESCRIPTION
    Set Windows Update pause duration
#>
function Set-UpdatePauseDuration {
    param(
        [ValidateRange(0, 35)]
        [int]$Days = 7,
        
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Setting Update Pause Duration"
    
    Write-WinPurgeInfo "Pausing Windows Updates for $Days days" -Category 'WindowsUpdate'
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Update pause configured for $Days days" -Category 'WindowsUpdate'
    }
}

Export-ModuleMember -Function @(
    'Disable-AutomaticRestart',
    'Set-UpdatePauseDuration'
)
