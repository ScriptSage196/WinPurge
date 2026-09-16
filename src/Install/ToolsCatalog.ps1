<#
.SYNOPSIS
    Tools and Applications catalog for WinPurge
    
.DESCRIPTION
    Comprehensive catalog of development tools, game launchers,
    browsers, and Microsoft applications with easy installation.
    Integrates with WinGet for seamless package management.
#>

$Script:ToolsCatalog = @{
    Games = @{
        'Steam'                = @{ Package = 'Valve.Steam'; Category = 'Gaming'; Description = 'Gaming platform and launcher' }
        'Epic Games Launcher'  = @{ Package = 'EpicGames.EpicGamesFree'; Category = 'Gaming'; Description = 'Epic Games store and launcher' }
        'GOG Galaxy'           = @{ Package = 'GOG.GOG'; Category = 'Gaming'; Description = 'GOG game client' }
        'Ubisoft Connect'      = @{ Package = 'Ubisoft.Connect'; Category = 'Gaming'; Description = 'Ubisoft game launcher' }
        'EA App'               = @{ Package = 'ElectronicArts.EAApp'; Category = 'Gaming'; Description = 'EA games and services' }
    }
    
    Browsers = @{
        'Google Chrome'        = @{ Package = 'Google.Chrome'; Category = 'Browser'; Description = 'Google web browser' }
        'Mozilla Firefox'      = @{ Package = 'Mozilla.Firefox'; Category = 'Browser'; Description = 'Privacy-focused browser' }
        'Microsoft Edge'       = @{ Package = 'Microsoft.Edge'; Category = 'Browser'; Description = 'Microsoft Edge browser' }
        'Brave Browser'        = @{ Package = 'BraveSoftware.BraveBrowser'; Category = 'Browser'; Description = 'Privacy-centric browser' }
        'Opera'                = @{ Package = 'Opera.Opera'; Category = 'Browser'; Description = 'Opera web browser' }
        'Vivaldi'              = @{ Package = 'VivaldiTechnologies.Vivaldi'; Category = 'Browser'; Description = 'Customizable browser' }
    }
    
    Development = @{
        'Visual Studio Code'   = @{ Package = 'Microsoft.VisualStudioCode'; Category = 'IDE'; Description = 'Code editor by Microsoft' }
        'Visual Studio'        = @{ Package = 'Microsoft.VisualStudio.Community'; Category = 'IDE'; Description = 'Full-featured IDE' }
        'Python'               = @{ Package = 'Python.Python.3.11'; Category = 'Language'; Description = 'Python programming language' }
        'Node.js'              = @{ Package = 'OpenJS.NodeJS'; Category = 'Language'; Description = 'JavaScript runtime' }
        'Git'                  = @{ Package = 'Git.Git'; Category = 'VCS'; Description = 'Version control system' }
        'GitHub Desktop'       = @{ Package = 'GitHub.GitHubDesktop'; Category = 'VCS'; Description = 'GitHub client' }
        'JetBrains IntelliJ'   = @{ Package = 'JetBrains.IntelliJIDEA.Community'; Category = 'IDE'; Description = 'Java IDE' }
        'Postman'              = @{ Package = 'Postman.Postman'; Category = 'API'; Description = 'API testing tool' }
        'Docker Desktop'       = @{ Package = 'Docker.DockerDesktop'; Category = 'DevOps'; Description = 'Container platform' }
        'VirtualBox'           = @{ Package = 'Oracle.VirtualBox'; Category = 'Virtualization'; Description = 'Virtualization platform' }
        'Notepad++'            = @{ Package = 'Notepad++.Notepad++'; Category = 'Editor'; Description = 'Advanced text editor' }
        '.NET SDK'             = @{ Package = 'Microsoft.DotNet.SDK.Latest'; Category = 'Framework'; Description = '.NET development framework' }
    }
    
    Productivity = @{
        'Microsoft Office'     = @{ Package = 'Microsoft.Office'; Category = 'Office'; Description = 'MS Office suite' }
        'LibreOffice'          = @{ Package = 'TheDocumentFoundation.LibreOffice'; Category = 'Office'; Description = 'Open source office suite' }
        'Obsidian'             = @{ Package = 'Obsidian.Obsidian'; Category = 'Notes'; Description = 'Knowledge base app' }
        'Notion'               = @{ Package = 'Notion.Notion'; Category = 'Notes'; Description = 'All-in-one workspace' }
        'Microsoft Teams'      = @{ Package = 'Microsoft.Teams'; Category = 'Communication'; Description = 'Team collaboration' }
        'Slack'                = @{ Package = 'SlackTechnologies.Slack'; Category = 'Communication'; Description = 'Team messaging' }
        'Discord'              = @{ Package = 'Discord.Discord'; Category = 'Communication'; Description = 'Community chat' }
    }
    
    Media = @{
        'VLC Media Player'     = @{ Package = 'VideoLAN.VLC'; Category = 'Player'; Description = 'Universal media player' }
        'OBS Studio'           = @{ Package = 'OBSProject.OBSStudio'; Category = 'Recording'; Description = 'Streaming/recording software' }
        'Audacity'             = @{ Package = 'Audacity.Audacity'; Category = 'Audio'; Description = 'Audio editor' }
        'FFmpeg'               = @{ Package = 'FFmpeg.FFmpeg'; Category = 'Converter'; Description = 'Multimedia framework' }
        'Blender'              = @{ Package = 'BlenderFoundation.Blender'; Category = '3D'; Description = '3D modeling software' }
    }
    
    Utilities = @{
        'Everything Search'    = @{ Package = 'voidtools.Everything'; Category = 'Search'; Description = 'Fast file search' }
        '7-Zip'                = @{ Package = '7zip.7zip'; Category = 'Archive'; Description = 'File archiver' }
        'WinRAR'               = @{ Package = 'RARLab.WinRAR'; Category = 'Archive'; Description = 'RAR archiver' }
        'Rufus'                = @{ Package = 'Rufus.Rufus'; Category = 'USB'; Description = 'USB bootable creation' }
        'HWiNFO'               = @{ Package = 'REALiX.HWiNFO'; Category = 'System'; Description = 'System information' }
        'CPU-Z'                = @{ Package = 'CPUID.CPU-Z'; Category = 'System'; Description = 'CPU information tool' }
        'GPU-Z'                = @{ Package = 'Techpowerup.GPU-Z'; Category = 'System'; Description = 'GPU information tool' }
        'GPU Driver Install'   = @{ Package = 'NVIDIA.GeForceExperience'; Category = 'Drivers'; Description = 'NVIDIA driver manager' }
    }
}

<#
.DESCRIPTION
    List all available tools by category
#>
function Get-AvailableTools {
    param(
        [ValidateSet('Games', 'Browsers', 'Development', 'Productivity', 'Media', 'Utilities', 'All')]
        [string]$Category = 'All'
    )
    
    if ($Category -eq 'All') {
        return $Script:ToolsCatalog
    }
    else {
        return $Script:ToolsCatalog[$Category]
    }
}

<#
.DESCRIPTION
    Display tools catalog in interactive format
#>
function Show-ToolsCatalog {
    param(
        [ValidateSet('Games', 'Browsers', 'Development', 'Productivity', 'Media', 'Utilities', 'All')]
        [string]$Category = 'All'
    )
    
    Write-WinPurgeSectionHeader "WinPurge Tools Catalog"
    
    if ($Category -eq 'All') {
        $categoriesToShow = @('Games', 'Browsers', 'Development', 'Productivity', 'Media', 'Utilities')
    }
    else {
        $categoriesToShow = @($Category)
    }
    
    foreach ($cat in $categoriesToShow) {
        Write-Host "`n" -ForegroundColor Cyan
        Write-Host "[=== $cat ==="] -ForegroundColor Yellow
        Write-Host ""
        
        $tools = $Script:ToolsCatalog[$cat]
        $counter = 1
        
        foreach ($tool in $tools.GetEnumerator() | Sort-Object Name) {
            $desc = $tool.Value.Description
            $pkg = $tool.Value.Package
            Write-Host "  $counter. $($tool.Name)" -ForegroundColor Green -NoNewline
            Write-Host " - $desc" -ForegroundColor Gray
            Write-Host "     Package: $pkg" -ForegroundColor DarkGray
            $counter++
        }
    }
    
    Write-Host "`n" -ForegroundColor Cyan
}

<#
.DESCRIPTION
    Install a specific tool from catalog
#>
function Install-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ToolName,
        
        [switch]$Silent,
        [switch]$DryRun = $Script:DryRunMode
    )
    
    # Search tool in catalog
    $tool = $null
    foreach ($category in $Script:ToolsCatalog.Values) {
        if ($category.ContainsKey($ToolName)) {
            $tool = $category[$ToolName]
            break
        }
    }
    
    if (-not $tool) {
        Write-WinPurgeError "Tool not found: $ToolName" -Category 'Tools'
        return $false
    }
    
    Write-WinPurgeInfo "Installing: $ToolName" -Category 'Tools'
    Write-WinPurgeInfo "Description: $($tool.Description)" -Category 'Tools'
    Write-WinPurgeDebug "Package: $($tool.Package)" -Category 'Tools'
    
    return Install-PackageViaWinGet -PackageName $tool.Package -Silent:$Silent -DryRun:$DryRun
}

<#
.DESCRIPTION
    Install multiple tools at once
#>
function Install-ToolsBundle {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ToolNames,
        
        [switch]$Silent,
        [switch]$DryRun = $Script:DryRunMode
    )
    
    Write-WinPurgeSectionHeader "Installing Tools Bundle"
    
    $installedCount = 0
    
    foreach ($tool in $ToolNames) {
        Write-WinPurgeInfo "Tool: $tool" -Category 'Tools'
        $result = Install-Tool -ToolName $tool -Silent:$Silent -DryRun:$DryRun
        if ($result) { $installedCount++ }
    }
    
    Write-WinPurgeSuccess "Installed $installedCount/$($ToolNames.Count) tools" -Category 'Tools'
    return @{
        Total      = $ToolNames.Count
        Installed  = $installedCount
        Failed     = $ToolNames.Count - $installedCount
    }
}

<#
.DESCRIPTION
    Get bundle recommendations (dev, gaming, minimal)
#>
function Get-ToolsBundle {
    param(
        [ValidateSet('Developer', 'Gamer', 'Minimal', 'Professional', 'Creator')]
        [string]$Bundle = 'Developer'
    )
    
    $bundles = @{
        'Developer' = @(
            'Visual Studio Code',
            'Git',
            'Python',
            'Node.js',
            'Postman',
            'Docker Desktop',
            'GitHub Desktop',
            'Mozilla Firefox'
        )
        'Gamer' = @(
            'Steam',
            'Epic Games Launcher',
            'GOG Galaxy',
            'Discord',
            'OBS Studio',
            'GPU-Z',
            'Google Chrome'
        )
        'Minimal' = @(
            'Mozilla Firefox',
            'Git',
            'Notepad++',
            'Everything Search',
            '7-Zip'
        )
        'Professional' = @(
            'Microsoft Office',
            'Visual Studio Code',
            'Microsoft Teams',
            'Postman',
            'Everything Search',
            'VLC Media Player',
            'Google Chrome'
        )
        'Creator' = @(
            'Blender',
            'OBS Studio',
            'Audacity',
            'FFmpeg',
            'Visual Studio Code',
            'Git',
            'VLC Media Player'
        )
    }
    
    return $bundles[$Bundle]
}

<#
.DESCRIPTION
    List Microsoft tools and utilities
#>
function Get-MicrosoftTools {
    $msTools = @(
        'Microsoft.Office',
        'Microsoft.VisualStudioCode',
        'Microsoft.VisualStudio.Community',
        'Microsoft.Teams',
        'Microsoft.Edge',
        'Microsoft.DotNet.SDK.Latest',
        'Microsoft.WindowsTerminal',
        'Microsoft.PowerShell',
        'Microsoft.OneDrive'
    )
    
    return $msTools
}

Export-ModuleMember -Function @(
    'Get-AvailableTools',
    'Show-ToolsCatalog',
    'Install-Tool',
    'Install-ToolsBundle',
    'Get-ToolsBundle',
    'Get-MicrosoftTools'
)
