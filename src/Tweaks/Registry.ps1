<#
.SYNOPSIS
    Advanced registry tweaks for optimization
    
.DESCRIPTION
    Applies safe registry modifications to improve performance,
    responsiveness, and system behavior.
#>

<#
.DESCRIPTION
    Apply context menu tweaks
#>
function Apply-ContextMenuTweaks {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Applying Context Menu Tweaks"
    
    # Hide 'Send to' submenu items
    $contextMenuRegs = @(
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowSuperHidden'; Value = 1 }
    )
    
    foreach ($reg in $contextMenuRegs) {
        Set-DryRunRegistry -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type DWORD
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Context menu tweaks applied" -Category 'Registry'
    }
}

<#
.DESCRIPTION
    Optimize visual effects
#>
function Optimize-VisualEffects {
    param(
        [ValidateSet('Best Performance', 'Balanced', 'Best Appearance')]
        [string]$Mode = 'Best Performance',
        
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Optimizing Visual Effects"
    
    if ($Mode -eq 'Best Performance') {
        Set-DryRunRegistry -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
            -Name 'TaskbarAnimations' -Value 0 -Type DWORD
        
        Set-DryRunRegistry -Path 'HKCU:\Control Panel\Desktop' `
            -Name 'UserPreferencesMask' -Value ([byte[]](144, 18, 3, 128)) -Type Binary
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Visual effects optimized ($Mode mode)" -Category 'Registry'
    }
}

Export-ModuleMember -Function @(
    'Apply-ContextMenuTweaks',
    'Optimize-VisualEffects'
)
