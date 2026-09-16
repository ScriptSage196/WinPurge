<#
.SYNOPSIS
    WinGet integration for package management
    
.DESCRIPTION
    Wrapper functions for WinGet to install, update, and manage packages.
    Supports batch installation from JSON configuration files.
#>

<#
.DESCRIPTION
    Check if WinGet is installed and available
#>
function Test-WinGetAvailable {
    try {
        $winget = Get-Command winget -ErrorAction Stop
        Write-WinPurgeSuccess "WinGet available: $($winget.Source)" -Category 'WinGet'
        return $true
    }
    catch {
        Write-WinPurgeWarning "WinGet not found. Install from Microsoft Store." -Category 'WinGet'
        return $false
    }
}

<#
.DESCRIPTION
    Install package via WinGet
#>
function Install-PackageViaWinGet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        
        [switch]$Silent,
        [switch]$DryRun = $Script:DryRunMode
    )
    
    if (-not (Test-WinGetAvailable)) {
        Write-WinPurgeError "WinGet not available" -Category 'WinGet'
        return $false
    }
    
    $args = @('install', $PackageName, '--accept-package-agreements', '--accept-source-agreements')
    
    if ($Silent) {
        $args += '--silent'
    }
    
    if ($DryRun) {
        Write-WinPurgeWarning "[DRY-RUN] Would install: $PackageName" -Category 'WinGet'
        return $true
    }
    
    try {
        Write-WinPurgeInfo "Installing: $PackageName" -Category 'WinGet'
        & winget @args
        Write-WinPurgeSuccess "Installed: $PackageName" -Category 'WinGet'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to install $PackageName : $_" -Category 'WinGet'
        return $false
    }
}

<#
.DESCRIPTION
    Install multiple packages from JSON config
#>
function Install-PackagesFromJSON {
    param(
        [Parameter(Mandatory = $true)]
        [string]$JSONPath,
        
        [switch]$Silent,
        [switch]$DryRun = $Script:DryRunMode
    )
    
    if (-not (Test-Path $JSONPath)) {
        Write-WinPurgeError "JSON file not found: $JSONPath" -Category 'WinGet'
        return $false
    }
    
    try {
        $packages = Get-Content $JSONPath | ConvertFrom-Json
        $installed = 0
        
        foreach ($package in $packages.packages) {
            $result = Install-PackageViaWinGet -PackageName $package.name -Silent:$Silent -DryRun:$DryRun
            if ($result) { $installed++ }
        }
        
        Write-WinPurgeSuccess "Installed $installed packages from $JSONPath" -Category 'WinGet'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to process packages: $_" -Category 'WinGet'
        return $false
    }
}

<#
.DESCRIPTION
    List installed packages
#>
function Get-InstalledPackages {
    if (-not (Test-WinGetAvailable)) {
        return @()
    }
    
    try {
        $packages = & winget list --output json | ConvertFrom-Json
        return $packages
    }
    catch {
        Write-WinPurgeError "Failed to list packages: $_" -Category 'WinGet'
        return @()
    }
}

Export-ModuleMember -Function @(
    'Test-WinGetAvailable',
    'Install-PackageViaWinGet',
    'Install-PackagesFromJSON',
    'Get-InstalledPackages'
)
