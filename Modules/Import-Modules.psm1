$psModules = Get-Childitem $PSScriptRoot -recurse | Where-Object { $_.extension -eq ".psm1" -and $_.Name -ne "Import-Modules.psm1"  }

foreach($module in $psModules) {
    Write-Host "Importing module: " $module.Name -ForegroundColor Cyan
    Import-Module $module.FullName -Force
}
