[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$PackagePath

  # [Parameter(Mandatory=$True)]
  # [string]$ParamFile
)
$noDbPath =  Join-Path $(Split-Path -Path $PackagePath -Parent) "no-db"
if(!(Test-Path $noDbPath)) {
    New-Item -ItemType directory -Path $noDbPath
}

#Extract package to get the original paramiters files
$packageExtracttionPath = $PackagePath.Replace(".zip", "")
Expand-Archive $PackagePath -DestinationPath $packageExtracttionPath
$ParamFile = Join-Path $packageExtracttionPath "parameters.xml"

$PackageDestinationPath = (Join-Path $noDbPath $(Split-Path $PackagePath -leaf)).Replace(".scwdp.zip", "-nodb.scwdp.zip")

Write-Host $PackageDestinationPath -ForegroundColor Green

$msdeploy = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"
$verb = "-verb:sync"
$source = "-source:package=`"$PackagePath`""
$destination = "-dest:package=`"$($PackageDestinationPath)`""
$declareParamFile = "-declareparamfile=`"$($ParamFile)`""
$skipDbFullSQL = "-skip:objectName=dbFullSql"
$skipDbDacFx = "-skip:objectName=dbDacFx"

# read parameter file
[xml]$paramfile_content = Get-Content -Path $ParamFile
$paramfile_paramnames = $paramfile_content.parameters.parameter.name
$params = ""
foreach($paramname in $paramfile_paramnames){
   $tmpvalue = "tmpvalue"
   if($paramname -eq "License Xml"){ $tmpvalue = "LicenseContent"}
   if($paramname -eq "IP Security Client IP"){ $tmpvalue = "0.0.0.0"}
   if($paramname -eq "IP Security Client IP Mask"){ $tmpvalue = "0.0.0.0"}
   $params = "$params -setParam:`"$paramname`"=`"$tmpvalue`""
}

# create new package
Invoke-Expression "& '$msdeploy' --% $verb $source $destination $declareParamFile $skipDbFullSQL $skipDbDacFx $params"