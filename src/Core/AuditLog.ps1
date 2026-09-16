<#
.SYNOPSIS
    Audit logging system for WinPurge changes
    
.DESCRIPTION
    Maintains detailed JSON audit log of all changes made, including:
    - Timestamp, category, target, old value, new value, command
    - Reversibility status
    - Dry-run vs actual changes
    Enables one-click full rebloat capability.
#>

<#
.DESCRIPTION
    Initialize audit log
#>
function Initialize-AuditLog {
    $Script:AuditLog = @()
    Write-WinPurgeDebug "Audit log initialized" -Category 'AuditLog'
}

<#
.DESCRIPTION
    Add entry to audit log
#>
function Add-AuditLogEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,
        
        [Parameter(Mandatory = $true)]
        [string]$Target,
        
        [object]$OldValue,
        
        [object]$NewValue,
        
        [string]$Command,
        
        [bool]$Reversible = $true,
        
        [bool]$Success = $true,
        
        [string]$Note
    )
    
    $entry = @{
        timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        category    = $Category
        target      = $Target
        oldValue    = $OldValue
        newValue    = $NewValue
        command     = $Command
        reversible  = $Reversible
        success     = $Success
        isDryRun    = (Get-DryRunMode)
        note        = $Note
    }
    
    $Script:AuditLog += $entry
    Write-WinPurgeDebug "Logged: $Category - $Target" -Category 'AuditLog'
}

<#
.DESCRIPTION
    Save audit log to JSON file
#>
function Save-AuditLog {
    param(
        [string]$Path = $Script:LogPath
    )
    
    try {
        $json = $Script:AuditLog | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $Path -Encoding UTF8 -Force
        Write-WinPurgeSuccess "Audit log saved to: $Path" -Category 'AuditLog'
        return $true
    }
    catch {
        Write-WinPurgeError "Failed to save audit log: $_" -Category 'AuditLog'
        return $false
    }
}

<#
.DESCRIPTION
    Load audit log from JSON file
#>
function Load-AuditLog {
    param(
        [string]$Path = $Script:LogPath
    )
    
    if (-not (Test-Path $Path)) {
        Write-WinPurgeWarning "Audit log file not found: $Path" -Category 'AuditLog'
        return $null
    }
    
    try {
        $json = Get-Content -Path $Path -Raw | ConvertFrom-Json
        Write-WinPurgeSuccess "Audit log loaded from: $Path" -Category 'AuditLog'
        return $json
    }
    catch {
        Write-WinPurgeError "Failed to load audit log: $_" -Category 'AuditLog'
        return $null
    }
}

<#
.DESCRIPTION
    Get all reversible changes from audit log
#>
function Get-ReversibleChanges {
    param(
        [string]$Category,
        [string]$Path = $Script:LogPath
    )
    
    $log = Load-AuditLog -Path $Path
    if (-not $log) { return @() }
    
    $changes = $log | Where-Object { $_.reversible -eq $true -and $_.success -eq $true }
    
    if ($Category) {
        $changes = $changes | Where-Object { $_.category -eq $Category }
    }
    
    return $changes
}

<#
.DESCRIPTION
    Export audit log as formatted report
#>
function Export-AuditReport {
    param(
        [string]$Path = (Join-Path $env:TEMP "WinPurge_audit_report.html"),
        [string]$Format = 'HTML'  # HTML, CSV, or JSON
    )
    
    if ($Script:AuditLog.Count -eq 0) {
        Write-WinPurgeWarning "No audit log entries to export" -Category 'AuditLog'
        return $null
    }
    
    try {
        switch ($Format.ToUpper()) {
            'JSON' {
                $content = $Script:AuditLog | ConvertTo-Json -Depth 10
            }
            'CSV' {
                $content = $Script:AuditLog | ConvertTo-Csv -NoTypeInformation
            }
            'HTML' {
                $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>WinPurge Audit Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0078d4; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #0078d4; color: white; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .success { color: green; }
        .failed { color: red; }
        .dryrun { background-color: #fff3cd; }
    </style>
</head>
<body>
    <h1>WinPurge Audit Report</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    <table>
        <tr>
            <th>Timestamp</th>
            <th>Category</th>
            <th>Target</th>
            <th>Old Value</th>
            <th>New Value</th>
            <th>Status</th>
            <th>Dry-Run</th>
        </tr>
"@
                
                foreach ($entry in $Script:AuditLog) {
                    $statusClass = if ($entry.success) { 'success' } else { 'failed' }
                    $statusText = if ($entry.success) { 'Success' } else { 'Failed' }
                    $dryRunClass = if ($entry.isDryRun) { 'dryrun' } else { '' }
                    
                    $html += @"
        <tr class="$dryRunClass">
            <td>$($entry.timestamp)</td>
            <td>$($entry.category)</td>
            <td>$($entry.target)</td>
            <td>$($entry.oldValue)</td>
            <td>$($entry.newValue)</td>
            <td class="$statusClass">$statusText</td>
            <td>$(if ($entry.isDryRun) { 'Yes' } else { 'No' })</td>
        </tr>
"@
                }
                
                $html += @"
    </table>
</body>
</html>
"@
                $content = $html
            }
        }
        
        $content | Out-File -FilePath $Path -Encoding UTF8 -Force
        Write-WinPurgeSuccess "Audit report exported to: $Path" -Category 'AuditLog'
        return $Path
    }
    catch {
        Write-WinPurgeError "Failed to export audit report: $_" -Category 'AuditLog'
        return $null
    }
}

<#
.DESCRIPTION
    Clear audit log
#>
function Clear-AuditLog {
    param(
        [switch]$Confirm
    )
    
    if (-not $Confirm) {
        Write-WinPurgeWarning "Use -Confirm to clear audit log" -Category 'AuditLog'
        return $false
    }
    
    $Script:AuditLog = @()
    Write-WinPurgeSuccess "Audit log cleared" -Category 'AuditLog'
    return $true
}

Export-ModuleMember -Function @(
    'Initialize-AuditLog',
    'Add-AuditLogEntry',
    'Save-AuditLog',
    'Load-AuditLog',
    'Get-ReversibleChanges',
    'Export-AuditReport',
    'Clear-AuditLog'
)
