Import-Module (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath "Modules\Import-ModulesAndSettings.psm1") -Force

$ArmTemplateUrl = "https://raw.githubusercontent.com/Sitecore/Sitecore-Azure-Quickstart-Templates/master/Sitecore%209.1.1/XP/azuredeploy.json"
$ParamFileName = "azuredeploy.parameters.json"
$Environment = "XP"
$Location = "UK South"
$DeploymentId = "valtech-dev-4"
$SubscriptionId = "62d371f3-9d21-4c34-8228-df37a925dab0"
$SitecoreVersion = "9.1.1"
$SitecoreBuildNumber = "002459"
$SitecoreLicensePath = "C:\Sitecore\scripts\license.xml"

$SitecoreAdminPassword = "b" 
#$SitecoreAdminPassword = [system.web.security.membership]::GeneratePassword(15,3)
$SitecoreAdminPasswordSecure = ConvertTo-SecureString $SitecoreAdminPassword -AsPlainText -Force

$StorageResourceGroup = "Sitecore"
$StorageAccountName = "valtechsitecore"
$StorageContainerName = "sc911"

ProvisionNewSitecoreEnvironment `
    -SitecoreVersion $SitecoreVersion `
    -SitecoreBuildNumber $SitecoreBuildNumber `
    -SitecoreLicensePath $SitecoreLicensePath `
    -SitecoreAdminPassword $SitecoreAdminPasswordSecure `
    -ARMTemplateUrl $ArmTemplateUrl `
    -ParamFileName $ParamFileName `
    -SubscriptionId $SubscriptionId `
    -DeploymentId $DeploymentId `
    -Environment $Environment `
    -Location $Location `
    -AzureToolkit $Settings.Locations.AzureToolkitPath `
    -StorageResourceGroup $StorageResourceGroup `
    -StorageAccountName $StorageAccountName `
    -StorageContainerName $StorageContainerName
    