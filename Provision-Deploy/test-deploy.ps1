$ErrorActionPreference = "Stop"

# 1. Delete Existing Staging Slots (CM & CD)

# 2. Create Staging Slots (CM & CD)

# 3. Deploy Applicaiton in to Staging Slots

$SubscriptionId = "62d371f3-9d21-4c34-8228-df37a925dab0"
$DeploymentId = "valtech-dev-4"
$StagingSlotName = "Staging"
$Environment = "XP"
$Location = "UK South"
$AzureToolkit = "C:\Sitecore\Sitecore Azure Toolkit 2.2.0 rev. 190305"

$StorageResourceGroup = "Sitecore"
$StorageAccountName = "valtechsitecore"
$StorageContainerName = "sc911"

$SitecoreAdminPassword = "f£4C@dcDSklwoo9"

$SqlServerFqdn = "Enter-SQL-Domain"
$SqlServerLogin = "scSqlAdmin"
$SqlServerPassword = "Enter-SQL-Password"

Import-Module "$($PSScriptRoot)\..\Functions\Import-Modules.psm1" -Force
LoginAzureSubscription -UseServicePrinciple $False -SubscriptionId $SubscriptionId

$cmAppName = "$DeploymentId-cm"
$cdAppName = "$DeploymentId-cd"

# 1
Write-Host "Deleting $StagingSlotName slots for:`n- $cmAppName`n- $cdAppName" -ForegroundColor Yellow  

# Remove-AzureRmWebAppSlot -ResourceGroupName $DeploymentId -Name $cmAppName -Slot $StagingSlotName -AsJob -Force | Show-JobProgress
# Remove-AzureRmWebAppSlot -ResourceGroupName $DeploymentId -Name $cdAppName -Slot $StagingSlotName -AsJob -Force | Show-JobProgress

# 2
# Wait for previous jobs to finish
Get-Job | Wait-Job

Write-Host "Creating $StagingSlotName slots for:`n- $cmAppName`n- $cdAppName" -ForegroundColor Green  

# New-AzureRmWebAppSlot -ResourceGroupName $DeploymentId -Name $cmAppName -Slot $StagingSlotName -AsJob | Show-JobProgress
# New-AzureRmWebAppSlot -ResourceGroupName $DeploymentId -Name $cdAppName -Slot $StagingSlotName -AsJob | Show-JobProgress

# 3
# Wait for previous jobs to finish
. "./deploy-xp1-dev.ps1" `
    -Environment $Environment
    -ResourceGroupName $DeploymentId `
    -StorageResourceGroup $StorageResourceGroup `
    -StorageAccountName $StorageAccountName `
    -StorageContainerName $StorageContainerName `
    -Location $Location `
    -AzureToolkit $AzureToolkit `
    -SitecoreAdminPassword $SitecoreAdminPassword `
    -SqlServerFqdn $SqlServerFqdn `
    -SqlServerLogin $SqlServerLogin `
    -SqlServerPassword $SqlServerPassword `
    -StorageResourceGroup $StorageResourceGroup `
    -StorageAccountName $StorageAccountName `
    -StorageContainerName $StorageContainerName `
  

