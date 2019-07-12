$psModules = Get-Childitem $PSScriptRoot -recurse | Where-Object { $_.extension -eq ".psm1" -and $_.Name -ne "Import-ModulesAndSettings.psm1"  }

foreach($module in $psModules) {
    Write-Host "Importing module: " $module.Name -ForegroundColor Cyan
    Import-Module $module.FullName -Force
}

#Set Global Variables to allow scripts to access outside of this module
$Global:Settings = Get-IniFile (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath "Settings.ini")
$Global:RootPath = Split-Path $PSScriptRoot -Parent
