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
Function Get-ritmSysID {
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
    $URI = "https://$BaseURI/api/now/table/sc_req_item?sysparm_query=request%3D$sys_id"
    Write-Host $URI
    #endregion

    #region Send HTTP request
    Try {
        $Response = Invoke-WebRequest -Headers $Headers -Method Get -Uri $URI -ErrorAction Stop
        $Obj = ($Response.content | convertFrom-JSON).result
        Return $Obj.sys_id
    }
    Catch {
        Write-error $_
    }
    #endregion
}
Function Get-taskSysIDs {

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
    $URI = "https://$BaseURI/api/now/table/sc_task?sysparm_query=request_item=$sys_id"
    Write-Host $URI
    #endregion

    #region Send HTTP request
    Try {
        $Response = Invoke-WebRequest -Headers $Headers -Method Get -Uri $URI -ErrorAction Stop
        $Obj = ($Response.content | convertFrom-JSON).result
        Return $Obj
    }
    Catch {
        Write-error $_
    }
    #endregion
}
Function Update-task {
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
        [String]$sys_id,

        [Parameter(Mandatory = $True, HelpMessage = 'This is Ticket ID to search for.')]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$body
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
    $URI = "https://$BaseURI/api/now/table/sc_task/$sys_id"
    Write-Host $URI
    #endregion

    #region Format JSON Body
    $json = $body | ConvertTo-Json
    #endregion

    #region Send HTTP request
    Try {
        $Response = Invoke-WebRequest -Headers $Headers -Method Put -Uri $URI -Body $json -ErrorAction Stop
        #$Obj = ($Response.content | convertFrom-JSON).result
        #Return $Obj
        Return $Response
    }
    Catch {
        Write-error $_
    }
    #endregion
}

Try {
    $credential = #TODO

    Try {
        Copy-Item -Path "D:\temp\$($ENV:Samaccountname)-log.txt" `
            -Destination "\\share\Apps\Cloudbees\Joiners\$($ENV:Samaccountname)-log.txt" `
            -Force -ErrorAction Stop
        If (Test-Path -Path "\\share\Apps\Cloudbees\Joiners\$($ENV:Samaccountname)-log.txt") {
            Try {
                Remove-Item -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Force -ErrorAction Stop
                $log_path = "\\share\Apps\Cloudbees\Joiners\$($ENV:Samaccountname)-log.txt"
            }
            Catch {
                Write-Error "Unable to delete local log copy"
            }
        }
    }
    Catch {
        $log_path = "D:\temp\$($ENV:Samaccountname)-log.txt"
        Write-Error $_
    }

    #Get the sys_id of the RITM
    $Splat = @{
        Credential = $Credential
        sys_id     = $Env:Ticketnumber #passed from sharepoint call as ticketnumber
        baseURI    = "comapny.service-now.com"
    }
    $RITMsysID = Get-ritmSysID @splat

    #get the tasks associated with that RITM sys_id
    $Splat = @{
        Credential = $Credential
        sys_id     = $RITMsysID
        baseURI    = "company.service-now.com"
    }
    $tasks = Get-taskSysIDs @splat

    #Filter the task that is the network account and grab the sys_id
    $TaskSysID = $Tasks | Where-Object { $_.'short_description' -like '*Network account activation*' } | Select-Object -ExpandProperty sys_id
    
    If ($TaskSysID -eq '' -or $null -eq $TaskSysID) {
        Write-Host "Unable to find task that matches name 'Network account activation'"
        Write-Host "Here are the task descriptions:"
        Write-Host $tasks.short_description
        exit 1
    }

    Try {
        $content = Get-Content -Path $log_path -Raw -ErrorAction Stop
    }
    Catch {
        Write-Error "Unable to get file contents."
        $content = "Unable to get file contents"
    }

    #create a body to update the task.
    $body = @{
        "work_notes" = $Content
    }

    #update the task
    $Splat = @{
        Credential = $Credential
        sys_id     = $TaskSysID
        baseURI    = "company.service-now.com"
        body       = $body
    }
    Update-Task @splat | Out-Null
    Return 'Complete'
}
Catch {
    Write-error $_
    exit 1
}