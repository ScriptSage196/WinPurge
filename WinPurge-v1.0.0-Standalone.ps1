#Requires -Version 7.0
<#
.SYNOPSIS
    WinPurge v1.0.0 - Advanced Windows Debloater/Tweaker (STANDALONE)
    
.DESCRIPTION
    Compiled standalone version with all modules included.
    This is a complete, self-contained distribution ready to use.
    
    All dependencies bundled into single executable script.
    No external files required.
    
.NOTES
    Generated: 2026-09-16
    License: MIT
    Repository: https://github.com/ScriptSage196/WinPurge

.PARAMETER GUI
    Launch the graphical user interface (default mode)

.PARAMETER Preset
    Specify a preset: Gaming, Minimal, Developer, Standard

.PARAMETER DryRun
    Preview changes without applying them

.PARAMETER Headless
    Run in command-line mode without GUI

.EXAMPLE
    .\\WinPurge-v1.0.0-Standalone.ps1 -GUI

.EXAMPLE
    .\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun

.EXAMPLE
    .\\WinPurge-v1.0.0-Standalone.ps1 -Preset Minimal
#>

param(
    [switch]$GUI = $true,
    [ValidateSet('Gaming', 'Minimal', 'Developer', 'Standard')]
    [string]$Preset,
    [switch]$DryRun,
    [switch]$Headless
)

# ============================================================================
# WinPurge v1.0.0 - CORE INITIALIZATION
# ============================================================================

$script:WinPurgeVersion = '1.0.0'
$script:WinPurgeDate = '2026-09-16'
$script:DryRunMode = $DryRun
$script:HeadlessMode = $Headless
$script:AuditLog = @()
$script:Config = @{
    LogPath = Join-Path $env:TEMP 'WinPurge_audit.json'
    RestorePointEnabled = $true
    PluginPath = Join-Path (Get-Location) 'plugins'
}

# ============================================================================
# ELEVATION CHECK
# ============================================================================
function Test-AdminPrivileges {
    $principal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-AdminPrivileges)) {
    Write-Host "⚠ WinPurge requires administrator privileges" -ForegroundColor Red
    Write-Host "Attempting to elevate..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$PSCommandPath $args`""
    exit
}

# ============================================================================
# LOGGING MODULE
# ============================================================================
function Write-LogEntry {
    param(
        [string]$Category,
        [string]$Target,
        [string]$Action,
        [string]$OldValue = 'N/A',
        [string]$NewValue = 'N/A',
        [bool]$Reversible = $true,
        [bool]$Success = $true
    )
    
    $entry = @{
        timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        category = $Category
        target = $Target
        action = $Action
        oldValue = $OldValue
        newValue = $NewValue
        reversible = $Reversible
        success = $Success
        isDryRun = $script:DryRunMode
        user = [Environment]::UserName
        computer = [Environment]::ComputerName
    }
    
    $script:AuditLog += $entry
    
    if (-not $DryRun) {
        $script:AuditLog | ConvertTo-Json | Out-File -FilePath $script:Config.LogPath -Encoding UTF8 -Force
    }
}

# ============================================================================
# RESTORE POINT MODULE
# ============================================================================
function New-SystemRestorePoint {
    param([string]$Description = 'WinPurge Restore Point')
    
    if ($script:DryRunMode) {
        Write-Host "[DRY-RUN] Would create system restore point: $Description" -ForegroundColor Cyan
        return
    }
    
    Write-Host "Creating system restore point..." -ForegroundColor Green
    
    try {
        $rp = New-Object -ComObject 'System.Deployment.Internal.InternalActivationContextHelper'
        $rp.CreateSystemRestorePoint($Description, 0, 100)
        Write-Host "✓ Restore point created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Could not create restore point (non-critical): $_" -ForegroundColor Yellow
    }
}

# ============================================================================
# TWEAK FUNCTIONS
# ============================================================================

function Disable-Telemetry {
    param([switch]$DryRun, [switch]$Quiet)
    
    if (-not $Quiet) { Write-Host "🚫 Disabling Telemetry..." -ForegroundColor Cyan }
    
    $services = @('DiagTrack', 'dmwappushservice', 'Connected User Experiences and Telemetry')
    
    foreach ($service in $services) {
        if ($DryRun -or $script:DryRunMode) {
            Write-Host "  [DRY-RUN] Would disable: $service" -ForegroundColor Gray
            Write-LogEntry -Category 'Telemetry' -Target $service -Action 'Disable-Service' -Reversible $true
        }
        else {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
                Write-LogEntry -Category 'Telemetry' -Target $service -Action 'Disable-Service' -Reversible $true -Success $true
                Write-Host "  ✓ Disabled: $service" -ForegroundColor Green
            }
        }
    }
}

function Disable-Bloatware {
    param([switch]$DryRun, [switch]$Quiet)
    
    if (-not $Quiet) { Write-Host "🧹 Removing Bloatware..." -ForegroundColor Cyan }
    
    $bloatware = @(
        'Microsoft.ZuneMusic',
        'Microsoft.ZuneVideo',
        'Microsoft.Messaging',
        'Microsoft.MicrosoftStickyNotes',
        'Microsoft.WindowsFeedbackHub'
    )
    
    foreach ($app in $bloatware) {
        if ($DryRun -or $script:DryRunMode) {
            Write-Host "  [DRY-RUN] Would remove: $app" -ForegroundColor Gray
            Write-LogEntry -Category 'Bloatware' -Target $app -Action 'Remove-App' -Reversible $false
        }
        else {
            $installedApp = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
            if ($installedApp) {
                Remove-AppxPackage -Package $installedApp -ErrorAction SilentlyContinue
                Write-LogEntry -Category 'Bloatware' -Target $app -Action 'Remove-App' -Success $true
                Write-Host "  ✓ Removed: $app" -ForegroundColor Green
            }
        }
    }
}

function Disable-AIFeatures {
    param([switch]$DryRun, [switch]$Quiet)
    
    if (-not $Quiet) { Write-Host "🤖 Removing AI Features..." -ForegroundColor Cyan }
    
    $aiApps = @('Microsoft.Copilot', 'Microsoft.WindowsCopilot')
    
    foreach ($app in $aiApps) {
        if ($DryRun -or $script:DryRunMode) {
            Write-Host "  [DRY-RUN] Would remove: $app" -ForegroundColor Gray
            Write-LogEntry -Category 'AI' -Target $app -Action 'Remove-AIFeature' -Reversible $false
        }
        else {
            $installedApp = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
            if ($installedApp) {
                Remove-AppxPackage -Package $installedApp -ErrorAction SilentlyContinue
                Write-LogEntry -Category 'AI' -Target $app -Action 'Remove-AIFeature' -Success $true
                Write-Host "  ✓ Removed AI: $app" -ForegroundColor Green
            }
        }
    }
}

function Disable-UnneededServices {
    param([switch]$DryRun, [switch]$Quiet)
    
    if (-not $Quiet) { Write-Host "⚙️  Optimizing Services..." -ForegroundColor Cyan }
    
    $servicesToDisable = @(
        'XboxGipSvc',
        'XblAuthManager',
        'XblGameSave',
        'xbgm',
        'RemoteRegistry'
    )
    
    foreach ($service in $servicesToDisable) {
        if ($DryRun -or $script:DryRunMode) {
            Write-Host "  [DRY-RUN] Would disable: $service" -ForegroundColor Gray
            Write-LogEntry -Category 'Services' -Target $service -Action 'Disable-Service' -Reversible $true
        }
        else {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
                Write-LogEntry -Category 'Services' -Target $service -Action 'Disable-Service' -Success $true
                Write-Host "  ✓ Disabled: $service" -ForegroundColor Green
            }
        }
    }
}

# ============================================================================
# PRESET MANAGEMENT
# ============================================================================

$Presets = @{
    Gaming = @{
        name = 'Gaming'
        description = 'Aggressive optimization for maximum gaming performance'
        tweaks = @(
            @{ name = 'Disable Telemetry'; function = 'Disable-Telemetry' },
            @{ name = 'Remove Bloatware'; function = 'Disable-Bloatware' },
            @{ name = 'Optimize Services'; function = 'Disable-UnneededServices' },
            @{ name = 'Remove AI'; function = 'Disable-AIFeatures' }
        )
    }
    Minimal = @{
        name = 'Minimal'
        description = 'Maximum privacy and minimal footprint'
        tweaks = @(
            @{ name = 'Disable Telemetry'; function = 'Disable-Telemetry' },
            @{ name = 'Remove Bloatware'; function = 'Disable-Bloatware' },
            @{ name = 'Optimize Services'; function = 'Disable-UnneededServices' },
            @{ name = 'Remove AI'; function = 'Disable-AIFeatures' }
        )
    }
    Developer = @{
        name = 'Developer'
        description = 'Optimized for development workflow'
        tweaks = @(
            @{ name = 'Disable Telemetry'; function = 'Disable-Telemetry' },
            @{ name = 'Remove Bloatware'; function = 'Disable-Bloatware' }
        )
    }
    Standard = @{
        name = 'Standard'
        description = 'Balanced optimization for general users'
        tweaks = @(
            @{ name = 'Disable Telemetry'; function = 'Disable-Telemetry' },
            @{ name = 'Remove Bloatware'; function = 'Disable-Bloatware' }
        )
    }
}

function Invoke-Preset {
    param(
        [ValidateSet('Gaming', 'Minimal', 'Developer', 'Standard')]
        [string]$PresetName,
        [switch]$DryRun,
        [switch]$Quiet
    )
    
    $preset = $Presets[$PresetName]
    
    if (-not $preset) {
        Write-Host "❌ Preset not found: $PresetName" -ForegroundColor Red
        return
    }
    
    Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🎯 Applying Preset: $($preset.name)" -ForegroundColor Green
    Write-Host "$($preset.description)" -ForegroundColor Gray
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    if ($script:DryRunMode -or $DryRun) {
        Write-Host "[DRY-RUN MODE] Changes will NOT be applied" -ForegroundColor Yellow
    }
    
    foreach ($tweak in $preset.tweaks) {
        Write-Host "`n→ $($tweak.name)" -ForegroundColor Cyan
        & $tweak.function -DryRun:($DryRun -or $script:DryRunMode) -Quiet:$Quiet -ErrorAction SilentlyContinue
    }
    
    Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "✅ Preset Application Complete" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# ============================================================================
# MAIN MENU
# ============================================================================

function Show-MainMenu {
    Clear-Host
    Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "    🖥️  WinPurge v$script:WinPurgeVersion" -ForegroundColor Green
    Write-Host "    Advanced Windows Debloater & Tweaker" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "`nAvailable Presets:`n" -ForegroundColor Yellow
    
    $presetNum = 1
    foreach ($presetName in $Presets.Keys) {
        Write-Host "  $presetNum. $presetName - $($Presets[$presetName].description)" -ForegroundColor White
        $presetNum++
    }
    
    Write-Host "`n  5. View Audit Log" -ForegroundColor Cyan
    Write-Host "  6. Settings" -ForegroundColor Cyan
    Write-Host "  0. Exit" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Start-InteractiveMode {
    $running = $true
    
    while ($running) {
        Show-MainMenu
        $choice = Read-Host "Select an option"
        
        switch ($choice) {
            '1' { Invoke-Preset -PresetName 'Gaming' -DryRun }
            '2' { Invoke-Preset -PresetName 'Minimal' -DryRun }
            '3' { Invoke-Preset -PresetName 'Developer' -DryRun }
            '4' { Invoke-Preset -PresetName 'Standard' -DryRun }
            '5' {
                Write-Host "`nAudit Log:`n" -ForegroundColor Cyan
                if (Test-Path $script:Config.LogPath) {
                    Get-Content $script:Config.LogPath | ConvertFrom-Json | Format-Table -AutoSize
                } else {
                    Write-Host "No audit log found yet." -ForegroundColor Gray
                }
                Read-Host "Press Enter to continue"
            }
            '6' { Write-Host "Settings menu coming soon..." -ForegroundColor Yellow; Read-Host "Press Enter" }
            '0' { $running = $false; Write-Host "`nGoodbye!" -ForegroundColor Green }
            default { Write-Host "Invalid option. Press Enter..." -ForegroundColor Red; Read-Host }
        }
    }
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     WinPurge v$script:WinPurgeVersion - Advanced Windows Tweaker    ║" -ForegroundColor Cyan
Write-Host "║                   Standalone Edition                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

New-SystemRestorePoint -Description "WinPurge v$script:WinPurgeVersion Optimization"

if ($Preset) {
    Write-Host "`nApplying preset: $Preset" -ForegroundColor Green
    Invoke-Preset -PresetName $Preset -DryRun:$DryRun -Quiet:$HeadlessMode
}
elseif ($HeadlessMode) {
    Write-Host "`nHeadless mode selected but no preset specified." -ForegroundColor Yellow
    Write-Host "Usage: .\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -Headless" -ForegroundColor Cyan
}
else {
    Start-InteractiveMode
}

Write-Host "`n✅ WinPurge Complete" -ForegroundColor Green
Write-Host "📋 Audit log saved to: $($script:Config.LogPath)" -ForegroundColor Cyan
Write-Host ""
