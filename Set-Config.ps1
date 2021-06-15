$SQLServer = Read-Host "SQL Server"
$SQLDatabase = Read-Host "SQL Database"
$SQLUser = Read-Host "SQL User"
$SQLPassword = Read-Host "SQL Password"
$APIUrl = Read-Host "API Url"
$APIKey = Read-Host "API Access Key"
$APISecretKey = Read-Host "API Secret Key"
[string]$Encrypt = Read-Host "Store passwords in encrypted format? [Y]es or [N]o"

if ( $Encrypt.Substring(0,1).ToLower() -eq 'y' ) {
    Function New-EncryptedString {
        param (
            [string]$PlainText,
            [Byte[]]$EncryptionKeyBytes
        )
        
        $SecureString = New-Object System.Security.SecureString
        foreach ( $Char in $PlainText.toCharArray() ) {
            $SecureString.AppendChar( $Char ) 
        }
        Return ConvertFrom-SecureString -SecureString $SecureString -Key $EncryptionKeyBytes
    }

    $EncryptionKey = ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 32 | ForEach-Object {[char]$_}) )
    $EncryptionKeyBytes = ([system.Text.Encoding]::UTF8).GetBytes($EncryptionKey)
    $SQLPassword = New-EncryptedString -PlainText $SQLPassword -EncryptionKeyBytes $EncryptionKeyBytes
    $APISecretKey = New-EncryptedString -PlainText $APISecretKey -EncryptionKeyBytes $EncryptionKeyBytes

    Write-Host "Your encryption key is `n`n$EncryptionKey`n`nWhen running UpdateSQLTables.ps1 pass this value as `$env:DrmmToPowerBICredentialKey.`nIf you lose it it cannot be recovered."
}

Function Set-RegistryKeyValue {
    param (
        [string]$Path,
        [string]$Key,
        [string]$Value
    )
    if ( !( Test-Path $Path ) ) {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Key -Value $Value -PropertyType "Unknown" -Force | Out-Null
}

Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "SQLServer" -Value $SQLServer
Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "SQLDatabase" -Value $SQLDatabase
Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "SQLUser" -Value $SQLUser
Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "SQLPassword" -Value $SQLPassword
Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "APIUrl" -Value $APIUrl
Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "APIKey" -Value $APIKey
Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\DrmmToPowerBI" -Key "APISecretKey" -Value $APISecretKey