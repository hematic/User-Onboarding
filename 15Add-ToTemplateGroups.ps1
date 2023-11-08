Try {
    Write-Host "Retrieving template from file..."
    $Template = Get-content -Path "$ENV:Workspace\$ENV:Code-Template.txt" -ErrorAction Stop | ConvertFrom-JSON
    Write-Host "Retrieving template AD groups from file..."
    [Array]$Groups = Get-content -Path "$ENV:Workspace\$($Template.samaccountname)-groups.txt" -ErrorAction Stop
    Write-Host "Retrieving AD Object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" | ConvertFrom-JSON
}
Catch {
    Write-Host $_
    exit 1
}
Foreach ($Group in $Groups) {
    Try {
        Add-ADGroupMember -Identity $Group -Members $Joiner.Samaccountname -Server $ENV:DC -Confirm:$false -ErrorAction Stop -Verbose -Debug -InformationAction Continue
        $ad_groups = get-ADPrincipalGroupMembership -Identity $Joiner.Samaccountname -Server $ENV:DC -ErrorAction Stop | select -ExpandProperty distinguishedName
        If ($ad_groups -contains $Group) {
            Write-Host "`tUser added to $Group"
            Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "User added to group    : $Group"
        }
        Else {
            Write-Host "`t**********"
            Write-Host "`tUNABLE TO ADD User $($Joiner.Samaccountname) to $Group but no error was thrown."
            Write-Host "`t**********"
        }
    }
    Catch {
        If ($_ -like '*already a member*') {
            Write-Host "`tUser is already a member of $Group"
            Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Already a member of    : $Group"
            Continue;
        }
        Else {
            Write-Host $_
            exit 1
        }
    }
}