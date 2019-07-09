function ProvisionNewSitecoreEnvironment()
{
    param (
        [Parameter(Mandatory=$True, HelpMessage="Version number of Sitecore.")]    
        [string]$SitecoreVersion,

        [Parameter(Mandatory=$True, HelpMessage="Build number of Sitecore.")]    
        [string]$SitecoreBuildNumber,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore License path")]    
        [string]$SitecoreLicensePath,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore admin password")]    
        [securestring]$SitecoreAdminPassword,

        [Parameter(Mandatory=$True, HelpMessage="The UR: to the ARM Template")]    
        [string]$ARMTemplateUrl,

        [Parameter(Mandatory=$True, HelpMessage="Name of the parameter file in the environment directory")]    
        [string]$ParamFileName,

        [Parameter(Mandatory=$True, HelpMessage="Name of the environment must equal the environment directory name in the deploy folder.")]    
        [Alias("e")]
        [string]$Environment,
    
        [Parameter(Mandatory=$True, HelpMessage="Corresponds to name of resource group")]
        [Alias("d")]
        [string]$DeploymentId, 

        [Parameter(HelpMessage="Location of the PAAS infrastructure. Defaults to UK South")]
        [Alias("l")]
        [string]$Location="UK South",

        [Parameter(HelpMessage="Location of the Azure Toolkit")]
        [Alias("atk")]
        [string]$AzureToolkit="C:\Sitecore\Sitecore Azure Toolkit 2.2.0 rev. 190305",

        [Parameter(Mandatory=$True, HelpMessage="Id of the PAAS subscription")]
        [Alias("s")]
        [string]$SubscriptionId,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore Packages Storage Resource Group")]
        [Alias("strg")]
        [string]$StorageResourceGroup,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore Packages Storage Account Name")]
        [Alias("stan")]
        [string]$StorageAccountName,

        [Parameter(Mandatory=$True, HelpMessage="Sitecore Storage Account Container Name")]
        [Alias("stacn")]
        [string]$StorageContainerName

    )

    ##########################################################################
    $PSScriptRootParent = Split-Path $PSScriptRoot -Parent
    $EnvironmentFolder = Join-Path $PSScriptRootParent "ARM\Sitecore $SitecoreVersion\$($Environment)\"
    $TempFolder = Join-Path $PSScriptRootParent "_Temp"

    $ArmParametersPath = $EnvironmentFolder + $ParamFileName
    $authCertificateBlobFilePath = Join-Path $TempFolder "authCertificate.pfx"
    $machineLearningCertificateBlobFilePath  = Join-Path $TempFolder "machineLearningCertificate.pfx"

    $sqlServerPassword = New-Password -PasswordLength 18 -NumNonAlphaNumeric 3

    if(![System.IO.File]::Exists($SitecoreLicensePath)) {
        throw "SitecoreLicensePath doesn't exist `n $SitecoreLicensePath" 
    }

    # Create Self-Signed SSL Certificate !!! (Maybe change to use Lets Encrypt) !!!
   
    $authCertificatePassword = New-Password -PasswordLength 18 -NumNonAlphaNumeric 5
    $authCertificatePasswordSecure = ConvertTo-SecureString $authCertificatePassword -AsPlainText -Force
    Invoke-CreateSelfSignedCertificate -CertificateFilePath $authCertificateBlobFilePath -CertificatePassword $authCertificatePasswordSecure

    $machineLearningCertificatePassword = New-Password -PasswordLength 18 -NumNonAlphaNumeric 5
    $machineLearningCertificatePasswordSecure = ConvertTo-SecureString $machineLearningCertificatePassword -AsPlainText -Force
    Invoke-CreateSelfSignedCertificate -CertificateFilePath $machineLearningCertificateBlobFilePath -CertificatePassword $machineLearningCertificatePasswordSecure
   
    Write-Host "authCertificatePassword $authCertificatePassword"
    Write-Host "machineLearningCertificatePasswordSecure $machineLearningCertificatePassword"
    
    ##########################################################################

    LoginAzureSubscription -UseServicePrinciple $False -SubscriptionId $SubscriptionId

    # Get WDP URLS with SAS Tokens
    $storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $StorageResourceGroup -Name $StorageAccountName

    $cmMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_cm.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount
                                
    $cdMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_cd.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $prcMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_prc.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $repMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_rep.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $xcRefDataMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1referencedata.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $xcCollectMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1collection.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $xcSearchMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1collectionsearch.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $cortexProcessingMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1cortexprocessing.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $cortexReportingMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1cortexreporting.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $maOpsMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1marketingautomation.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $maRepMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore $SitecoreVersion rev. $SitecoreBuildNumber (Cloud)_xp1marketingautomationreporting.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    $siMsDeployPackageUrl = Get-StorageAccessToken `
        -PackageName "Sitecore.IdentityServer.2.0.1-r00166.scwdp.zip" `
        -ContainerName $StorageContainerName `
        -PSStorageAccount $storageAccount

    # read the contents of your Sitecore license file
    # read the contents of your authentication certificate
    if ($authCertificateBlobFilePath) {
        $authCertificateBlob = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($authCertificateBlobFilePath))
    }

    # if ($machineLearningCertificateBlobFilePath) {
    #     $machineLearningCertificateBlob = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($machineLearningCertificateBlobFilePath))
    # }

    $Parameters = @{}
    $Parameters.Add("deploymentId",$DeploymentId)
    $Parameters.Add("location",$Location)
    $Parameters.Add("authCertificateBlob",$authCertificateBlob)
    $Parameters.Add('authCertificatePassword',$authCertificatePassword)

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

    #Credentials
    $SitecoreAdminPasswordPlain = Convert-SecurePasswordToPlainText $SitecoreAdminPassword

    $Parameters.Add('sitecoreAdminPassword', 'f£4C@dcDSklwoo9')

    $Parameters.Add('sqlServerLogin', "scSqlAdmin")
    $Parameters.Add('sqlServerPassword', $sqlServerPassword) 

    Import-Module $AzureToolkit\tools\Sitecore.Cloud.Cmdlets.psm1
    Start-SitecoreAzureDeployment `
        -Name $DeploymentId `
        -Location $Location `
        -ArmTemplateUrl $ARMTemplateUrl `
        -ArmParametersPath $ArmParametersPath `
        -LicenseXmlPath $SitecoreLicensePath `
        -SetKeyValue $Parameters
    
    Write-Host "#######################################################"
    Write-Host "# Sitecore Deployment Details                         #"
    Write-Host "# SQL                                                 #"
    Write-Host "#   - Login: scSqlAdmin                               #"
    Write-Host "#   - Password: $sqlServerPassword                    #"
    Write-Host "# Sitecore                                            #"
    Write-Host "#   - Login: admin                                    #"
    Write-Host "#   - Password: $SitecoreAdminPasswordPlain           #"
    Write-Host "#######################################################"

}