Function Get-HomeDirectory {
    [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$Office,
        [Parameter(Mandatory = $True, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$Samaccountname
    )

    Try {
        $code = get-wcoffice -Offices $Office | Select-Object -ExpandProperty officecode
        If (!$Code) {
            Write-Error "No Matching office code found for $Office"
        }
        Else {
            #TODO
            $HomeDirectory = "\\<Home Drive Path>\$Code\$Samaccountname"
            Write-Output $HomeDirectory
        }
    }
    Catch {
        Write-Error "No Matching office code found for $Office"
    }

}


Try {
    Write-Host "Retrieving AD Object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" | ConvertFrom-JSON
    Write-Host "Building Home directory path..."
    $HomeDirectory = Get-HomeDirectory -Office $ENV:Location -Samaccountname $Joiner.SamAccountName
    Return $HomeDirectory
}
Catch {
    Write-host $_
    Return 'ERR' 
}