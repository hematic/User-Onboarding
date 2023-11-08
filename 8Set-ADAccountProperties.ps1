Try {
    Write-Host "Retrieving template data from file..."
    $Template = Get-content -Path "$ENV:Workspace\$ENV:Code-Template.txt" -ErrorAction Stop | ConvertFrom-JSON
    Write-Host "Retrieving AD Object data from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" -ErrorAction Stop | ConvertFrom-JSON
}
Catch {
    Write-host $_
    exit 1
}


try {
    $Props = @{
        Identity      = $Joiner.SamAccountName
        Fax           = $Template.Fax
        Company       = $Template.Company
        OfficePhone   = $Template.OfficePhone
        Description   = $Env:Description
        HomeDrive     = "H:"
        HomeDirectory = $Env:HomeDirectory
        ErrorAction   = 'Stop'
        Server        = $ENV:DC
    }
    Write-Host "Setting properties in active directory..."
    Set-ADUser @Props 
    Set-ADUser -Identity $Joiner.SamAccountName  -ChangePasswordAtLogon $True -Server $ENV:DC -ErrorAction Stop
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Template used was      : $($Template.samaccountname)"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Description set was    : $Env:Description"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Company set was        : $Env:Company"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Homedirectory set was  : $Env:HomeDirectory"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Fax set was            : $($Template.Fax)"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "OfficePhone set was    : $($Template.OfficePhone)"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Homedrive set was      : H:"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Account Enabled in AD."
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Change password at next logon enforced."
}
catch {
    Write-host $_
    exit 1
}