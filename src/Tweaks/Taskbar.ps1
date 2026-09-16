<#
.SYNOPSIS
    Taskbar customization and tweaks
    
.DESCRIPTION
    Customizes taskbar appearance, search functionality,
    and widget settings.
#>

<#
.DESCRIPTION
    Hide search box from taskbar
#>
function Hide-TaskbarSearch {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Hiding Taskbar Search"
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
        -Name 'SearchboxTaskbarMode' -Value 0 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Taskbar search hidden" -Category 'Taskbar'
    }
}

<#
.DESCRIPTION
    Hide task view button from taskbar
#>
function Hide-TaskViewButton {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Hiding Task View Button"
    
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
        -Name 'ShowTaskViewButton' -Value 0 -Type DWORD
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Task view button hidden" -Category 'Taskbar'
    }
}

Export-ModuleMember -Function @(
    'Hide-TaskbarSearch',
    'Hide-TaskViewButton'
)
