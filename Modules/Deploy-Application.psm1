function DeploySitecoreApplication()
{
    param (
        [Parameter(Mandatory=$True, HelpMessage="Name of the environment must equal the environment directory name in the deploy folder.")]    
        [string]$ARMTemplateFile,

        [Parameter(Mandatory=$True, HelpMessage="Name of the parameter file in the environment directory")]    
        [string]$ParamFileName,

        [Parameter(Mandatory=$True, HelpMessage="Name of the environment must equal the environment directory name in the deploy folder.")]    
        [string]$Environment,
    
        [Parameter(Mandatory=$True, HelpMessage="Corresponds to name of resource group")]
        [string]$DeploymentId, 

        [Parameter(HelpMessage="Location of the PAAS infrastructure. Defaults to Uk South")]
        [string]$Location="UK South",

        [Parameter(HelpMessage="Location of the Azure Toolkit")]
        [string]$AzureToolkit="C:\Sitecore\Sitecore Azure Toolkit 2.2.0 rev. 190305",

        [Parameter(Mandatory=$True, HelpMessage="Sql Server Fully Qualified Domain Name")]
        [string]$SqlServerFqdn,

        [Parameter(Mandatory=$True, HelpMessage="Sql Admin Username")]
        [string]$SqlServerLogin,

        [Parameter(Mandatory=$True, HelpMessage="Sql Admin Password")]
        [string]$SqlServerPassword,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore's Admin password")]
        [Alias("scPass")]
        [string]$SitecoreAdminPassword,

        [Parameter(Mandatory=$false, HelpMessage="Id of the PAAS subscription")]
        [string]$SubscriptionId,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore Packages Storage Resource Group")]
        [Alias("strg")]
        [string]$StorageResourceGroup,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore Packages Storage Account Name")]
        [Alias("stan")]
        [string]$StorageAccountName,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore Storage Account Container Name")]
        [Alias("stacn")]
        [string]$StorageContainerName,

        [Parameter(Mandatory=$false, HelpMessage="Prompt for Azure Login")]
        [switch]$PromptAzureLogin
    )

    if($PromptAzureLogin -and $SubscriptionId -eq "") {
        throw "Please supply a SubscriptionId as you have enabled PromptAzureLogin"
    }

    ##########################################################################

    $EnvironmentFolder = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "ARM\Sitecore 9.0.2\$($Environment)\"

    $ParamFile = Join-Path $EnvironmentFolder $ParamFileName
    $LicenseFile = Join-Path $EnvironmentFolder "license.xml"
    $CertificateFile = Join-Path $EnvironmentFolder "certificate.pfx"

    
    if(!(Test-Path $ARMTemplateFile)) {
        Write-Error "ARMTemplateFile camn't be found $ARMTemplateFile"
        throw
    }

    if(!(Test-Path $ParamFile)) {
        Write-Error "ParamFile camn't be found $ParamFile"
        throw
    }

    if(!(Test-Path $LicenseFile)) {
        Write-Error "LicenseFile camn't be found $LicenseFile"
        throw
    }

    ##########################################################################

    if($PromptAzureLogin) {
        Import-Module "$($PSScriptRoot)\login-azure-subscription.psm1" -Force
        LoginAzureSubscription -UseServicePrinciple $False -SubscriptionId $SubscriptionId
    }
    
    $certificate = Get-AzureRmWebAppCertificate -ResourceGroupName "$DeploymentId"
    $certificateThumbprint = $certificate.Thumbprint

    # Get WDP URLS with SAS Tokens
    $storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $StorageResourceGroup -Name $StorageAccountName

    $cmMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_cm.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount
                                
    $cdMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_cd.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $prcMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_prc.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $repMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_rep.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $xcRefDataMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1referencedata.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $xcCollectMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1collection.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $xcSearchMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1collectionsearch.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $cortexProcessingMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1cortexprocessing.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $cortexReportingMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1cortexreporting.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $maOpsMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1marketingautomation.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $maRepMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1marketingautomationreporting.withoutdb.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $siMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore.IdentityServer.2.0.1-r00166.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $Parameters = @{}
    $Parameters.Add("deploymentId",$DeploymentId)
    $Parameters.Add("authCertificateThumbprint","$certificateThumbprint")
    # $Parameters.Add("authCertificateThumbprint","C38BDCBEE7ADFD2BE192AE79EC24949FB5E6F7E0")

    # BEGIN SQL Parameters 
    $Parameters.Add("sqlServerFqdn",$SqlServerFqdn)
    $Parameters.Add("sqlServerLogin",$SqlServerLogin)
    $Parameters.Add("sqlServerPassword",$SqlServerPassword)
    #End SQL Parameters

    $Parameters.Add("sitecoreAdminPassword",$SitecoreAdminPassword)

    $Parameters.Add("cmMsDeployPackageUrl",$cmMsDeployPackageUrl)
    $Parameters.Add("cdMsDeployPackageUrl",$cdMsDeployPackageUrl)
    $Parameters.Add("prcMsDeployPackageUrl",$prcMsDeployPackageUrl)
    $Parameters.Add("repMsDeployPackageUrl",$repMsDeployPackageUrl)
    $Parameters.Add("xcRefDataMsDeployPackageUrl",$xcRefDataMsDeployPackageUrl)
    $Parameters.Add("xcCollectMsDeployPackageUrl",$xcCollectMsDeployPackageUrl)
    $Parameters.Add("xcSearchMsDeployPackageUrl",$xcSearchMsDeployPackageUrl)
    $Parameters.Add("cortexProcessingMsDeployPackageUrl",$cortexProcessingMsDeployPackageUrl)
    $Parameters.Add("cortexReportingMsDeployPackageUrl",$cortexReportingMsDeployPackageUrl)
    $Parameters.Add("maOpsMsDeployPackageUrl",$maOpsMsDeployPackageUrl)
    $Parameters.Add("maRepMsDeployPackageUrl",$maRepMsDeployPackageUrl)
    $Parameters.Add("siMsDeployPackageUrl",$siMsDeployPackageUrl)

    $Parameters.Add('repAuthenticationApiKey', "d005af2d-3101-418d-b2d6-ca2f3bd9b8cb") #TODO Make Dynamic

    Import-Module $AzureToolkit\tools\Sitecore.Cloud.Cmdlets.psm1 -Force
    Start-SitecoreAzureDeployment -Verbose `
        -Name $DeploymentId `
        -Location $Location `
        -ArmTemplatePath "$ARMTemplateFile"  `
        -ArmParametersPath $ParamFile  `
        -LicenseXmlPath $LicenseFile  `
        -SetKeyValue $Parameters
}