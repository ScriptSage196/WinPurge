# Plugin Interface Specification for WinPurge

## Overview
Plugins extend WinPurge functionality by dropping .ps1 files into the `plugins/` folder.
Each plugin is automatically discovered, loaded, and integrated into the GUI and CLI.

## Plugin Structure

### Metadata Header (Required)
```powershell
# Name: Display Name of Plugin
# Description: What this plugin does
# Author: Your Name
# Version: 1.0
# Category: Tweaks | Install | System | Utility
# Tags: tag1, tag2, tag3
```

### Minimum Requirements
```powershell
#Requires -Version 7.0

# Import core WinPurge functions (available in global scope)
# - Write-WinPurgeLog, Write-WinPurgeSuccess, Write-WinPurgeError
# - Get-DryRunMode, Set-DryRunRegistry, Set-DryRunService
# - Add-AuditLogEntry, Assert-AdminRights

function Invoke-MyPlugin {
    param(
        [switch]$DryRun,
        [switch]$Quiet
    )
    
    # Your plugin logic here
    Write-WinPurgeSuccess "Plugin executed successfully" -Category "MyPlugin"
}

Export-ModuleMember -Function @('Invoke-MyPlugin')
```

## Best Practices

### 1. Use WinPurge Logging Functions
```powershell
Write-WinPurgeSuccess "Operation completed" -Category "MyPlugin"
Write-WinPurgeWarning "Something might be wrong" -Category "MyPlugin"
Write-WinPurgeError "Critical error occurred: $error" -Category "MyPlugin"
```

### 2. Respect Dry-Run Mode
```powershell
if ((Get-DryRunMode)) {
    Write-WinPurgeWarning "[DRY-RUN] Would perform action" -Category "MyPlugin"
    return $true
}

# Actual changes here
```

### 3. Log All Changes to Audit
```powershell
Add-AuditLogEntry -Category "MyPlugin" `
    -Target "Something" `
    -OldValue $oldVal `
    -NewValue $newVal `
    -Command "Command used" `
    -Reversible $true `
    -Success $success
```

### 4. Support All Parameters
```powershell
function My-Function {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Verbose = $Script:VerboseMode,
        [switch]$Quiet,
        [string[]]$Preserve   # Skip specific items
    )
}
```

### 5. Provide Undo Functions
```powershell
function My-Function {
    # Apply changes
}

function Undo-MyFunction {
    # Revert changes
}

Export-ModuleMember -Function @('My-Function', 'Undo-MyFunction')
```

## Example Plugin: Custom Service Disabler

```powershell
# Name: Custom Service Optimizer
# Description: Disables specific services for your workflow
# Author: Your Name
# Version: 1.0
# Category: Tweaks
# Tags: services, optimization

#Requires -Version 7.0

function Optimize-CustomServices {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Optimizing Custom Services"
    
    $services = @(
        'CustomService1',
        'CustomService2'
    )
    
    foreach ($service in $services) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            $oldState = $svc.StartType
            $result = Set-DryRunService -ServiceName $service -State 'Disabled'
            
            Add-AuditLogEntry -Category 'CustomPlugin' `
                -Target $service `
                -OldValue $oldState `
                -NewValue 'Disabled' `
                -Command "Set-Service -Name $service -StartupType Disabled" `
                -Reversible $true `
                -Success $result.Success
        }
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Custom services optimized" -Category 'CustomPlugin'
    }
}

function Undo-CustomServices {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Reverting Custom Service Changes"
    
    # Revert logic here
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Custom service changes reverted" -Category 'CustomPlugin'
    }
}

Export-ModuleMember -Function @(
    'Optimize-CustomServices',
    'Undo-CustomServices'
)
```

## Available Global Functions

### Logging
- `Write-WinPurgeLog -Level <DEBUG|INFO|WARNING|ERROR|SUCCESS> -Message <string> -Category <string>`
- `Write-WinPurgeSuccess <message> -Category <string>`
- `Write-WinPurgeError <message> -Category <string>`
- `Write-WinPurgeWarning <message> -Category <string>`
- `Write-WinPurgeInfo <message> -Category <string>`
- `Write-WinPurgeSectionHeader <title>`

### Dry-Run & Changes
- `Get-DryRunMode` - Returns $true if in dry-run mode
- `Set-DryRunRegistry -Path <string> -Name <string> -Value <object> -Type <string>`
- `Set-DryRunService -ServiceName <string> -State <string>`
- `Invoke-DryRunCommand -CommandDescription <string> -Command <scriptblock>`

### Audit Logging
- `Add-AuditLogEntry -Category <string> -Target <string> -OldValue <object> -NewValue <object> -Command <string> -Reversible <bool> -Success <bool>`
- `Save-AuditLog -Path <string>`
- `Load-AuditLog -Path <string>`

### Security
- `Assert-AdminRights` - Throws if not admin
- `Test-AdminRights` - Returns $true if admin
- `Get-CurrentUserContext` - Returns user info

### System Info
- `Get-SystemBenchmark -Label <string>` - Captures performance metrics
- `Test-OSCompatibility` - Returns $true if OS supported
- `Get-OSInfo` - Returns detailed OS information

## Debugging Plugins

Run with verbose mode to see detailed execution:
```powershell
.\Main.ps1 -Verbose
```

Check audit log:
```powershell
Get-Content "$env:TEMP\WinPurge_audit.json" | ConvertFrom-Json
```

## Distribution

To share your plugin:
1. Create a GitHub Gist or repository
2. Document usage in comments
3. Include example invocations
4. Link to it in WinPurge community forum

Plugins can be easily installed by users dropping them in `plugins/` folder.

## Limitations

- Plugins run in same PowerShell session as WinPurge
- No sandbox isolation (use `-DryRun` for safety)
- Must be PowerShell 7.0+ compatible
- Admin elevation required for system changes
