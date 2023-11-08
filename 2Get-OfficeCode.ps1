#Environtment Variables Used : Location
Try {
	Write-Host "Retrieving 3 digit office code..."
	$Code = Get-WCOffice -Offices $ENV:location | Select -expand OfficeCode -ErrorAction Stop
	Return $Code
}
Catch {
	Write-Host $_
	Return 'ERR'
}