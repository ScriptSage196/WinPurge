<#
.SYNOPSIS
    Elevation and privilege management for WinPurge
    
.DESCRIPTION
    Handles admin rights verification, UAC prompts, and privilege escalation.
#>

<#
.DESCRIPTION
    Test if current process has administrator privileges
#>
function Test-AdminRights {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        Write-WinPurgeError "Failed to check admin rights: $_" -Category 'Elevation'
        return $false
    }
}

<#
.DESCRIPTION
    Get current user context
#>
function Get-CurrentUserContext {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        return @{
            Username = $identity.Name
            SID      = $identity.User.Value
            IsAdmin  = (Test-AdminRights)
        }
    }
    catch {
        Write-WinPurgeError "Failed to get user context: $_" -Category 'Elevation'
        return $null
    }
}

<#
.DESCRIPTION
    Request UAC elevation if not already running as admin
#>
function Request-Elevation {
    param(
        [string[]]$ArgumentList,
        [switch]$NoExit
    )
    
    if (Test-AdminRights) {
        Write-WinPurgeSuccess "Already running with admin privileges" -Category 'Elevation'
        return $true
    }
    
    Write-WinPurgeWarning "WinPurge requires administrator privileges" -Category 'Elevation'
    Write-WinPurgeInfo "Requesting elevation via UAC..." -Category 'Elevation'
    
    $psArgs = @(
        if ($NoExit) { '-NoExit' },
        '-ExecutionPolicy Bypass',
        "-File `"$($MyInvocation.ScriptName)`""
    )
    
    if ($ArgumentList) {
        $psArgs += $ArgumentList
    }
    
    try {
        Start-Process powershell -ArgumentList $psArgs -Verb RunAs -Wait
        return $true
    }
    catch {
        Write-WinPurgeError "Elevation request failed: $_" -Category 'Elevation'
        return $false
    }
}

<#
.DESCRIPTION
    Test if running in system (SYSTEM) context
#>
function Test-SystemContext {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return $identity.Name -eq 'NT AUTHORITY\SYSTEM'
}

<#
.DESCRIPTION
    Assert admin rights or throw error
#>
function Assert-AdminRights {
    if (-not (Test-AdminRights)) {
        throw "This operation requires administrator privileges. Please run WinPurge as administrator."
    }
}

Export-ModuleMember -Function @(
    'Test-AdminRights',
    'Get-CurrentUserContext',
    'Request-Elevation',
    'Test-SystemContext',
    'Assert-AdminRights'
)
