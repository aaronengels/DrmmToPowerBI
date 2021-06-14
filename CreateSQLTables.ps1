# Get DrmmToPowerBI registry values
$Config = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\DrmmToPowerBI -ErrorAction SilentlyContinue
if (!$Config) {
	Write-Host 'Registry keys not found. Please import DrmmToPowerBI.reg first!'
	exit 1
}

# Import Module
Remove-Module SQLPS
Import-Module SQLServer -Force

# Create SQL Connection Parameters
$sqlParams = [ordered]@{
	Server     =  $Config.SQLServer
	Database   =  $Config.SQLDatabase
	User       =  $Config.SQLUser
	Password   =  $Config.SQLPassword
}

# Create SQL Connection String
$connString = 'Server={0};Database={1};User Id={2};Password={3};' -f [array]$sqlParams.Values

# Run SQL query to Create SQL Tables
Invoke-Sqlcmd -ConnectionString $connString -InputFile 'CreateSQLTables.sql'