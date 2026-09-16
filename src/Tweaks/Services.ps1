<#
.SYNOPSIS
    Windows services optimization
    
.DESCRIPTION
    Disables unnecessary Windows services to reduce resource usage.
    Only disables services safe to disable. All changes are reversible.
#>

<#
.DESCRIPTION
    Disable unnecessary services
#>
function Disable-UnnecessaryServices {
    param(
        [string[]]$Preserve,
        [switch]$Aggressive,
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Disabling Unnecessary Services"
    
    $services = @(
        @{ Name = 'WSearch'; Display = 'Windows Search' },
        @{ Name = 'fhsvc'; Display = 'File History' },
        @{ Name = 'HomeGroupListener'; Display = 'HomeGroup Listener' },
        @{ Name = 'HomeGroupProvider'; Display = 'HomeGroup Provider' },
        @{ Name = 'lmhosts'; Display = 'TCP/IP NetBIOS Helper' },
        @{ Name = 'NetTcpPortSharing'; Display = 'Net.Tcp Port Sharing Service' },
        @{ Name = 'RemoteRegistry'; Display = 'Remote Registry' },
        @{ Name = 'SharedAccess'; Display = 'Internet Connection Sharing' },
        @{ Name = 'UmRdpService'; Display = 'Remote Desktop Services' }
    )
    
    if ($Aggressive) {
        $services += @(
            @{ Name = 'XblAuthManager'; Display = 'Xbox Live Auth Manager' },
            @{ Name = 'XblGameSave'; Display = 'Xbox Live Game Save Service' },
            @{ Name = 'XboxNetApiSvc'; Display = 'Xbox Live Networking Service' }
        )
    }
    
    $disabled = 0
    
    foreach ($svc in $services) {
        if ($Preserve -contains $svc.Name) {
            Write-WinPurgeInfo "Skipping (preserved): $($svc.Display)" -Category 'Services'
            continue
        }
        
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            $oldState = $service.StartType
            
            $result = Set-DryRunService -ServiceName $svc.Name -State 'Disabled'
            
            Add-AuditLogEntry -Category 'Services' -Target $svc.Name `
                -OldValue $oldState -NewValue 'Disabled' `
                -Command "Set-Service -Name '$($svc.Name)' -StartupType Disabled" `
                -Reversible $true -Success $result.Success
            
            Write-WinPurgeSuccess "Disabled: $($svc.Display)" -Category 'Services'
            $disabled++
        }
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Disabled $disabled services" -Category 'Services'
    }
    
    return $disabled
}

<#
.DESCRIPTION
    Get list of disabled services for review
#>
function Get-DisabledServices {
    try {
        $disabled = Get-Service | Where-Object { $_.StartType -eq 'Disabled' }
        return $disabled
    }
    catch {
        Write-WinPurgeError "Failed to get disabled services: $_" -Category 'Services'
        return @()
    }
}

Export-ModuleMember -Function @(
    'Disable-UnnecessaryServices',
    'Get-DisabledServices'
)
