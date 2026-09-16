<#
.SYNOPSIS
    Post-Windows Update cleanup task
    
.DESCRIPTION
    Scheduled task that automatically re-removes AI features after
    Windows Update reinstalls them. Runs post-update automatically.
#>

<#
.DESCRIPTION
    Create scheduled task for post-update cleanup
#>
function New-PostUpdateCleanupTask {
    param(
        [switch]$DryRun = $Script:DryRunMode,
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Creating Post-Update Cleanup Task"
    
    Assert-AdminRights
    
    $taskName = 'WinPurge_PostUpdateCleanup'
    $taskPath = '\Microsoft\Windows\WinPurge\'
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-WinPurgeInfo "Task already exists: $taskName" -Category 'PostUpdate'
        return $true
    }
    
    # Create the cleanup script
    $cleanupScript = @'
    # Post-update cleanup script
    param($silent = $false)
    
    # Re-remove AI features
    if (Test-AIBlocked) {
        Remove-WindowsCopilot -Quiet
        Disable-SearchAI -Quiet
    }
    
    # Re-disable telemetry if it was disabled
    if (Test-TelemetryDisabled) {
        Disable-Telemetry -Quiet
    }
'
    
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
        -Argument "-NoProfile -WindowStyle Hidden -Command $cleanupScript"
    
    $trigger = New-ScheduledTaskTrigger -AtStartup
    
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -StartWhenAvailable -RunOnlyIfNetworkAvailable
    
    if (-not $DryRun) {
        Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath `
            -Action $action -Trigger $trigger -Settings $settings `
            -RunLevel Highest -Force
        
        Write-WinPurgeSuccess "Post-update cleanup task created" -Category 'PostUpdate'
    }
    else {
        Write-WinPurgeWarning "[DRY-RUN] Would create post-update task: $taskName" -Category 'PostUpdate'
    }
    
    return $true
}

<#
.DESCRIPTION
    Remove post-update cleanup task
#>
function Remove-PostUpdateCleanupTask {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Removing Post-Update Cleanup Task"
    
    Assert-AdminRights
    
    $taskName = 'WinPurge_PostUpdateCleanup'
    $taskPath = '\Microsoft\Windows\WinPurge\'
    
    try {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false -ErrorAction Stop
        Write-WinPurgeSuccess "Post-update task removed" -Category 'PostUpdate'
    }
    catch {
        Write-WinPurgeWarning "Could not remove task: $_" -Category 'PostUpdate'
    }
}

Export-ModuleMember -Function @(
    'New-PostUpdateCleanupTask',
    'Remove-PostUpdateCleanupTask'
)
