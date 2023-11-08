#Environment Variables Used : Workspace
Try {
    $Properties = @('Samaccountname', 'Department', 'Title', 'Location', 'Description',
        'StreetAddress', 'City', 'State', 'PostalCode', 'Fax', 'Company',
        'Country', 'OfficePhone', 'HomeDrive', 'HomeDirectory')

    $Name = $ENV:Code + "-template"
    Write-Host "Retrieving template: $Name from AD..."
    $Template = Get-ADUser -Identity $Name -Properties $Properties -Server $ENV:DC -ErrorAction Stop
    Write-Host "Writing template to file..."
    $Template | Select-Object -Property $Properties | ConvertTo-JSON | Out-File "$ENV:Workspace\$($Template.samaccountname).txt" -Force
    Return $($Template.samaccountname)
}
Catch {
    Write-Host $_
    Return 'ERR'
}