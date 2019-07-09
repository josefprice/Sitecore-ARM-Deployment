 param( 
    [string]$ResourceGroup, 
    [string]$WebAppName, 
    [string]$Slot, 
    [hashtable]$ConnectionStrings
)

Write-Host "Loading Existing Connectionstrings"
$webApp = Get-AzureRmWebAppSlot -ResourceGroupName  $ResourceGroup -Name $WebAppName -Slot $Slot

Write-Host "Applying New Connectionstrings"
$hash = @{}
# adds existings connections strings to the hash so they are lost
ForEach ($kvp in $webApp.SiteConfig.ConnectionStrings) {
    $hash[$kvp.Name] = @{ Type=$kvp.Type; Value = $kvp.ConnectionString } 
}

# adds new connection strings to has
ForEach ($key in $ConnectionStrings.Keys) {
    $hash[$key] = $ConnectionStrings[$key]
}

Write-Host "Saving ConnectionStrings"
Write-Host $hash
Set-AzureRMWebAppSlot -ResourceGroupName $ResourceGroup -Name $WebAppName -ConnectionStrings $hash -Slot $Slot | Out-Null
Write-Host "ConnectionStrings Updated"