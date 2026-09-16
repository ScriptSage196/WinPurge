<#
.SYNOPSIS
    File Explorer customization and tweaks
    
.DESCRIPTION
    Configures File Explorer behavior, quick access, and UI settings.
#>

<#
.DESCRIPTION
    Customize File Explorer startup location
#>
function Set-FileExplorerStartup {
    param(
        [ValidateSet('ThisPC', 'QuickAccess', 'Home')]
        [string]$Location = 'ThisPC',
        
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Customizing File Explorer Startup"
    
    $values = @{
        'ThisPC'      = 1
        'QuickAccess' = 0
        'Home'        = 4
    }
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
        -Name 'LaunchTo' -Value $values[$Location] -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "File Explorer startup set to: $Location" -Category 'FileExplorer'
    }
}

<#
.DESCRIPTION
    Show hidden files in File Explorer
#>
function Show-HiddenFiles {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Showing Hidden Files"
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
        -Name 'Hidden' -Value 1 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Hidden files will now be visible" -Category 'FileExplorer'
    }
}

Export-ModuleMember -Function @(
    'Set-FileExplorerStartup',
    'Show-HiddenFiles'
)
