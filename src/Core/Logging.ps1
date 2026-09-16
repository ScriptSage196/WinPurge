<#
.SYNOPSIS
    Centralized logging system for WinPurge
    
.DESCRIPTION
    Provides structured logging with severity levels, console formatting,
    and file output for debugging and auditing.
#>

$Script:LogLevels = @{
    'DEBUG'   = 0
    'INFO'    = 1
    'WARNING' = 2
    'ERROR'   = 3
    'SUCCESS' = 4
}

$Script:LogColors = @{
    'DEBUG'   = 'Gray'
    'INFO'    = 'Cyan'
    'WARNING' = 'Yellow'
    'ERROR'   = 'Red'
    'SUCCESS' = 'Green'
}

<#
.DESCRIPTION
    Write a log entry with severity level and formatting
#>
function Write-WinPurgeLog {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [string]$Category = 'General',
        
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = "[$timestamp] [$Level] [$Category]"
    $color = $Script:LogColors[$Level]
    
    if (-not $NoConsole) {
        Write-Host "$prefix $Message" -ForegroundColor $color
    }
    
    # Log to file if audit log is initialized
    if ($Script:AuditLog) {
        $Script:AuditLog += @{
            timestamp = $timestamp
            level     = $Level
            category  = $Category
            message   = $Message
        }
    }
}

<#
.DESCRIPTION
    Write a debug message (only if verbose mode enabled)
#>
function Write-WinPurgeDebug {
    param(
        [string]$Message,
        [string]$Category = 'Debug'
    )
    
    if ($Script:VerboseMode) {
        Write-WinPurgeLog -Level DEBUG -Message $Message -Category $Category
    }
}

<#
.DESCRIPTION
    Write an info message
#>
function Write-WinPurgeInfo {
    param(
        [string]$Message,
        [string]$Category = 'Info'
    )
    
    Write-WinPurgeLog -Level INFO -Message $Message -Category $Category
}

<#
.DESCRIPTION
    Write a warning message
#>
function Write-WinPurgeWarning {
    param(
        [string]$Message,
        [string]$Category = 'Warning'
    )
    
    Write-WinPurgeLog -Level WARNING -Message $Message -Category $Category
}

<#
.DESCRIPTION
    Write an error message
#>
function Write-WinPurgeError {
    param(
        [string]$Message,
        [string]$Category = 'Error'
    )
    
    Write-WinPurgeLog -Level ERROR -Message $Message -Category $Category
}

<#
.DESCRIPTION
    Write a success message
#>
function Write-WinPurgeSuccess {
    param(
        [string]$Message,
        [string]$Category = 'Success'
    )
    
    Write-WinPurgeLog -Level SUCCESS -Message $Message -Category $Category
}

<#
.DESCRIPTION
    Log a section header with decorative formatting
#>
function Write-WinPurgeSectionHeader {
    param(
        [string]$Title,
        [string]$Character = '═'
    )
    
    $line = $Character * 60
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "$line`n" -ForegroundColor Cyan
}

Export-ModuleMember -Function @(
    'Write-WinPurgeLog',
    'Write-WinPurgeDebug',
    'Write-WinPurgeInfo',
    'Write-WinPurgeWarning',
    'Write-WinPurgeError',
    'Write-WinPurgeSuccess',
    'Write-WinPurgeSectionHeader'
)
