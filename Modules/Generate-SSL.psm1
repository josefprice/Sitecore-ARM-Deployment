function Invoke-CreateSelfSignedCertificate {
    param (
        [Parameter(Mandatory=$True, HelpMessage="New Certificate File Path")]    
        [string]$CertificateFilePath,
        [Parameter(Mandatory=$True, HelpMessage="New Certificate Password")]    
        [securestring]$CertificatePassword
    )

    # Delete Existing Certificate 
    if(Test-Path $CertificateFilePath) {
        Remove-Item $CertificateFilePath
    }

    $thumbprint = (New-SelfSignedCertificate `
    -Subject "CN=$env:COMPUTERNAME @ Sitecore, Inc." `
    -Type SSLServerAuthentication `
    -FriendlyName "$env:USERNAME Certificate").Thumbprint

    # $certificateFilePath = "D:\Temp\$thumbprint.pfx"
    Export-PfxCertificate `
        -cert cert:\LocalMachine\MY\$thumbprint `
        -FilePath "$CertificateFilePath" `
        -Password $CertificatePassword
        #-Password (Read-Host -Prompt "Enter password that would protect the certificate" -AsSecureString)
}
