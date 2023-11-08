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
$database_name_filter = $ENV:mailboxregion + "DB3*"
Try{
    $Databases = Get-MailboxDatabase $database_name_filter -Status -ErrorAction Stop -WarningAction SilentlyContinue
}
Catch{
    Write-Error $_
    Return 'ERR'
}

[Float]$CurrentMaxSize = 0
[String]$BestDB = ''

$Databases = $Databases | Where-object {$_.IsExcludedFromProvisioning -ne $true -and $_.IsSuspendedFromProvisioning -ne $true}

Foreach ($Database in $Databases) {
    Try{
        $FreeBytes = ([regex]::matches($Database.AvailableNewMailboxSpace, "(?:\()([\S]+)")).groups[1].value
        $Freebytes = $Freebytes -replace ",", ""
        [Float]$Freebytes = $Freebytes / 1GB
        If ($Freebytes -gt $CurrentMaxSize) {
            $CurrentMaxSize = $FreeBytes
            $BestDB = $Database.name
        }
    }
    Catch{
        Write-Host "$_" -ForegroundColor Red
        Continue;
    }
}
Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Mailbox Database is    : $($bestDB)"
Write-Output $BestDB
#Return $BestDB
