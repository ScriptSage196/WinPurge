<#
.SYNOPSIS
    DISM helper functions for ISO and feature management
    
.DESCRIPTION
    Provides functions to manage Windows features, DISM operations,
    and ISO customization.
#>

<#
.DESCRIPTION
    Get list of available Windows features
#>
function Get-WindowsFeatures {
    param(
        [ValidateSet('Enabled', 'Disabled', 'All')]
        [string]$State = 'All'
    )
    
    try {
        Assert-AdminRights
        
        $features = Get-WindowsOptionalFeature -Online -ErrorAction Stop
        
        if ($State -ne 'All') {
            $features = $features | Where-Object { $_.State -eq $State }
        }
        
        return $features
    }
    catch {
        Write-WinPurgeError "Failed to get features: $_" -Category 'DISM'
        return @()
    }
}

<#
.DESCRIPTION
    Enable Windows feature
#>
function Enable-WindowsFeature {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName,
        
        [switch]$DryRun = $Script:DryRunMode
    )
    
    Assert-AdminRights
    
    if ($DryRun) {
        Write-WinPurgeWarning "[DRY-RUN] Would enable feature: $FeatureName" -Category 'DISM'
        return $true
    }
    
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart -ErrorAction Stop
        Write-WinPurgeSuccess "Enabled feature: $FeatureName" -Category 'DISM'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to enable feature: $_" -Category 'DISM'
        return $false
    }
}

<#
.DESCRIPTION
    Disable Windows feature
#>
function Disable-WindowsFeature {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName,
        
        [switch]$DryRun = $Script:DryRunMode
    )
    
    Assert-AdminRights
    
    if ($DryRun) {
        Write-WinPurgeWarning "[DRY-RUN] Would disable feature: $FeatureName" -Category 'DISM'
        return $true
    }
    
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -ErrorAction Stop
        Write-WinPurgeSuccess "Disabled feature: $FeatureName" -Category 'DISM'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to disable feature: $_" -Category 'DISM'
        return $false
    }
}

Export-ModuleMember -Function @(
    'Get-WindowsFeatures',
    'Enable-WindowsFeature',
    'Disable-WindowsFeature'
)
