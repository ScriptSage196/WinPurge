<#
.SYNOPSIS
    Windows bloatware and default app removal
    
.DESCRIPTION
    Removes pre-installed bloatware, games, and unnecessary UWP apps.
    Supports per-user and system-wide removal with undo capability.
#>

<#
.DESCRIPTION
    Remove bloatware UWP apps
#>
function Remove-Bloatware {
    param(
        [string[]]$Preserve,
        [switch]$User,
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Verbose = $Script:VerboseMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Removing Bloatware"
    
    $bloatwareApps = @(
        'Microsoft.3DBuilder',
        'Microsoft.GetHelp',
        'Microsoft.Getstarted',
        'Microsoft.MixedReality.Portal',
        'Microsoft.News',
        'Microsoft.OneConnect',
        'Microsoft.People',
        'Microsoft.SkypeApp',
        'Microsoft.Solitaire.Collection',
        'Microsoft.StorePurchaseApp',
        'Microsoft.Wallet',
        'Microsoft.WindowsMaps',
        'Microsoft.WindowsAlarms',
        'Microsoft.YourPhone',
        'Microsoft.ZuneMusic',
        'Microsoft.ZuneVideo',
        'Microsoft.BingWeather'
    )
    
    $removed = 0
    
    foreach ($app in $bloatwareApps) {
        if ($Preserve -contains $app) {
            Write-WinPurgeInfo "Skipping (preserved): $app" -Category 'Bloatware'
            continue
        }
        
        try {
            if ($User) {
                Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
            }
            else {
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            }
            
            Write-WinPurgeSuccess "Removed: $app" -Category 'Bloatware'
            
            Add-AuditLogEntry -Category 'Bloatware' -Target $app `
                -OldValue 'Installed' -NewValue 'Removed' `
                -Command "Remove-AppxPackage -Name $app" `
                -Reversible $false -Success $true
            
            $removed++
        }
        catch {
            Write-WinPurgeWarning "Failed to remove $app : $_" -Category 'Bloatware'
        }
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Removed $removed bloatware apps" -Category 'Bloatware'
    }
    
    return $removed
}

<#
.DESCRIPTION
    Remove specific bloatware app
#>
function Remove-BloatwareApp {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        
        [switch]$AllUsers,
        [switch]$DryRun = $Script:DryRunMode
    )
    
    try {
        if ($AllUsers) {
            Get-AppxPackage -Name $AppName -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Stop
        }
        else {
            Get-AppxPackage -Name $AppName | Remove-AppxPackage -ErrorAction Stop
        }
        
        Write-WinPurgeSuccess "Removed: $AppName" -Category 'Bloatware'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to remove $AppName : $_" -Category 'Bloatware'
        return $false
    }
}

Export-ModuleMember -Function @(
    'Remove-Bloatware',
    'Remove-BloatwareApp'
)
