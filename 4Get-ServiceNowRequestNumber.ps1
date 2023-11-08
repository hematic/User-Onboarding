#region functions
Function New-WCServiceNowBase64AuthObj {
    [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $True, HelpMessage = 'This is the API Credential.')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )
    [String]$textuser = $Credential.UserName
    [String]$textPassword = $Credential.GetNetworkCredential().password
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $TextUser, $Textpassword)))
    Return $base64AuthInfo
}
Function New-WCServiceNowHeaders {
    [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $True, HelpMessage = 'This is the API Credential.')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )
    Try {
        $base64AuthInfo = New-WCServiceNowBase64AuthObj -Credential $Credential -ErrorAction Stop
    }
    Catch {
        Write-Error $_
    }
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Authorization', ('Basic {0}' -f $base64AuthInfo))
    $headers.Add('Accept', 'application/json')
    Return $headers
}
Function Get-RequestNumber {
    [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $True, HelpMessage = 'This is credential for connecting to Service Now.')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $True, HelpMessage = 'This is base URI of your Service Now instance.')]
        [ValidateNotNullOrEmpty()]
        [String]$baseURI,
        
        [Parameter(Mandatory = $True, HelpMessage = 'This is Ticket ID to search for.')]
        [ValidateNotNullOrEmpty()]
        [String]$sys_id
    )

    #region Get Headers
    Try {
        $Headers = New-WCServiceNowHeaders -Credential $Credential -ErrorAction Stop
    }
    Catch {
        Write-Error $_
    }
    #endregion

    #region Build URI
    $URI = "https://$BaseURI/api/now/table/sc_request/$sys_id"
    Write-Host $URI
    #endregion

    #region Send HTTP request
    Try {
        $Response = Invoke-WebRequest -Headers $Headers -Method Get -Uri $URI -ErrorAction Stop
        $Obj = ($Response.content | convertFrom-JSON).result
        Return $Obj.number
    }
    Catch {
        Write-error $_
    }
    #endregion
}

Try {
    #TODO
    $credential = Import-Savedcredential '<Credential>'

    #Get the sys_id of the RITM
    $Splat = @{
        Credential = $Credential
        sys_id     = $Env:Ticketnumber #passed from sharepoint call as ticketnumber
        baseURI    = "COMPANY.service-now.com"
    }
    $Request = Get-RequestNumber @splat

      
    If ($Request -eq '' -or $Request -eq $null) {
        Write-Host "Unable to Retieve the request number using the SYS_ID passed from Sharepoint"
        Return 'ERR'
    }
    Else {
        Return $Request
    }
}
Catch {
    Write-error $_
    Return 'ERR'
}