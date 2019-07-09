
    function Get-StorageAccessToken()
    {
        param (
            [Parameter(Mandatory=$True, HelpMessage="Sitecore Web Deploy Package Name")]    
            [string]$PackageName,          

            [Parameter(Mandatory=$True, HelpMessage="Azure Storage Container Name")]    
            [string]$ContainerName,

            [Parameter(Mandatory=$True, HelpMessage="Storage Account")]    
            [Object]$PSStorageAccount
        )

        $msDeployPackageUrl = New-AzureStorageBlobSASToken -Container $ContainerName `
            -Blob $PackageName `
            -Permission r `
            -StartTime (Get-Date) `
            -ExpiryTime (Get-Date).AddHours(1) `
            -Context $PSStorageAccount.Context `
            -FullUri
       
        return $msDeployPackageUrl
    }    