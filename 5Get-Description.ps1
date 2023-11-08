#Environment Variables Used : Ticketnumber, technician
Function New-Description {
    [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$Title,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$NSATicketNumber,
        [Parameter(Mandatory = $True, ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $False)]
        [String]$Technician
    )

    If ($NSATicketNumber) {
        $Description = $Title + ' - acct modified ' + $(get-date -format 'dd MMMM yyyy') + " by $Technician;" + " (NSA Ticket # $NSATicketNumber);" + "Requested by:" 
    }
    Else {
        $Description = $Title + ' - acct modified ' + $(get-date -format 'dd MMMM yyyy') + " by $Technician;"  
    }

    Write-output $Description

} 

$Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" | ConvertFrom-JSON

Try {
    If ($Joiner.employeeType -like '*NSA*') {
        Write-Host "Using NSA format for description..."
        $Description = New-Description -Title $Joiner.Title -NSATicketNumber $ENV:TicketNumber -Technician $ENV:Technician
        Return $Description
    }
    Else {
        Write-Host "using NON-NSA format for description..."
        $Description = New-Description -Title $Joiner.Title -Technician $Env:Technician
        Return $Description
    }
}
Catch {
    Write-Host $_
    Return 'ERR'
} 