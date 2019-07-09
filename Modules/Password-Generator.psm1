Function New-Password {
 
    [cmdletbinding()]
 
    Param (
        [parameter()]
        [ValidateRange(1,128)]
        [Int]$PasswordLength = 15,
        [parameter()]
        [Int]$NumNonAlphaNumeric = 7,
        [parameter()]
        [switch] $AsSecureString
    )
 
    If ($NumNonAlphaNumeric -gt $PasswordLength) {
        Write-Warning ("NumNonAlphaNumeric ({0}) cannot be greater than the PasswordLength ({1})!" -f`
            $NumNonAlphaNumeric,$PasswordLength)
        Break
    }
 
    Add-Type -AssemblyName System.Web
    $pasword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,$NumNonAlphaNumeric)
    If ($AsSecureString) {
        return ConvertTo-SecureString $pasword -AsPlainText -Force
    } Else {
        return $pasword
    }
}

Function Convert-SecurePasswordToPlainText {
    
    [cmdletbinding()]
 
    Param (    
        [parameter()]
        [securestring] $SecureString
    )

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
}