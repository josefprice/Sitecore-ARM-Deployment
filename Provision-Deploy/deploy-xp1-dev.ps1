param (
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$true)]
    [string]$StorageContainerName,
    [Parameter(Mandatory=$true)]
    [string]$SqlServerFqdn,
    [Parameter(Mandatory=$true)]
    [string]$Location,
    [Parameter(Mandatory=$true)]
    [string]$AzureToolkit,
    [Parameter(Mandatory=$true)]
    [string]$StorageConnectionString,
    [Parameter(Mandatory=$true)]
    [string]$SitecoreAdminPassword,
    [Parameter(Mandatory=$true)]
    [string]$SqlServerLogin,
    [Parameter(Mandatory=$true)]
    [string]$SqlServerPassword,
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId,
    [Parameter(Mandatory=$false, HelpMessage="Prompt for Azure Login")]
    [switch]$PromptAzureLogin
)

Import-Module (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath "Modules\Import-ModulesAndSettings.psm1") -Force

$ARMTemplateFile = "application-cmcd-slots.json"
$ParamFileName = "azuredeploy-redeploy-application.parameters.json"

DeploySitecoreApplication `
    -ARMTemplateFile $ARMTemplateFile `
    -ParamFileName $ParamFileName `
    -SubscriptionId  $SubscriptionId  `
    -DeploymentId $ResourceGroupName `
    -Location $Location `
    -AzureToolkit $AzureToolkit `
    -Environment $Environment `
    -SqlServerLogin $SqlServerLogin `
    -SqlServerPassword $SqlServerPassword `
    -SqlServerFqdn $SqlServerFqdn `
    -SitecoreAdminPassword $SitecoreAdminPassword `
    -StorageResourceGroup $StorageResourceGroup `
    -StorageAccountName $StorageAccountName `
    -StorageContainerName $StorageContainerName `
    -PromptAzureLogin:$PromptAzureLogin