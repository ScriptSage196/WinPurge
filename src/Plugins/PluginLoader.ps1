<#
.SYNOPSIS
    Plugin system loader and manager
    
.DESCRIPTION
    Dynamically loads community plugins from the plugins/ folder.
    Each plugin appears as a menu item in the GUI and CLI.
#>

<#
.DESCRIPTION
    Scan and load all available plugins
#>
function Load-Plugins {
    param(
        [string]$PluginPath = $Script:PluginPath
    )
    
    if (-not (Test-Path $PluginPath)) {
        Write-WinPurgeDebug "Plugin directory not found: $PluginPath" -Category 'Plugins'
        return @()
    }
    
    Write-WinPurgeSectionHeader "Loading Plugins"
    
    $pluginFiles = Get-ChildItem -Path $PluginPath -Filter '*.ps1' -ErrorAction SilentlyContinue
    $loadedPlugins = @()
    
    foreach ($file in $pluginFiles) {
        try {
            . $file.FullName
            $loadedPlugins += $file.Name
            Write-WinPurgeSuccess "Loaded plugin: $($file.Name)" -Category 'Plugins'
        }
        catch {
            Write-WinPurgeWarning "Failed to load plugin $($file.Name) : $_" -Category 'Plugins'
        }
    }
    
    Write-WinPurgeInfo "Loaded $($loadedPlugins.Count) plugins" -Category 'Plugins'
    return $loadedPlugins
}

<#
.DESCRIPTION
    Get list of available plugins
#>
function Get-AvailablePlugins {
    param(
        [string]$PluginPath = $Script:PluginPath
    )
    
    if (-not (Test-Path $PluginPath)) {
        return @()
    }
    
    $plugins = @()
    $pluginFiles = Get-ChildItem -Path $PluginPath -Filter '*.ps1' -ErrorAction SilentlyContinue
    
    foreach ($file in $pluginFiles) {
        $content = Get-Content $file.FullName -Raw
        $nameMatch = $content -match '#\s*Name:\s*(.*)'
        $descMatch = $content -match '#\s*Description:\s*(.*)'
        
        $plugins += @{
            Name        = if ($nameMatch) { $matches[1].Trim() } else { $file.BaseName }
            File        = $file.Name
            Path        = $file.FullName
            Description = if ($descMatch) { $matches[1].Trim() } else { 'No description' }
        }
    }
    
    return $plugins
}

<#
.DESCRIPTION
    Execute a specific plugin
#>
function Invoke-Plugin {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PluginName,
        
        [switch]$DryRun = $Script:DryRunMode
    )
    
    $pluginPath = Join-Path $Script:PluginPath "$PluginName.ps1"
    
    if (-not (Test-Path $pluginPath)) {
        Write-WinPurgeError "Plugin not found: $PluginName" -Category 'Plugins'
        return $false
    }
    
    try {
        Write-WinPurgeInfo "Executing plugin: $PluginName" -Category 'Plugins'
        . $pluginPath
        return $true
    }
    catch {
        Write-WinPurgeError "Plugin execution failed: $_" -Category 'Plugins'
        return $false
    }
}

Export-ModuleMember -Function @(
    'Load-Plugins',
    'Get-AvailablePlugins',
    'Invoke-Plugin'
)
