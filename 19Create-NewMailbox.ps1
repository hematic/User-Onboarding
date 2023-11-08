Function Get-NewSMTPAddressInfo {
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$FirstName,
        [Parameter(Mandatory = $True, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$LastName
    )
    #First Names with spaces.
    $FirstName = $FirstName -replace "\s", "."

    #Last Names With Spaces
    If ($Lastname -like '* *') {
        If ($LastName -like "Von *" -or $LastName -like "Van *") {
            $LastName = $LastName -replace "\s", ""
        }
        Else {
            $LastName = $LastName -replace "\s", "."
        }
    }
    #TODO
    $SMTPAddress = ($Firstname + '.' + $LastName + '@DOMAIN.com').tolower()
    $obj = New-Object -TypeName psobject -Property @{
        SMTPAddress = $SMTPAddress
        Firstname   = $FirstName
        Lastname    = $LastName
    }
    $obj
}

Function Get-WorkingSecondaryAddress {
    Param(
        [psobject]$User,
        [Int]$Count
    )
    $max = $User.firstname.length
    If ($Count -gt $max) {
        Write-Error 'Unable to create an available secondary address. All permutations are taken.'
        Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "ERROR!!! Secondary SMTP is unsettable"
        Return $Null
    }
    Try {
        #TODO
        $address = $User.firstname.substring(0, $Count) + $User.lastname + '@DOMAIN.com'
        Write-Host "Trying address : $address"
        $Mailbox = Get-Mailbox $Address -ErrorAction stop
        $Count++
        Write-Host "Address Taken." -ForegroundColor Yellow
        Get-WorkingSecondaryAddress -User $user -Count $Count
    }
    Catch {
        Return $Address.tolower()
    }
}
    
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
Catch {
    Write-Error $_
    exit 1 
}

#Gather the user object and create the addresses
Try {
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" | ConvertFrom-JSON
    # When you use the PrimarySmtpAddress parameter the EmailAddressPolicy is automatically disabled.
    $obj = Get-NewSMTPAddressInfo -Firstname $joiner.givenname -LastName $Joiner.Surname
    $obj.smtpaddress | Out-file -FilePath "$ENV:Workspace\$($ENV:samaccountname)-smtpaddress.txt"
    #TODO
    $Alias = $obj.smtpaddress -replace '@DOMAIN.com', ''
    $EmailAddress2 = Get-WorkingSecondaryAddress -User $obj -Count 1 -ErrorAction Stop
    $EmailAddress2 = 'smtp:' + $EmailAddress2
    #TODO
    $SipAddress = 'sip:' + $joiner.samaccountname + '@DOMAIN.com'
}
Catch {
    Write-Error $_
    exit 1 
}
#Enable the Mailbox
Try {
    #TODO
    $domaincontroller = $ENV:DC + '.SUB.DOMAIN.com'
    Enable-Mailbox -Identity $Joiner.SamAccountName -Database $ENV:MailboxDatabase -PrimarySmtpAddress $obj.smtpaddress -Alias $Alias -DomainController $domaincontroller -ErrorAction Stop | Out-Null
    Write-Host "Mailbox created for $($Joiner.samaccountname)" -ForegroundColor Green
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Mailbox created successfully."
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Primary SMTP is        : $($obj.smtpaddress)"
}
Catch {
    Write-Error $_
    exit 1 
}
#Set the secondary addresses
Try {
    Set-Mailbox -Identity $Joiner.SamAccountName -EmailAddresses @{Add = "$EmailAddress2", "$SipAddress" } -DomainController $domaincontroller -ErrorAction Stop
    Set-Mailbox -Identity $Joiner.SamAccountName -AuditEnabled $TRUE -DomainController $domaincontroller -ErrorAction Stop
    Write-Host "SMTP and SIP addresses set" -ForegroundColor Green
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Secondary SMTP IS      : $($emailaddress2)"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Alias is               : $($Alias)"
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Sip address is         : $($sipaddress)"
}
Catch {
    Write-Host $_
    #exit 1 
}
#Enable and disable other misc settings
Try {
    Set-CASMailbox -Identity $Joiner.Samaccountname -MapiHttpEnabled $True -IMAPEnabled $False -PopEnabled $False -OwaMailboxPolicy "Default" -DomainController $domaincontroller -ErrorAction Stop
    $abp = "White*"
    Set-Mailbox -identity $Joiner.Samaccountname -AddressBookPolicy $abp -DomainController $domaincontroller -ErrorAction Stop
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "IMAP and POP disabled. MAPI enabled."

}
Catch {
    Write-Error $_
    exit 1 
}