<#
.SYNOPSIS
    Template for creating custom WinPurge modules
    
.DESCRIPTION
    Copy this template and modify to create your own tweaks.
    Every function MUST have:
    - A matching Undo- function
    - DryRun support
    - Audit logging
    - Error handling
    - Reversible flag
#>

<#
.DESCRIPTION
    Apply your custom tweaks
#>
function Apply-MyCustomTweaks {
    param(
        [string[]]$Preserve,
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Verbose = $Script:VerboseMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Applying Custom Tweaks"
    
    $changes = 0
    
    try {
        # Your tweak logic here
        $result = Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\MyCustom' `
            -Name 'MySetting' -Value 1 -Type DWORD
        
        if ($result.Success) {
            # Log to audit
            Add-AuditLogEntry -Category 'MyCustom' `
                -Target 'MySetting' `
                -OldValue $null `
                -NewValue 1 `
                -Command "Set-ItemProperty -Path 'HKCU:\SOFTWARE\MyCustom' -Name 'MySetting' -Value 1" `
                -Reversible $true `
                -Success $true
            
            $changes++
            Write-WinPurgeSuccess "Custom tweak applied" -Category 'MyCustom'
        }
    }
    catch {
        Write-WinPurgeError "Failed to apply custom tweak: $_" -Category 'MyCustom'
        
        Add-AuditLogEntry -Category 'MyCustom' `
            -Target 'MySetting' `
            -OldValue $null `
            -NewValue $null `
            -Command 'Apply-MyCustomTweaks' `
            -Reversible $false `
            -Success $false `
            -Note "Error: $_"
    }
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Applied $changes custom tweaks" -Category 'MyCustom'
    }
    
    return $changes
}

<#
.DESCRIPTION
    Undo your custom tweaks
#>
function Undo-MyCustomTweaks {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Undoing Custom Tweaks"
    
    try {
        # Undo logic here
        Remove-ItemProperty -Path 'HKCU:\SOFTWARE\MyCustom' `
            -Name 'MySetting' -ErrorAction SilentlyContinue
        
        Write-WinPurgeSuccess "Custom tweaks reverted" -Category 'MyCustom'
    }
    catch {
        Write-WinPurgeError "Failed to revert custom tweaks: $_" -Category 'MyCustom'
    }
}

Export-ModuleMember -Function @(
    'Apply-MyCustomTweaks',
    'Undo-MyCustomTweaks'
)
