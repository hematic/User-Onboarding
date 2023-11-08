try {
    Write-Host "Retrieving AD Object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" -ErrorAction Stop | ConvertFrom-JSON
    
}
catch {
    Write-Host $_
    exit 1
}

If ($ENV:Type -eq 'Default') {
    $Params = @{
        Office       = $Joiner.wcPhysicalOfficeName
        Name         = $Joiner.DisplayName
        Title        = $Joiner.Title
        Department   = $Joiner.Department
        StartDate    = $Joiner.wcCurrentHireDate
        USERID       = $Joiner.samaccountname
        Emailaddress = $ENV:smtpAddress
        Phone        = $Joiner.OfficePhone
        TKNumber     = $Joiner.EmployeeID
        PSID         = $Joiner.EmployeeNumber
        NSA          = 'No'
    }
    $template = 'New Account Information Default'

}
ElseIf ($ENV:Type -eq 'Template 2') {
    $Params = @{
        Office       = $Joiner.wcPhysicalOfficeName
        Name         = $Joiner.DisplayName
        Title        = $Joiner.Title
        Department   = $Joiner.Department
        StartDate    = $Joiner.wcCurrentHireDate
        USERID       = $Joiner.samaccountname
        Emailaddress = $ENV:smtpAddress
        Phone        = $Joiner.OfficePhone
        Attorney     = $Joiner.EmployeeID
        PSID         = $Joiner.EmployeeNumber
        NSA          = 'No'
    }
    $template = 'New Account Information 2'
}
ElseIf ($ENV:Type -eq 'NSA') {
    $Params = @{
        Office       = $Joiner.wcPhysicalOfficeName
        Name         = $Joiner.DisplayName
        Title        = $Joiner.Title
        Department   = $Joiner.Department
        StartDate    = $Joiner.wcCurrentHireDate
        USERID       = $Joiner.samaccountname
        Emailaddress = $ENV:smtpAddress
        Phone        = $Joiner.Telephone
        TKNumber     = $Joiner.EmployeeID
    }
    $template = 'NSA'
}

Try {
    $Body = Get-content -Path "$ENV:Workspace\$template.html" -raw -ErrorAction Stop
}
Catch {
    Write-Host $_
    exit 1  
}

foreach ( $token in $Params.GetEnumerator() ) {
    $pattern = '#{0}#' -f $token.key
    $body = $body -replace $pattern, $token.Value
}

If ($Template -eq 'NSA') {
    #TODO
    $To = 'EMAIL_ADDRESS
}
Else {
    #TODO
    $To = "$($ENV:Code)NewUserAccountNotification@groups.DOMAIN.com"
}

If ($Env:Attachment) {
    Try {
        $Splat = @{
            #TODO
            To         = 'EMAIL_ADDRESS
            Subject    = "New Employee Account Information | $($Params.name)"
            #TODO
            From       = 'EMAIL_ADDRESS
            #TODO
            CC         = 'EMAIL_ADDRESS
            SMTPServer = 'AM1SMTP'
            BodyAsHTML = $True
            Body       = $Body
            Attachment = "$ENV:Workspace\Security Awareness Training.pdf"
        }
        Send-MailMessage @Splat -ErrorAction Stop
        #TODO
        Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "New user notification email sent to $($ENV:Code)NewUserAccountNotification@groups.DOMAIN.com successfully."
        Write-host "Email Sent successfully!"
    }
    Catch {
        Write-Host $_
        exit 1   
    }
}
Else {
    Try {
        $Splat = @{
            #TODO
            To         = 'EMAIL_ADDRESS
            Subject    = "New Employee Account Information | $($Params.name)"
            #TODO
            From       = 'EMAIL_ADDRESS
            #TODO
            CC         = 'EMAIL_ADDRESS
            SMTPServer = 'AM1SMTP'
            BodyAsHTML = $True
            Body       = $Body  
        }
        #TODO
        Send-MailMessage @Splat
        Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "New user notification email sent to $($ENV:Code)NewUserAccountNotification@groups.DOMAIN.com successfully."
        Write-host "Email Sent successfully!"
    }
    Catch {
        Write-Host $_
        exit 1   
    }
}

