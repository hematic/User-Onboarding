Try {
    Write-Host "Retrieving AD Object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" -ErrorAction Stop | ConvertFrom-JSON
    $Params = @{
        Displayname = $Joiner.DisplayName
        Password    = $env:randompassword
    }
}
Catch {
    Write-Error $_
    exit 1   
}

#Load the body template
Try {
    Write-Host "Retrieving Password Notification HTML from file..."
    $Body = Get-content -Path "$ENV:Workspace\New User Password Notification Email.html" -raw -ErrorAction Stop
}
Catch {
    Write-Host $_
    exit 1  
}

foreach ( $token in $Params.GetEnumerator() ) {
    $pattern = '#{0}#' -f $token.key
    $body = $body -replace $pattern, $token.Value
}


#Send the email
Try {
    $Splat = @{
        To         = #TODO
        Subject    = "New Employee Account Password Notification | $($Params.name)"
        From       = #TODO
        CC         = #TODO
        SMTPServer = #TODO
        BodyAsHTML = $True
        Body       = $Body
    }
    Send-MailMessage @Splat -ErrorAction Stop
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Password email sent successfully."
}
Catch {
    Write-Error $_
    $LastExitCode = 1
    exit 1   
}