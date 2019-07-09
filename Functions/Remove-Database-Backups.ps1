 param (
    [Parameter(Mandatory=$True)]
    [string]$DataseMatchName,
    [Parameter(Mandatory=$True)]
    [string]$CurrentDatabaseBackupName,
    [Parameter(Mandatory=$True)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$True)]
    [string]$DbServerName,
    [Parameter(Mandatory=$False)]
    [int]$RetainedDays = 7
)

Write-Host "----------------------------------------------------- `n"
Write-Host " Database backup cleanup"
Write-Host " Info: Any backup databases older than $RetainedDays days, with the name of $DataseMatchName will be removed."
Write-Host "----------------------------------------------------- `n"

$archiveBoundary = (Get-Date).AddDays(-$RetainedDays).ToString('yyyyMMdd')

$databases = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $DbServerName `
                | Where-Object { 
                        $_.DatabaseName -Match $DataseMatchName -and `
                        $_.DatabaseName -Match "backup" ` -and # Double Check Database name does contain backup
                        $_.DatabaseName -ne $CurrentDatabaseBackupName -and `
                        ($_.DatabaseName -split '-backup-')[1] -lt $archiveBoundary
                    }

foreach($database in $databases) {
    Write-Host "Removing database: $($database.DatabaseName)" -ForegroundColor Yellow
    #Remove the database
    Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $DbServerName -DatabaseName $database.DatabaseName
}
