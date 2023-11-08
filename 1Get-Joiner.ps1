#ENV Variables used : Samaccountname,Workspace

try {
    $Properties = @('City',
        'Company',
        'Country',
        'Department',
        'Description',
        'DisplayName',
        'Distinguishedname',
        'employeeID',
        'employeeNumber',
        'employeetype',
        'Fax',
        'Givenname',
        'HomeDirectory',
        'HomeDrive',
        'l', 
        'Office',
        'OfficePhone',
        'PostalCode',
        'Samaccountname',
        'State',
        'StreetAddress',
        'Surname',
        'Title',
        'wcCurrentHireDate',
        'wcJobRoleLevel1',
        'wcJobRoleLevel3',
        'wcJobRoleLevel4',
        'wcPhysicalOfficeName'
    )

    Write-Host "Retrieving user: $ENV:Samaccountname from AD..."
    $Joiner = Get-ADUser -Identity $ENV:Samaccountname -Properties $Properties -Server $ENV:DC -ErrorAction Stop
    Write-Host "Creating/Updating user property text file..."
    $Joiner | Select-Object -Property $Properties | ConvertTo-JSON | Out-File "$ENV:Workspace\$($Joiner.samaccountname)-ADObject.txt" -Force
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Start of Logging..." -ErrorAction Stop
}
catch {
    Write-Host $_
    exit 1
}
