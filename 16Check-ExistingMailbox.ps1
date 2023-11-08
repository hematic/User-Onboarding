#Add the snappin
Try{
    #TODO
    $exchangeServer = "ExchangeServer1","ExchangeServer1","ExchangeServer1","ExchangeServer1" | Where-Object {
        Test-Connection -ComputerName $_ -Count 1 -Quiet
    } | Get-Random
    #TODO
    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri ("http://{0}.sub.domain.com/PowerShell" -f $exchangeServer)
    write-host "Connecting to $ExchangeServer" -foreground Green
    $null = Import-PSSession $ExchangeSession -DisableNameChecking
}
Catch{
    Write-Error $_
    exit 1 
}

$Mailbox = Get-Mailbox $ENV:Samaccountname -ErrorAction SilentlyContinue 
if ($Mailbox) {
    Write-Error "Mailbox Already Exists for SamAccountName : $($Joiner.samaccountname)"
    exit 1
}
Else{
    Write-Host "No mailbox was found matching the samaccountname" -ForegroundColor Green
}

