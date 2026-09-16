<#
.SYNOPSIS
    Unattend.xml generation for clean Windows installations
    
.DESCRIPTION
    Generates automated setup XML files to apply WinPurge tweaks
    during fresh Windows installations via Sysprep.
#>

<#
.DESCRIPTION
    Generate base Unattend.xml template
#>
function New-UnattendTemplate {
    param(
        [string]$ComputerName = 'WinPurge-PC',
        [string]$TimeZone = 'UTC',
        [ValidateSet('Home', 'Pro', 'Enterprise')]
        [string]$Edition = 'Pro'
    )
    
    Write-WinPurgeSectionHeader "Generating Unattend.xml Template"
    
    $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend"
    xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="urn:schemas-microsoft-com:unattend http://schemas.microsoft.com/WMIConfig/2002/State/unattend.xsd">
    
    <!-- System settings -->
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" 
            publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$ComputerName</ComputerName>
            <TimeZone>$TimeZone</TimeZone>
        </component>
    </settings>
    
    <!-- OOBESystem pass -->
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" 
            publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
            </OOBE>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>cmd /c echo Setup complete</CommandLine>
                    <Order>1</Order>
                </SynchronousCommand>
            </FirstLogonCommands>
        </component>
    </settings>
</unattend>
"@
    
    Write-WinPurgeSuccess "Unattend.xml template generated for: $ComputerName" -Category 'Unattend'
    return $xml
}

<#
.DESCRIPTION
    Save Unattend.xml to file
#>
function Save-UnattendXML {
    param(
        [Parameter(Mandatory = $true)]
        [string]$XMLContent,
        
        [string]$Path = (Join-Path $env:TEMP 'Unattend.xml')
    )
    
    try {
        $XMLContent | Out-File -FilePath $Path -Encoding UTF8 -Force
        Write-WinPurgeSuccess "Unattend.xml saved to: $Path" -Category 'Unattend'
        return $Path
    }
    catch {
        Write-WinPurgeError "Failed to save Unattend.xml: $_" -Category 'Unattend'
        return $null
    }
}

Export-ModuleMember -Function @(
    'New-UnattendTemplate',
    'Save-UnattendXML'
)
