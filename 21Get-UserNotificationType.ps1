try {
    Write-Host "Retrieving AD Object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" -ErrorAction Stop | ConvertFrom-JSON
}
catch {
    Write-Host $_
    exit 1
}

$NoEmailOffices = @('Singapore', 'London')
$NoNSAEmail = @('London')
$Template2Offices = @('Helsinki', 'Stockholm', 'Astana')

If ($Joiner.employeeType -like '*NSA*') {
    If ($Location -notin $NoNSAEmail) {
        Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "User notification type : NSA"
        Return 'nsa'
    }
    Else {
        Write-Host "No NSA Email was sent because the user is in the location : $Location"
        Write-Host "No password Email was sent because the user is in the location : $Location"
        Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "No user or password notification email will be sent because of the location."
        Return 'false'
    }
}
ElseIf ($Location -in $NoEmailOffices) {
    Write-host "No `"New User Notification Email`" will be sent because this user is in $Location"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "No user or password notification email will be sent because of the location."
    Return 'false'
}
ElseIf ($Location -in $Template2Offices) {
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "User notification type : template 2)"
    Return 'template 2'
}
Else {
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "User notification type : default)"
    Return 'default'
}