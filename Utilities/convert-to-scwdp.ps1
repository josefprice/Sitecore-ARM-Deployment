param (
    [Parameter(Mandatory=$True, HelpMessage="The path to the original Sitecore Module")]    
    [string]$ModuleOrginPath,
    [Parameter(Mandatory=$True, HelpMessage="The directory path to where it should be saved")]    
    [string]$Destination,
    [Parameter(Mandatory=$True, HelpMessage="The directory path to where Sitecore tools is installed")]    
    [string]$SCToolsPath,
    [switch]$StripDB
)

Import-Module (Join-Path $SCToolsPath "Sitecore.Cloud.Cmdlets.dll") -Verbose
$wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $ModuleOrginPath -Destination $Destination -Force

if($StripDB) {
    $convertToSCWDP = Join-Path "$($PSScriptRoot)" "strip-db.ps1"
    Write-Host $convertToSCWDP -ForegroundColor Green
    & $convertToSCWDP -PackagePath $wdpPath
}
