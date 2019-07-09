Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath "Modules\Import-ModulesAndSettings.psm1") -Force
Import-Module "$($Settings.Locations.AzureToolkitPath)\tools\Sitecore.Cloud.Cmdlets.dll"

Invoke-PreparePackages `
   -PackagePath "C:\Sitecore\Downloads\Sitecore 9.1.1 rev. 002459 (WDP XPScaled packages).zip" `
   -PackageExtractionPath (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath "_Temp")`
   -ClearExtractionFolder `
   -ImportAzureToolkit `
   -AzureToolkitPath $Settings.Locations.AzureToolkitPath

