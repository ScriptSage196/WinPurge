<#
.SYNOPSIS
    Performance monitoring and reporting
    
.DESCRIPTION
    Real-time performance monitoring and detailed reporting:
    - CPU usage tracking
    - Memory monitoring
    - Disk I/O statistics
    - Network monitoring
    - Process profiling
#>

<#
.DESCRIPTION
    Get detailed CPU information and usage
#>
function Get-CPUInfo {
    try {
        $cpu = Get-WmiObject -Class Win32_Processor -ErrorAction Stop
        $perfCounter = Get-Counter -Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue
        
        return @{
            Manufacturer       = $cpu.Manufacturer
            Model              = $cpu.Name
            Cores              = $cpu.NumberOfCores
            LogicalProcessors  = $cpu.NumberOfLogicalProcessors
            MaxClockSpeed      = $cpu.MaxClockSpeed
            CurrentUsagePercent = if ($perfCounter) { [math]::Round($perfCounter.CounterSamples[0].CookedValue, 2) } else { 'N/A' }
            Architecture       = $cpu.Architecture
        }
    }
    catch {
        Write-WinPurgeError "Failed to get CPU info: $_" -Category 'Performance'
        return $null
    }
}

<#
.DESCRIPTION
    Get memory and RAM information
#>
function Get-MemoryInfo {
    try {
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
        $totalMem = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
        $freeMem = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
        $usedMem = $totalMem - $freeMem
        $usagePercent = [math]::Round(($usedMem / $totalMem) * 100, 2)
        
        return @{
            TotalGB        = $totalMem
            UsedGB         = $usedMem
            FreeGB         = $freeMem
            UsagePercent   = $usagePercent
            AvailableGB    = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
        }
    }
    catch {
        Write-WinPurgeError "Failed to get memory info: $_" -Category 'Performance'
        return $null
    }
}

<#
.DESCRIPTION
    Get disk information and usage
#>
function Get-DiskInfo {
    param(
        [string]$Drive = 'C:'
    )
    
    try {
        $diskInfo = Get-PSDrive -Name $Drive[0] -ErrorAction Stop
        $totalGB = [math]::Round(($diskInfo.Used + $diskInfo.Free) / 1GB, 2)
        $usedGB = [math]::Round($diskInfo.Used / 1GB, 2)
        $freeGB = [math]::Round($diskInfo.Free / 1GB, 2)
        $usagePercent = [math]::Round(($usedGB / $totalGB) * 100, 2)
        
        return @{
            Drive           = $Drive
            TotalGB         = $totalGB
            UsedGB          = $usedGB
            FreeGB          = $freeGB
            UsagePercent    = $usagePercent
            HealthStatus    = if ($usagePercent -gt 90) { 'Critical' } elseif ($usagePercent -gt 75) { 'Warning' } else { 'Healthy' }
        }
    }
    catch {
        Write-WinPurgeError "Failed to get disk info: $_" -Category 'Performance'
        return $null
    }
}

<#
.DESCRIPTION
    Get top processes by memory usage
#>
function Get-TopProcessesByMemory {
    param(
        [int]$Count = 10
    )
    
    try {
        $processes = Get-Process -ErrorAction Stop | 
            Select-Object Name, WorkingSet, @{Name='MemoryMB'; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} |
            Sort-Object MemoryMB -Descending |
            Select-Object -First $Count
        
        return $processes
    }
    catch {
        Write-WinPurgeError "Failed to get process list: $_" -Category 'Performance'
        return @()
    }
}

<#
.DESCRIPTION
    Get top processes by CPU usage
#>
function Get-TopProcessesByCPU {
    param(
        [int]$Count = 10
    )
    
    try {
        # Note: CPU percentage requires sampling
        $processes = Get-Process -ErrorAction Stop | 
            Select-Object Name, CPU |
            Sort-Object CPU -Descending -ErrorAction SilentlyContinue |
            Select-Object -First $Count
        
        return $processes
    }
    catch {
        Write-WinPurgeError "Failed to get CPU processes: $_" -Category 'Performance'
        return @()
    }
}

<#
.DESCRIPTION
    Display comprehensive performance report
#>
function Show-PerformanceReport {
    Write-WinPurgeSectionHeader "System Performance Report"
    
    # CPU Info
    Write-Host "`n[CPU Information]" -ForegroundColor Yellow
    $cpu = Get-CPUInfo
    if ($cpu) {
        Write-Host "  Model: $($cpu.Model)" -ForegroundColor White
        Write-Host "  Cores: $($cpu.Cores) physical, $($cpu.LogicalProcessors) logical" -ForegroundColor White
        Write-Host "  Max Speed: $($cpu.MaxClockSpeed) MHz" -ForegroundColor White
        if ($cpu.CurrentUsagePercent -ne 'N/A') {
            Write-Host "  Usage: $($cpu.CurrentUsagePercent)%" -ForegroundColor $(if ($cpu.CurrentUsagePercent -gt 80) { 'Red' } else { 'Green' })
        }
    }
    
    # Memory Info
    Write-Host "`n[Memory Information]" -ForegroundColor Yellow
    $mem = Get-MemoryInfo
    if ($mem) {
        Write-Host "  Total: $($mem.TotalGB) GB" -ForegroundColor White
        Write-Host "  Used: $($mem.UsedGB) GB ($($mem.UsagePercent)%)" -ForegroundColor $(if ($mem.UsagePercent -gt 80) { 'Red' } else { 'Green' })
        Write-Host "  Free: $($mem.FreeGB) GB" -ForegroundColor Green
    }
    
    # Disk Info
    Write-Host "`n[Disk Information]" -ForegroundColor Yellow
    $disk = Get-DiskInfo
    if ($disk) {
        Write-Host "  Drive: $($disk.Drive)" -ForegroundColor White
        Write-Host "  Total: $($disk.TotalGB) GB" -ForegroundColor White
        Write-Host "  Used: $($disk.UsedGB) GB ($($disk.UsagePercent)%)" -ForegroundColor $(if ($disk.UsagePercent -gt 90) { 'Red' } elseif ($disk.UsagePercent -gt 75) { 'Yellow' } else { 'Green' })
        Write-Host "  Free: $($disk.FreeGB) GB" -ForegroundColor Green
        Write-Host "  Status: $($disk.HealthStatus)" -ForegroundColor $(if ($disk.HealthStatus -eq 'Healthy') { 'Green' } else { 'Red' })
    }
    
    # Top Processes
    Write-Host "`n[Top 5 Processes by Memory]" -ForegroundColor Yellow
    $topMem = Get-TopProcessesByMemory -Count 5
    $counter = 1
    foreach ($proc in $topMem) {
        Write-Host "  $counter. $($proc.Name): $($proc.MemoryMB) MB" -ForegroundColor Cyan
        $counter++
    }
    
    Write-Host "`n" -ForegroundColor Cyan
}

Export-ModuleMember -Function @(
    'Get-CPUInfo',
    'Get-MemoryInfo',
    'Get-DiskInfo',
    'Get-TopProcessesByMemory',
    'Get-TopProcessesByCPU',
    'Show-PerformanceReport'
)
