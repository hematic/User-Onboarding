Try {
    Write-Host "Retrieving template from file..."
    $Template = Get-content -Path "$ENV:Workspace\$ENV:Code-Template.txt" | ConvertFrom-JSON
    $Region = Get-wcOffice -Offices $ENV:Location | Select -ExpandProperty RegionShortCode
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Mailbox region is      : $($Region)"
    Write-Output $Region
}
Catch {
    Write-Error $_
    Return 'ERR'
}