Try {
    $Env:Homedirectory = $Env:Homedirectory.trim()
    New-Item -ItemType Directory -path $Env:Homedirectory -ErrorAction Stop
    Write-host "User Home Directory Created at $Env:Homedirectory"
}
Catch [System.IO.IOException] {
    Write-Host "Directory $Env:Homedirectory already exists, assigning permissions..."
}
Catch [System.UnauthorizedAccessException] {
    Write-host "Permission Denied creating Home directory"
    exit 1
}

Try {
    $User = "$env:samaccountname"
    $FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
    $AccessControl = [System.Security.AccessControl.AccessControlType]::Allow
    $NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)
    $currentACL = Get-ACL -path $Env:Homedirectory -ErrorAction Stop
    $currentACL.SetAccessRule($NewAccessrule)
    Set-ACL -path $Env:Homedirectory -AclObject $currentACL -ErrorAction Stop
    Write-host "Permissions assigned successfully."
}
Catch {
    Write-host "Failed to set permissions on User Home Directory : $Env:Homedirectory"
    Write-Error $_
    exit 1
}
