# By default this script will prompt you for your Azure credentials but you can update the script to use an Azure Service Principal instead by following the details at the link below and updating the four variables below once you are done.
# https://azure.microsoft.com/en-us/documen tation/articles/resource-group-authenticate-service-principal/

function LoginAzureSubscription()
{
    param (
        [Parameter()]
        [string]$SubscriptionId,
    
        [Parameter()]
        [string]$TenantId = "your tenant id", 

        [Parameter()]
        [string]$ApplicationId,

        [Parameter()]
        [string]$ApplicationPassword,

        [Parameter()]
        [string]$UseServicePrinciple = $true
    )
    
    Write-Host "Setting Azure RM Context..."

    if($UseServicePrinciple -eq $true)
    {
        #region Use Service Principle
        $secpasswd = ConvertTo-SecureString $ApplicationPassword -AsPlainText -Force
        $mycreds = New-Object System.Management.Automation.PSCredential ($ApplicationId, $secpasswd)

        Login-AzureRmAccount -ServicePrincipal -Tenant $TenantId -Credential $mycreds

        Set-AzureRmContext -SubscriptionID $SubscriptionId -TenantId $TenantId;
        #endregion
    }
    else
    {
        #region Use Manual Login
        if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount}
        
        Set-AzureRmContext -SubscriptionID $SubscriptionId -ErrorAction Stop
        #endregion
    }
}