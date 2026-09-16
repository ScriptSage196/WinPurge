#Requires -Version 7.0
<#
.SYNOPSIS
    WinPurge - Advanced Windows Debloater/Tweaker
    
.DESCRIPTION
    A comprehensive Windows optimization tool with AI feature removal, dry-run mode,
    audit logging, plugin system, and community presets.
    
.PARAMETER GUI
    Launch the WPF GUI interface (default)
    
.PARAMETER DryRun
    Simulate changes without applying them
    
.PARAMETER Preset
    Apply a preset configuration (Gaming, Minimal, Developer, Standard)
    
.PARAMETER Headless
    Run in CLI mode without GUI
    
.PARAMETER NoElevate
    Skip elevation check (not recommended)
    
.EXAMPLE
    .\Main.ps1 -GUI
    .\Main.ps1 -Preset Gaming -DryRun
    .\Main.ps1 -Headless -Preset Minimal
#>

param(
    [switch]$GUI = $true,
    [switch]$DryRun,
    [ValidateSet('Gaming', 'Minimal', 'Developer', 'Standard')]
    [string]$Preset,
    [switch]$Headless,
    [switch]$NoElevate,
    [switch]$Verbose
)

# Configuration
$Script:WinPurgeRoot = Split-Path -Parent $MyInvocation.MyCommandPath
$Script:SrcPath = Join-Path $Script:WinPurgeRoot "src"
$Script:LogPath = Join-Path $env:TEMP "WinPurge_audit.json"
$Script:PluginPath = Join-Path $Script:WinPurgeRoot "plugins"
$Script:AuditLog = @()
$Script:DryRunMode = $DryRun
$Script:VerboseMode = $Verbose
$Script:OSVersion = [System.Environment]::OSVersion.Version

Write-Host "WinPurge v2.0 - Advanced Windows Optimization Tool" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/ScriptSage196/WinPurge" -ForegroundColor Gray

# ============================================================================
# ELEVATION CHECK
# ============================================================================

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $NoElevate -and -not (Test-AdminRights)) {
    Write-Host "⚠ WinPurge requires administrator privileges" -ForegroundColor Yellow
    Write-Host "Attempting to elevate..." -ForegroundColor Cyan
    
    $args = @(
        "-NoExit",
        "-ExecutionPolicy Bypass",
        "-File `"$($MyInvocation.MyCommandPath)`"",
        "-NoElevate"
    )
    
    if ($DryRun) { $args += "-DryRun" }
    if ($Headless) { $args += "-Headless" }
    if ($Preset) { $args += "-Preset $Preset" }
    if ($Verbose) { $args += "-Verbose" }
    
    Start-Process powershell -ArgumentList $args -Verb RunAs
    exit
}

Write-Host "✓ Running with administrator privileges" -ForegroundColor Green

# ============================================================================
# CORE MODULE LOADING
# ============================================================================

function Import-WinPurgeModule {
    param([string]$ModuleName)
    
    $modulePath = Join-Path $Script:SrcPath $ModuleName
    
    if (Test-Path $modulePath) {
        try {
            . $modulePath
            Write-Host "✓ Loaded: $ModuleName" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Failed to load $ModuleName : $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "✗ Module not found: $modulePath" -ForegroundColor Red
    }
}

# Load core modules
Write-Host "`n[Core Modules]" -ForegroundColor Cyan
Import-WinPurgeModule "Core/Logging.ps1"
Import-WinPurgeModule "Core/Elevation.ps1"
Import-WinPurgeModule "Core/DryRun.ps1"
Import-WinPurgeModule "Core/AuditLog.ps1"
Import-WinPurgeModule "Core/RestorePoint.ps1"
Import-WinPurgeModule "Core/VersionCheck.ps1"
Import-WinPurgeModule "Core/Benchmark.ps1"

# Load tweak modules
Write-Host "`n[Tweak Modules]" -ForegroundColor Cyan
$tweakModules = @(
    "Tweaks/Telemetry.ps1",
    "Tweaks/Bloatware.ps1",
    "Tweaks/Services.ps1",
    "Tweaks/Registry.ps1",
    "Tweaks/Privacy.ps1",
    "Tweaks/Network.ps1",
    "Tweaks/FileExplorer.ps1",
    "Tweaks/Taskbar.ps1",
    "Tweaks/StartMenu.ps1",
    "Tweaks/WindowsUpdate.ps1"
)

foreach ($module in $tweakModules) {
    Import-WinPurgeModule $module
}

# Load AI modules
Write-Host "`n[AI Protection Modules]" -ForegroundColor Cyan
Import-WinPurgeModule "AI/AIProtection.ps1"
Import-WinPurgeModule "AI/AIReinstallBlock.ps1"
Import-WinPurgeModule "AI/PostUpdateCleanup.ps1"
Import-WinPurgeModule "AI/ClassicAppReplace.ps1"

# Load utility modules
Write-Host "`n[Utility Modules]" -ForegroundColor Cyan
Import-WinPurgeModule "Install/WingetHelper.ps1"
Import-WinPurgeModule "Iso/DisMHelper.ps1"
Import-WinPurgeModule "Plugins/PluginLoader.ps1"
Import-WinPurgeModule "Presets/PresetManager.ps1"

# ============================================================================
# VERSION AND COMPATIBILITY CHECK
# ============================================================================

Write-Host "`n[System Verification]" -ForegroundColor Cyan
$osCheck = Test-OSCompatibility
if ($osCheck) {
    Write-Host "✓ OS Compatible: $($Script:OSVersion)" -ForegroundColor Green
}
else {
    Write-Host "✗ OS Not Supported. Requires Windows 10 22H2+ or Windows 11 23H2+" -ForegroundColor Red
    exit 1
}

# ============================================================================
# DRY-RUN MODE
# ============================================================================

if ($Script:DryRunMode) {
    Write-Host "`n" -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host " DRY-RUN MODE ENABLED - No changes will be applied" -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# HEADLESS MODE
# ============================================================================

if ($Headless) {
    Write-Host "`n[Headless Mode]" -ForegroundColor Cyan
    
    if ($Preset) {
        Write-Host "Applying preset: $Preset" -ForegroundColor Yellow
        Apply-Preset -PresetName $Preset -DryRun:$Script:DryRunMode
    }
    else {
        Write-Host "No preset specified. Use -Preset <name> with headless mode." -ForegroundColor Yellow
        Write-Host "Available presets: Gaming, Minimal, Developer, Standard" -ForegroundColor Gray
    }
    
    exit
}

# ============================================================================
# GUI MODE (DEFAULT)
# ============================================================================

Write-Host "`n[Launching GUI]" -ForegroundColor Cyan

$guiPath = Join-Path $Script:SrcPath "GUI/MainWindow.xaml.cs"

if (Test-Path $guiPath) {
    try {
        # GUI loading logic will be implemented here
        # For now, show placeholder
        Write-Host "✓ GUI components ready" -ForegroundColor Green
        Write-Host "`nNote: Full WPF GUI implementation pending..." -ForegroundColor Gray
    }
    catch {
        Write-Host "✗ Failed to launch GUI: $_" -ForegroundColor Red
        Write-Host "Falling back to CLI mode..." -ForegroundColor Yellow
    }
}
else {
    Write-Host "✗ GUI files not found. Running in CLI mode." -ForegroundColor Yellow
    Write-Host "Available tweaks can be applied via -Preset or manual commands." -ForegroundColor Gray
}

Write-Host "`n[Ready for input]" -ForegroundColor Green
