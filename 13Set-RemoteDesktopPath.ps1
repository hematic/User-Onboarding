Try {
    Write-Host "Retrieving AD Object from file..."
    $Joiner = Get-content -Path "$ENV:Workspace\$($ENV:samaccountname)-ADObject.txt" -ErrorAction Stop | ConvertFrom-JSON
    Write-Host "Setting remote desktop path in AD..."
    $user = [ADSI]"LDAP://$($Joiner.Distinguishedname)"
    $user.psbase.Invokeset("terminalservicesprofilepath", "c:\policies\user.man")
    $user.setinfo()
    Add-Content -Path "D:\temp\$($ENV:Samaccountname)-log.txt" -Value "Remote desktop Path    : c:\policies\user.man"
}
Catch {
    write-host $_
    exit 1
}