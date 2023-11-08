Try {
    Write-Host "Retrieving template from file..."
    $Template = Get-content -Path "$ENV:Workspace\$ENV:Code-Template.txt" | ConvertFrom-JSON
    Write-Host "Retrieving AD groups on the template..."
    $Groups = Get-ADPrincipalGroupMembership -Identity $Template.samaccountname -Server $ENV:DC -ErrorAction 'Stop'
    Write-Host "Outputting AD groups to file..."
    $Groups.distinguishedname | Out-File "$ENV:Workspace\$($Template.samaccountname)-groups.txt" -Force
}
Catch {
    write-host $_
    exit 1
}
