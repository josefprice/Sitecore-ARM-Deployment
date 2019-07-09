Function Invoke-PreparePackages {
    Param(
        [Parameter(Mandatory = $True, HelpMessage = "WDP Package Path")]
        [string]$PackagePath,

        [Parameter(Mandatory = $True, HelpMessage = "Where to extract the individual packages (CM, CD)")]
        [string]$PackageExtractionPath,

        [Parameter(Mandatory = $False, HelpMessage = "Clear the extraction folder completely before extracting")]
        [switch]$ClearExtractionFolder,

        [Parameter(Mandatory = $False, HelpMessage = "Import Azure Toolkit")]
        [switch]$ImportAzureToolkit,

        [Parameter(Mandatory = $False, HelpMessage = "Azure Toolkit path")]
        [string]$AzureToolkitPath
    )

    if($ImportAzureToolkit -and [string]::IsNullOrEmpty($AzureToolkitPath)) {
        throw "AzureToolkitPath cant' be null or empty when ImportAzureToolkit is true"
    } 
    elseif($ImportAzureToolkit -and -not [string]::IsNullOrEmpty($AzureToolkitPath)) {
        Write-Host "Importing Azure Toolkit" -ForegroundColor Yellow
        Import-Module "$AzureToolkitPath\tools\Sitecore.Cloud.Cmdlets.dll"
    }

    if($ClearExtractionFolder) {
        Remove-Item "$PackageExtractionPath/*" -Force
    }

    # Extract Packages
    Expand-Archive -LiteralPath $PackagePath -DestinationPath $PackageExtractionPath

    # Loop through each package and create a without db version (CD)
    # Exclude files with withoutdb and xp1 in the name
    $scWdps = Get-Childitem $PackageExtractionPath -recurse | Where-Object { $_.extension -eq ".zip" -and $_.Name -notmatch "withoutdb" -and $_.Name -notmatch "xp1" }

    foreach ($scWdpPath in $scWdps) {
        Write-Host "Converting:" $scWdpPath.FullName -ForegroundColor Yellow
        Remove-SCDatabaseOperations -Path $scWdpPath.FullName -Destination "$PackageExtractionPath"
    }
    
}

