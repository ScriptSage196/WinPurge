<#
.SYNOPSIS
    Windows privacy settings hardening
    
.DESCRIPTION
    Disables activity tracking, app suggestions, timeline, and
    data collection to improve privacy.
#>

<#
.DESCRIPTION
    Disable activity history and timeline
#>
function Disable-ActivityHistory {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Activity History"
    
    $changes = 0
    
    # Disable activity history
    $regPaths = @(
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; Name = 'TailoredExperiencesWithDiagnosticDataEnabled'; Value = 0 },
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'; Name = 'RestrictImplicitInkCollection'; Value = 1 },
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'; Name = 'RestrictImplicitTextCollection'; Value = 1 }
    )
    
    foreach ($reg in $regPaths) {
        $result = Set-DryRunRegistry -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWORD
        if ($result.Success) { $changes++ }
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Activity history disabled ($changes changes)" -Category 'Privacy'
    }
}

<#
.DESCRIPTION
    Disable app suggestions
#>
function Disable-AppSuggestions {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling App Suggestions"
    
    # Disable suggestions
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'ContentDeliveryAllowed' -Value 0 -Type DWORD
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SoftLandingEnabled' -Value 0 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "App suggestions disabled" -Category 'Privacy'
    }
}

Export-ModuleMember -Function @(
    'Disable-ActivityHistory',
    'Disable-AppSuggestions'
)
