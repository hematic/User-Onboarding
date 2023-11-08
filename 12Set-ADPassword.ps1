try {
    $SecureString = ConvertTo-SecureString $ENV:RandomPassword -AsPlainText -Force
    Write-Host "Setting password on account in AD..."
    Set-ADAccountPassword -Identity $Env:Samaccountname -NewPassword $SecureString -Server $ENV:DC -Reset -ErrorAction Stop
    Set-ADUser -Identity $Env:Samaccountname -Server $ENV:DC -ChangePasswordAtLogon $true -ErrorAction Stop
}
catch {
    write-host $_
    exit 1  
}