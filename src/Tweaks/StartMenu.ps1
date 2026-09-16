<#
.SYNOPSIS
    Start Menu customization
    
.DESCRIPTION
    Removes app suggestions, recommendations, and customizes
    Start Menu appearance.
#>

<#
.DESCRIPTION
    Disable Start Menu suggestions
#>
function Disable-StartMenuSuggestions {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Start Menu Suggestions"
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'OemPreinstalledAppsEnabled' -Value 0 -Type DWORD
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'PreInstalledAppsEnabled' -Value 0 -Type DWORD
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Start Menu suggestions disabled" -Category 'StartMenu'
    }
}

Export-ModuleMember -Function @(
    'Disable-StartMenuSuggestions'
)
