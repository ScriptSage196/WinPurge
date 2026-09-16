<#
.SYNOPSIS
    Performance benchmarking for WinPurge changes
    
.DESCRIPTION
    Measures before/after system performance:
    - RAM usage
    - Process count
    - Disk usage
    - Boot time
    - CPU metrics
#>

<#
.DESCRIPTION
    Get current system benchmark snapshot
#>
function Get-SystemBenchmark {
    param(
        [string]$Label = "Benchmark"
    )
    
    try {
        $timestamp = Get-Date
        
        # Memory info
        $memInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $totalMem = [math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 2)
        $freeMem = [math]::Round($memInfo.FreePhysicalMemory / 1MB, 2)
        $usedMem = $totalMem - $freeMem
        
        # Process count
        $processCount = (Get-Process -ErrorAction SilentlyContinue).Count
        
        # Disk usage (C: drive)
        $diskInfo = Get-PSDrive -Name C -ErrorAction SilentlyContinue
        $diskUsed = if ($diskInfo) { [math]::Round(($diskInfo.Used / 1GB), 2) } else { 0 }
        $diskFree = if ($diskInfo) { [math]::Round(($diskInfo.Free / 1GB), 2) } else { 0 }
        
        # Services count
        $serviceCount = (Get-Service -ErrorAction SilentlyContinue).Count
        $runningServices = (Get-Service | Where-Object { $_.Status -eq 'Running' }).Count
        
        # Startup programs
        $startupCount = (Get-CimInstance -ClassName Win32_StartupCommand -ErrorAction SilentlyContinue).Count
        
        $benchmark = @{
            Timestamp        = $timestamp
            Label            = $Label
            TotalMemoryGB    = $totalMem
            UsedMemoryGB     = $usedMem
            FreeMemoryGB     = $freeMem
            ProcessCount     = $processCount
            ServiceCount     = $serviceCount
            RunningServices  = $runningServices
            DiskUsedGB       = $diskUsed
            DiskFreeGB       = $diskFree
            StartupPrograms  = $startupCount
        }
        
        Write-WinPurgeDebug "Benchmark captured: $Label" -Category 'Benchmark'
        return $benchmark
    }
    catch {
        Write-WinPurgeError "Failed to capture benchmark: $_" -Category 'Benchmark'
        return $null
    }
}

<#
.DESCRIPTION
    Compare two benchmark snapshots
#>
function Compare-Benchmarks {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Before,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$After
    )
    
    $comparison = @{
        Timestamp            = Get-Date
        BeforeLabel          = $Before.Label
        AfterLabel           = $After.Label
        MemorySavedGB        = [math]::Round($Before.UsedMemoryGB - $After.UsedMemoryGB, 2)
        ProcessesRemoved     = $Before.ProcessCount - $After.ProcessCount
        ServicesRemoved      = $Before.ServiceCount - $After.ServiceCount
        RunningServicesReduced = $Before.RunningServices - $After.RunningServices
        DiskSpaceFreedGB     = [math]::Round($After.DiskFreeGB - $Before.DiskFreeGB, 2)
        StartupProgramsRemoved = $Before.StartupPrograms - $After.StartupPrograms
    }
    
    return $comparison
}

<#
.DESCRIPTION
    Display benchmark comparison in formatted table
#>
function Show-BenchmarkComparison {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Before,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$After
    )
    
    $comparison = Compare-Benchmarks -Before $Before -After $After
    
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         PERFORMANCE BENCHMARK COMPARISON           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    $metrics = @(
        @{ Label = "Memory Freed";           Value = "$($comparison.MemorySavedGB) GB";                Color = if ($comparison.MemorySavedGB -gt 0) { 'Green' } else { 'Yellow' } },
        @{ Label = "Processes Removed";      Value = $comparison.ProcessesRemoved;                    Color = if ($comparison.ProcessesRemoved -gt 0) { 'Green' } else { 'Gray' } },
        @{ Label = "Services Removed";       Value = $comparison.ServicesRemoved;                    Color = if ($comparison.ServicesRemoved -gt 0) { 'Green' } else { 'Gray' } },
        @{ Label = "Running Services Cut";   Value = $comparison.RunningServicesReduced;              Color = if ($comparison.RunningServicesReduced -gt 0) { 'Green' } else { 'Gray' } },
        @{ Label = "Disk Space Freed";       Value = "$($comparison.DiskSpaceFreedGB) GB";          Color = if ($comparison.DiskSpaceFreedGB -gt 0) { 'Green' } else { 'Gray' } },
        @{ Label = "Startup Programs Removed"; Value = $comparison.StartupProgramsRemoved;            Color = if ($comparison.StartupProgramsRemoved -gt 0) { 'Green' } else { 'Gray' } }
    )
    
    foreach ($metric in $metrics) {
        Write-Host "  $($metric.Label):".PadRight(30) -ForegroundColor White -NoNewline
        Write-Host " $($metric.Value)" -ForegroundColor $metric.Color
    }
    
    Write-Host "`n" -ForegroundColor Cyan
}

<#
.DESCRIPTION
    Export benchmark data to CSV
#>
function Export-BenchmarkData {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable[]]$Benchmarks,
        
        [string]$Path = (Join-Path $env:TEMP "WinPurge_benchmarks.csv")
    )
    
    try {
        $Benchmarks | ConvertTo-Csv -NoTypeInformation | Out-File -Path $Path -Encoding UTF8 -Force
        Write-WinPurgeSuccess "Benchmark data exported to: $Path" -Category 'Benchmark'
        return $Path
    }
    catch {
        Write-WinPurgeError "Failed to export benchmark data: $_" -Category 'Benchmark'
        return $null
    }
}

Export-ModuleMember -Function @(
    'Get-SystemBenchmark',
    'Compare-Benchmarks',
    'Show-BenchmarkComparison',
    'Export-BenchmarkData'
)
