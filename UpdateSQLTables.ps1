﻿<#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER SkipDeviceFields
	Comma separated list of device related fields.
	Any field given here is removed from SQL injection object, so the information in the fields is not passed to SQL database.

	.EXAMPLE
	PS> UpdateSQLTables.ps1 -SkipDeviceFields lastLoggedInUser,systemInfo.username

	.LINK
	GitHub: https://github.com/aaronengels/DrmmToPowerBI
#>

Param
(
	[Parameter(Mandatory=$False)]
    [string[]]$SkipDeviceFields

)
BEGIN {

	try {

		# Get DrmmToPowerBI registry values
		$Config = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\DrmmToPowerBI -ErrorAction SilentlyContinue
		if (!$Config) {
			Write-Output 'Registry keys not found. Please import DrmmToPowerBI.reg first!'
			exit 1
		}
		if ( $null -ne $env:DrmmToPowerBICredentialKey ) {
			$EncryptionKeyBytes = ( [system.Text.Encoding]::UTF8 ).GetBytes( $env:DrmmToPowerBICredentialKey )
			$Config.SQLPassword = $Config.SQLPassword | ConvertTo-SecureString -Key $EncryptionKeyBytes |
			ForEach-Object { [Runtime.InteropServices.Marshal]::PtrToStringAuto( [Runtime.InteropServices.Marshal]::SecureStringToBSTR( $_ ) ) }
			$Config.APISecretKey = $Config.APISecretKey | ConvertTo-SecureString -Key $EncryptionKeyBytes |
			ForEach-Object { [Runtime.InteropServices.Marshal]::PtrToStringAuto( [Runtime.InteropServices.Marshal]::SecureStringToBSTR( $_ ) ) }
		}

		# Import Datto RMM Module
		Remove-Module SQLPS -ErrorAction SilentlyContinue
		Import-Module DattoRMM -Force

		# Set Datto RMM API Parameters
		$apiParams = [ordered]@{
				Url       =  $Config.APIUrl
				Key       =  $Config.APIKey
				SecretKey =  $Config.APISecretKey
		}

		# Set Datto RMM API Parameters
		Set-DrmmApiParameters @apiParams -ErrorAction Stop

		# Import SQL Server Module
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

		# Truncate SQL temp tables
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.sites"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.devices"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.alerts"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.patchstatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.thirdpartystatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.avstatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.agentstatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.diskstatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "TRUNCATE TABLE temp.udfs"

	}
	catch {

		$_.Exception.Message
	}
}

PROCESS {


	try {

		# Insert API site data into SQL temp table
		foreach($site in Get-DrmmAccountSites) {

			# Convert API data to JSON	
			$json = $site | ConvertTo-Json

			# Insert site data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertSite N'$json'"

		}

		# Insert API device data into SQL temp table
		foreach($device in Get-DrmmAccountDevices) {

			# Add addtional audit data if possible
			if($device.deviceClass -eq 'device') {
				$audit = Get-DrmmAuditDevice $device.uid
				$device | Add-Member -NotePropertyName bios -NotePropertyValue $audit.bios
				$device | Add-Member -NotePropertyName systemInfo -NotePropertyValue $audit.systemInfo
				$device | Add-Member -NotePropertyName logicalDisks -NotePropertyValue $audit.logicalDisks
			}

			# Remove given device field properties from device object before injecting to SQL
			if ($SkipDeviceFields) {
                foreach ($skipDeviceField in $SkipDeviceFields) {
					if ($skipDeviceField -like "*.*") {
						$lastInstance = $skipDeviceField.IndexOf('.')
						$devicePropertyGroup = $($skipDeviceField.Substring(0,$lastInstance))
						$deviceProperty = $($skipDeviceField.Substring($lastInstance + 1,$skipDeviceField.Length - $lastInstance - 1))
						if ($device -and (Get-Member -InputObject $device."$devicePropertyGroup" -Name $deviceProperty -MemberType Properties)) {
						    $device."$devicePropertyGroup".PSObject.properties.remove($deviceProperty)
                        }
					} else {
						if ($device -and (Get-Member -InputObject $device -Name $skipDeviceField -MemberType Properties)) {
						    $device.PSObject.properties.remove($skipDeviceField)
                        }
					}
				}
            }

			# Convert API device data to JSON
			$json = $device | ConvertTo-Json

			# Insert device data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertDevice N'$json'"

			# Insert device Patch Status data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertPatchStatus N'$json'"

			# Insert device Third Party Status data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertThirdPartyStatus N'$json'"

			# Insert device AV Status data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertAVStatus N'$json'"

			# Insert device Agent Status data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertAgentStatus N'$json'"

			# Insert device UDF data into SQL temp table
			Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertUDFs N'$json'"

			# Insert device Disk Status data into SQL temp table
			foreach ($disk in $device.logicalDisks) {
				$disk | Add-Member -NotePropertyName deviceId -NotePropertyValue $device.id
				$jsonDisk = $disk | ConvertTo-Json
				Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertDiskStatus N'$jsonDisk'"
			}

			# Insert device alert data into SQL temp table
			foreach($alert in Get-DrmmDeviceOpenAlerts $device.uid) {
				$alert | Add-Member -NotePropertyName deviceId -NotePropertyValue $device.id
				$json = $alert | Add-DrmmAlertMessage | ConvertTo-Json
				Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.insertAlert N'$json'"
			}
		}
	}
	catch {

		$_.Exception.Message
	}
}


END {

	try {

		# Merge SQL temp tables
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeSites"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeDevices"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeAlerts"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergePatchStatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeThirdPartyStatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeAvStatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeAgentStatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeDiskStatus"
		Invoke-Sqlcmd -ConnectionString $connString -QueryTimeout 0 -Query "EXEC drmm.mergeUDFs"
	}
	catch {

		$_.Exception.Message
	}
}