Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

[string]$azTookkitPath = "C:\Sitecore\Sitecore Azure Toolkit 2.2.0 rev. 190305"

Import-Module "$azTookkitPath\tools\Sitecore.Cloud.Cmdlets.dll"
Import-Module (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath "Modules\Import-Modules.psm1")

Invoke-PreparePackages `
   -PackagePath "C:\Sitecore\Downloads\Sitecore 9.1.1 rev. 002459 (WDP XPScaled packages).zip" `
   -PackageExtractionPath "C:\Work\Other\Sitecore ARM Deployment\_Temp" `
   -ClearExtractionFolder `
   -ImportAzureToolkit `
   -AzureToolkitPath $azTookkitPath

