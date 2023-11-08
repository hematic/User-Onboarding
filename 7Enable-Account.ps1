Try {
    Write-Host "Retrieving AD object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" -ErrorAction Stop | ConvertFrom-JSON
    Write-Host "Enabling account in AD.."
    Enable-ADAccount -Identity $Joiner.Samaccountname -Server $ENV:DC -ErrorAction Stop
}
Catch {
    Write-Host $_
    exit 1
}