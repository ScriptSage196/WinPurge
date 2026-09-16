<#
.SYNOPSIS
    Replace AI-based apps with classic alternatives
    
.DESCRIPTION
    Substitutes modern AI-integrated apps with proven alternatives:
    - Windows Search -> Classic Search
    - Copilot -> Prompt templates / Classic Help
    - Edge with Copilot -> Lite browsers or alternatives
#>

<#
.DESCRIPTION
    Replace Windows Search with Classic Search (if available)
#>
function Use-ClassicSearch {
    param(
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Replacing Windows Search"
    
    # Disable modern Windows Search
    Set-DryRunRegistry -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
        -Name 'SearchboxTaskbarMode' -Value 0 -Type DWORD
    
    Write-WinPurgeInfo "Recommendation: Use Everything Search or Classic Search for better file indexing" -Category 'ClassicApps'
    
    if (-not $Quiet) {
        Write-WinPurgeSuccess "Windows Search disabled, consider alternatives" -Category 'ClassicApps'
    }
}

<#
.DESCRIPTION
    Suggest and install classic app alternatives
#>
function Install-ClassicAppAlternatives {
    param(
        [ValidateSet('Browser', 'SearchTool', 'TextEditor', 'All')]
        [string]$Category = 'All',
        
        [switch]$Quiet
    )
    
    Write-WinPurgeSectionHeader "Installing Classic App Alternatives"
    
    $alternatives = @{
        'Browser'    = @(
            @{ Name = 'Firefox'; Package = 'Mozilla.Firefox' },
            @{ Name = 'Brave'; Package = 'BraveSoftware.BraveBrowser' }
        )
        'SearchTool' = @(
            @{ Name = 'Everything'; Package = 'voidtools.Everything' }
        )
        'TextEditor' = @(
            @{ Name = 'Notepad++'; Package = 'Notepad++.Notepad++' },
            @{ Name = 'VSCode'; Package = 'Microsoft.VisualStudioCode' }
        )
    }
    
    if ($Category -eq 'All') {
        $appsToInstall = $alternatives.Values | ForEach-Object { $_ }
    }
    else {
        $appsToInstall = $alternatives[$Category]
    }
    
    Write-WinPurgeInfo "Available alternatives:" -Category 'ClassicApps'
    foreach ($app in $appsToInstall) {
        Write-Host "  - $($app.Name) ($($app.Package))" -ForegroundColor Cyan
    }
    
    if (-not $Quiet) {
        Write-WinPurgeInfo "Install with: winget install <PackageName>" -Category 'ClassicApps'
    }
}

Export-ModuleMember -Function @(
    'Use-ClassicSearch',
    'Install-ClassicAppAlternatives'
)
