<#
.SYNOPSIS
    Block automatic AI feature reinstallation
    
.DESCRIPTION
    Creates CBS (Component-Based Servicing) stubs and policies to prevent
    Windows from automatically reinstalling removed AI features after updates.
#>

<#
.DESCRIPTION
    Block AI components from CBS (Component-Based Servicing)
#>
function Block-AIReinstall {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Blocking AI Reinstallation"
    
    Assert-AdminRights
    
    # Create stub registry entries to block component reinstallation
    $aiComponents = @(
        'Microsoft-Windows-Copilot',
        'Microsoft-Windows-SearchEngine',
        'Windows-AI-Runtime'
    )
    
    foreach ($component in $aiComponents) {
        $result = Set-DryRunRegistry -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\$component" `
            -Name 'Installed' -Value 0 -Type DWORD
        
        Write-WinPurgeSuccess "Blocked reinstall: $component" -Category 'AI'
    }
    
    # Add to Features policy
    $result = Set-DryRunRegistry -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\FeatureManagement' `
        -Name 'BlockAIFeatures' -Value 1 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "AI reinstallation blocked" -Category 'AI'
    }
}

<#
.DESCRIPTION
    Check if AI components are blocked
#>
function Test-AIBlocked {
    try {
        $copilotBlock = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' `
            -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue
        
        return $copilotBlock.'TurnOffWindowsCopilot' -eq 1
    }
    catch {
        return $false
    }
}

<#
.DESCRIPTION
    Restore AI components (undo blocking)
#>
function Undo-AIBlock {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Unblocking AI Features"
    
    # Remove blocking policies
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' `
        -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue
    
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\FeatureManagement' `
        -Name 'BlockAIFeatures' -ErrorAction SilentlyContinue
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "AI feature blocks removed" -Category 'AI'
    }
}

Export-ModuleMember -Function @(
    'Block-AIReinstall',
    'Test-AIBlocked',
    'Undo-AIBlock'
)
