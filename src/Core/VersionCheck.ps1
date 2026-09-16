<#
.SYNOPSIS
    OS version and compatibility checking for WinPurge
    
.DESCRIPTION
    Verifies system meets minimum requirements:
    - Windows 10 22H2 or later
    - Windows 11 23H2 or later
    - PowerShell 7.0 or later
#>

<#
.DESCRIPTION
    Test if OS is compatible with WinPurge
#>
function Test-OSCompatibility {
    $osVersion = [System.Environment]::OSVersion.Version
    $major = $osVersion.Major
    $minor = $osVersion.Minor
    $build = $osVersion.Build
    
    Write-WinPurgeDebug "OS Version: $major.$minor.$build" -Category 'VersionCheck'
    
    # Windows 11 (build 22000+)
    if ($major -eq 10 -and $build -ge 22000) {
        # Windows 11 - require 23H2+ (build 23000+)
        if ($build -ge 23000) {
            Write-WinPurgeSuccess "Windows 11 23H2+ detected (Build $build)" -Category 'VersionCheck'
            return $true
        }
        else {
            Write-WinPurgeWarning "Windows 11 version too old. Requires 23H2+ (Build $build)" -Category 'VersionCheck'
            return $false
        }
    }
    
    # Windows 10 (build 19000-21999)
    if ($major -eq 10 -and $build -ge 19000 -and $build -lt 22000) {
        # Windows 10 - require 22H2 (build 19045+)
        if ($build -ge 19045) {
            Write-WinPurgeSuccess "Windows 10 22H2 detected (Build $build)" -Category 'VersionCheck'
            return $true
        }
        else {
            Write-WinPurgeWarning "Windows 10 version too old. Requires 22H2 (Build $build)" -Category 'VersionCheck'
            return $false
        }
    }
    
    # Unsupported
    Write-WinPurgeError "Unsupported OS version: $major.$minor Build $build" -Category 'VersionCheck'
    return $false
}

<#
.DESCRIPTION
    Get detailed OS information
#>
function Get-OSInfo {
    try {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        
        return @{
            Name              = $osInfo.Caption
            Version           = $osInfo.Version
            Build             = $osInfo.BuildNumber
            Architecture      = $osInfo.OSArchitecture
            InstallDate       = $osInfo.InstallDate
            LastBootUpTime    = $osInfo.LastBootUpTime
            SystemDriveSize   = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
            FreeSpace         = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
        }
    }
    catch {
        Write-WinPurgeError "Failed to get OS info: $_" -Category 'VersionCheck'
        return $null
    }
}

<#
.DESCRIPTION
    Check PowerShell version compatibility
#>
function Test-PowerShellCompatibility {
    $psVersion = $PSVersionTable.PSVersion
    
    if ($psVersion.Major -lt 7) {
        Write-WinPurgeWarning "PowerShell 7+ required. Current: $psVersion" -Category 'VersionCheck'
        return $false
    }
    
    Write-WinPurgeSuccess "PowerShell $psVersion is compatible" -Category 'VersionCheck'
    return $true
}

<#
.DESCRIPTION
    Check for latest WinPurge version online (requires internet)
#>
function Test-LatestVersion {
    param(
        [string]$CurrentVersion = "2.0"
    )
    
    try {
        $latest = Invoke-RestMethod -Uri "https://api.github.com/repos/ScriptSage196/WinPurge/releases/latest" -TimeoutSec 5 -ErrorAction Stop
        $latestVersion = $latest.tag_name -replace 'v', ''
        
        if ([version]$latestVersion -gt [version]$CurrentVersion) {
            Write-WinPurgeWarning "Newer version available: $latestVersion (Current: $CurrentVersion)" -Category 'VersionCheck'
            Write-WinPurgeInfo "Download from: $($latest.html_url)" -Category 'VersionCheck'
            return $false
        }
        
        Write-WinPurgeSuccess "Running latest version: $CurrentVersion" -Category 'VersionCheck'
        return $true
    }
    catch {
        Write-WinPurgeDebug "Could not check for updates (offline?): $_" -Category 'VersionCheck'
        return $null
    }
}

<#
.DESCRIPTION
    Get Windows Update status
#>
function Get-WindowsUpdateStatus {
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0")
        
        return @{
            TotalAvailable = $searchResult.Updates.Count
            Critical       = ($searchResult.Updates | Where-Object { $_.MsrcSeverity -eq 'Critical' }).Count
            Important      = ($searchResult.Updates | Where-Object { $_.MsrcSeverity -eq 'Important' }).Count
            Updates        = $searchResult.Updates
        }
    }
    catch {
        Write-WinPurgeError "Failed to check updates: $_" -Category 'VersionCheck'
        return $null
    }
}

Export-ModuleMember -Function @(
    'Test-OSCompatibility',
    'Get-OSInfo',
    'Test-PowerShellCompatibility',
    'Test-LatestVersion',
    'Get-WindowsUpdateStatus'
)
