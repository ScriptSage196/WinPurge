<#
.SYNOPSIS
    Advanced system utilities and tweaks
    
.DESCRIPTION
    Collection of specialized system utilities for power users:
    - Memory optimization
    - Process management
    - Disk cleanup
    - Temp file removal
    - Event log clearing
#>

<#
.DESCRIPTION
    Clear temporary files and caches
#>
function Clear-TemporaryFiles {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet,
        [switch]$AggressiveCleanup
    )
    
    Write-WinPurgeSectionHeader "Clearing Temporary Files"
    
    $paths = @(
        "$env:TEMP",
        "$env:WINDIR\Temp",
        "$env:LOCALAPPDATA\Temp"
    )
    
    if ($AggressiveCleanup) {
        $paths += @(
            "$env:ProgramData\Temp",
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
        )
    }
    
    $freedBytes = 0
    $itemsRemoved = 0
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            try {
                $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                
                foreach ($item in $items) {
                    try {
                        $freedBytes += $item.Length
                        
                        if (-not $DryRun) {
                            Remove-Item -Path $item.FullName -Force -ErrorAction SilentlyContinue
                            $itemsRemoved++
                        }
                    }
                    catch {
                        Write-WinPurgeDebug "Could not remove: $($item.FullName)" -Category 'Cleanup'
                    }
                }
            }
            catch {
                Write-WinPurgeWarning "Failed to access: $path" -Category 'Cleanup'
            }
        }
    }
    
    $freedGB = [math]::Round($freedBytes / 1GB, 2)
    
    Add-AuditLogEntry -Category 'Cleanup' -Target 'Temp Files' `
        -OldValue "$itemsRemoved items" -NewValue "Cleared" `
        -Command 'Clear-TemporaryFiles' `
        -Reversible $false -Success $true
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Freed $freedGB GB ($itemsRemoved items removed)" -Category 'Cleanup'
    }
    
    return @{
        ItemsRemoved = $itemsRemoved
        BytesFreed   = $freedBytes
        GBFreed      = $freedGB
    }
}

<#
.DESCRIPTION
    Clear Windows Event Logs
#>
function Clear-EventLogs {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Clearing Event Logs"
    
    Assert-AdminRights
    
    $logs = @('System', 'Application', 'Security')
    $clearedCount = 0
    
    foreach ($log in $logs) {
        try {
            if ($DryRun) {
                Write-WinPurgeWarning "[DRY-RUN] Would clear: $log" -Category 'EventLog'
            }
            else {
                Clear-EventLog -LogName $log -ErrorAction Stop
                $clearedCount++
                Write-WinPurgeSuccess "Cleared: $log" -Category 'EventLog'
            }
        }
        catch {
            Write-WinPurgeWarning "Could not clear $log : $_" -Category 'EventLog'
        }
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Event logs cleared ($clearedCount)" -Category 'EventLog'
    }
}

<#
.DESCRIPTION
    Optimize disk space and NTFS compression
#>
function Optimize-DiskSpace {
    param(
        [string]$Drive = 'C:',
        [switch]$CompressFiles,
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Optimizing Disk Space"
    
    try {
        # Get free space before
        $diskInfoBefore = Get-PSDrive -Name $Drive[0] -ErrorAction Stop
        $freeBefore = $diskInfoBefore.Free / 1GB
        
        Write-WinPurgeInfo "Free space before: $([math]::Round($freeBefore, 2)) GB" -Category 'DiskOptimization'
        
        if ($CompressFiles) {
            if (-not $DryRun) {
                # Compress old files
                $compressDir = "$Drive\Windows\Temp"
                if (Test-Path $compressDir) {
                    & compact /c /s:$compressDir /i /f /q
                    Write-WinPurgeSuccess "Compressed files on $Drive" -Category 'DiskOptimization'
                }
            }
        }
        
        # Get free space after
        $diskInfoAfter = Get-PSDrive -Name $Drive[0] -ErrorAction Stop
        $freeAfter = $diskInfoAfter.Free / 1GB
        $freed = $freeAfter - $freeBefore
        
        Write-WinPurgeInfo "Free space after: $([math]::Round($freeAfter, 2)) GB" -Category 'DiskOptimization'
        Write-WinPurgeSuccess "Freed: $([math]::Round($freed, 2)) GB" -Category 'DiskOptimization'
    }
    catch {
        Write-WinPurgeError "Disk optimization failed: $_" -Category 'DiskOptimization'
    }
}

<#
.DESCRIPTION
    Get system resource usage statistics
#>
function Get-SystemResourceUsage {
    try {
        $cpu = Get-WmiObject -Class Win32_Processor -ErrorAction Stop
        $memory = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
        $disk = Get-PSDrive -Name C -ErrorAction Stop
        
        $totalMem = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
        $usedMem = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)
        $freeMem = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
        
        return @{
            CPUCores         = $cpu.NumberOfCores
            CPULogicalProcs  = $cpu.NumberOfLogicalProcessors
            TotalMemoryGB    = $totalMem
            UsedMemoryGB     = $usedMem
            FreeMemoryGB     = $freeMem
            MemoryUsagePercent = [math]::Round(($usedMem / $totalMem) * 100, 2)
            DiskUsedGB       = [math]::Round($disk.Used / 1GB, 2)
            DiskFreeGB       = [math]::Round($disk.Free / 1GB, 2)
            DiskUsagePercent = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 2)
            ProcessCount     = (Get-Process -ErrorAction SilentlyContinue).Count
        }
    }
    catch {
        Write-WinPurgeError "Failed to get resource usage: $_" -Category 'System'
        return $null
    }
}

<#
.DESCRIPTION
    Display system resource usage in formatted table
#>
function Show-ResourceUsage {
    $usage = Get-SystemResourceUsage
    
    if (-not $usage) { return }
    
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "╔═══════════════════════════════════════════╔" -ForegroundColor Cyan
    Write-Host "║           SYSTEM RESOURCE USAGE                    ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    
    Write-Host "  CPU Cores:".PadRight(30) -NoNewline; Write-Host " $($usage.CPUCores) physical, $($usage.CPULogicalProcs) logical" -ForegroundColor White
    Write-Host "  Memory:".PadRight(30) -NoNewline; Write-Host " $($usage.UsedMemoryGB) GB / $($usage.TotalMemoryGB) GB ($($usage.MemoryUsagePercent)%)" -ForegroundColor $(if ($usage.MemoryUsagePercent -gt 80) { 'Red' } else { 'Green' })
    Write-Host "  Disk Space:".PadRight(30) -NoNewline; Write-Host " $($usage.DiskUsedGB) GB / $([math]::Round($usage.DiskUsedGB + $usage.DiskFreeGB, 2)) GB ($($usage.DiskUsagePercent)%)" -ForegroundColor $(if ($usage.DiskUsagePercent -gt 90) { 'Red' } else { 'Green' })
    Write-Host "  Running Processes:".PadRight(30) -NoNewline; Write-Host " $($usage.ProcessCount)" -ForegroundColor White
    
    Write-Host "`n" -ForegroundColor Cyan
}

Export-ModuleMember -Function @(
    'Clear-TemporaryFiles',
    'Clear-EventLogs',
    'Optimize-DiskSpace',
    'Get-SystemResourceUsage',
    'Show-ResourceUsage'
)
