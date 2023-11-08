try{
    node('am1apit002') {
        stage('Git clone'){
            //TODO
            git credentialsId: '<CRED_NAME>', url: 'https://tfs.DOMAIN.com/DEPARTMENT/Automation/_git/Joiner%20Pipeline'
        }
        stage('Check For User in AD') {
            def status = powershell(returnStatus: true, script: "& '.\\1Get-Joiner.ps1'")
            //User data is output to path "$ENV:Workspace\$($Joiner.samaccountname)-ADObject.txt"
            if (status == 0) {
                println('User Found in AD')
            }
            else{
                println('Unable to find user')
                error 'Failing build'
            }
        }
        stage('Get 3 Digit Office Code') {
            def code = powershell(returnStdout: true, script: "& '.\\2Get-officeCode.ps1'")
            env.code = code.trim()
            if (env.code == 'ERR'){
                println('Unable to retrieve 3 digit office code.')
                error 'Failing build'
            }
            println('3 Digit office code is ' + env.code)
        }
        stage('Get AD Template'){
            def template = powershell(returnStdout: true, script: "& '.\\3Get-ProperTemplate.ps1'")
            env.template = template.trim()
            if (env.template == 'ERR'){
                println('Unable to retrieve template.')
                error 'Failing build'
            }
            //Template JSOn is outset to path "$ENV:Workspace\$($Template.samaccountname).txt"
            println('Template is ' + env.template)
        }
        stage('ServiceNow Update'){
            def snrequestnum = powershell(returnStdout: true, script: "& '.\\4Get-ServiceNowRequestNumber.ps1'")
            env.snrequestnum = snrequestnum.trim()
            if (env.snrequestnum == 'ERR') {
                println 'Failed to retrieve matching ServiceNow Request.'
            }
            else{
                println('ServiceNow Request # is ' + env.snrequestnum)
            }
        }
        stage('Create Description'){
            def description = powershell(returnStdout: true, script: "& '.\\5Get-Description.ps1'")
            env.description = description.trim()
            if (env.description == 'ERR'){
                error 'Failing build'
            }
            println('User description is ' + env.type)
        }
        stage('Get HomeDirectory'){
            def homedirectory = powershell(returnStdout: true, script: "& '.\\6Get-HomeDirectory.ps1'")
            env.homedirectory = homedirectory.trim()
            if (env.homedirectory == 'ERR'){
                error 'Failing build'
            }
            println('User home directory is ' + env.homedirectory)
        }
        stage('SET AD Account Properties'){
            def status = powershell(returnStatus: true, script: "& '.\\8Set-ADAccountProperties.ps1'")
            if (status == 0) {
                println 'User Properties set in AD'
            }
            else{
                println 'Unable to set user properties'
                error 'Failing build'
            }
        }
        stage('Create Home Directory Folder'){
            def status = powershell(returnStatus: true, script: "& '.\\9New-UserHomeDirectory.ps1'")
            if (status == 0) {
                println 'Home directory created successfully'
            }
            else{
                println 'Unable to create home directory folder'
                error 'Failing build'
            }
        }
        stage('Update User file export'){
            def status = powershell(returnStatus: true, script: "& '.\\1Get-Joiner.ps1'")
            if (status == 0) {
                println 'User Properties file updated'
            }
            else{
                println 'Unable to set user properties in file'
                error 'Failing build'
            }
        }
        stage('Generate Password'){
            def randompassword = powershell(returnStdout: true, script: "& '.\\11Get-RandomPassword.ps1'")
            env.randompassword = randompassword.trim()
            println('User temp password is ' + env.randompassword)
        }
        stage('Set AD Password'){
            def status = powershell(returnStatus: true, script: "& '.\\12Set-ADPassword.ps1'")
            if (status == 0) {
                println 'AD Password updated'
            }
            else{
                println 'Unable to update AD password'
                error 'Failing build'
            }
        }
        stage('Enable User in AD') {
            def status = powershell(returnStatus: true, script: "& '.\\7Enable-Account.ps1'")
            if (status == 0) {
                println 'User Account Enabled in AD'
            }
            else{
                println 'Unable to enable user'
                error 'Failing build'
            }
        }
        stage('Set Remote Desktop Path'){
            def status = powershell(returnStatus: true, script: "& '.\\13Set-RemoteDesktopPath.ps1'")
            if (status == 0) {
                println 'Remote Desktop Path set'
            }
            else{
                println 'Unable to set remote desktop path'
                error 'Failing build'
            }
        }
        stage('Get Template groups'){
            def status = powershell(returnStatus: true, script: "& '.\\14Get-TemplateGroups.ps1'")
            if (status == 0) {
                println 'Template Groups gathered successfully'
            }
            else{
                println 'Failed to gather AD groups from template'
                error 'Failing build'
            }
        }
        stage('Set AD groups'){
            def status = powershell(returnStatus: true, script: "& '.\\15Add-ToTemplateGroups.ps1'")
            if (status == 0) {
                println 'Template Groups added successfully'
            }
            else{
                println 'Failed to add user to AD groups from template'
                error 'Failing build'
            }
        }
        if ( params.mailbox == 'true'){
            stage('Check for Existing Mailbox'){
                def existingmailboxstatus = powershell(returnStatus: true, script: "& '.\\16Check-ExistingMailbox.ps1'")
                if (existingmailboxstatus == 1) {
                    println 'Mailbox already exists for this user.'
                    error 'Failing build'
                }
            }
            stage('Get mailbox Region'){
                def mailboxregion = powershell(returnStdout: true, script: "& '.\\17Get-MailboxRegion.ps1'")
                env.mailboxregion = mailboxregion.trim()
                if (env.mailboxregion == 'ERR'){
                    error 'Failing build'
                }
                println('User mailbox region is ' + env.mailboxregion)
            }
            stage('Get Mailbox Database'){
                def mailboxdatabase = powershell(returnStdout: true, script: "& '.\\18Get-BestMailboxDatabase.ps1'")
                env.mailboxdatabase = mailboxdatabase.trim()
                if (env.mailboxdatabase == 'ERR'){
                    error 'Failing build'
                }
                println('User mailbox database is ' + env.mailboxdatabase)
            }
            stage('Create New Mailbox'){
                def newmailboxstatus = powershell(returnStatus: true, script: "& '.\\19Create-NewMailbox.ps1'")
                if (newmailboxstatus == 0) {
                    println 'Mailbox created!'
                }
                else{
                    error 'Failing build'
                }
            }
        }
        else {
            println 'No mailbox needed'
        }
        if(params.mailbox == 'true' || params.mailbox == 'True'){
            stage('Retrieve SMTP address'){
                def smtpaddress = powershell(returnStdout: true, script: "& '.\\20Retrieve-SMTPAddress.ps1'")
                env.smtpaddress = smtpaddress.trim()
                println('User smtp address is ' + env.smtpaddress)
            }
        }
        stage('Determine User Notification Type'){
            def type = powershell(returnStdout: true, script: "& '.\\21Get-UserNotificationType.ps1'")
            env.type = type.trim()
            println('User notification type is ' + env.type)
            if (env.type == 'nsa') {
                env.attachment = 'true'
                def status = powershell(returnStatus: true, script: "& '.\\22Send-NewUserNotification.ps1'")
                if (status == 0) {
                    println 'New user notification email sent'
                }
                else{
                    println 'Failed to send new user notification Email'
                    error 'Failing build'
                }
            }
            else if (env.type == 'template 2'){
                def status = powershell(returnStatus: true, script: "& '.\\22Send-NewUserNotification.ps1'")
                if (status == 0) {
                    println 'New user notification email sent'
                }
                else{
                    println 'Failed to send new user notification Email'
                    error 'Failing build'
                }
            }
            else if (env.type == 'default'){
                def status = powershell(returnStatus: true, script: "& '.\\22Send-NewUserNotification.ps1'")
                if (status == 0) {
                    println 'New user notification email sent'
                }
                else{
                    println 'Failed to send new user notification Email'
                    error 'Failing build'
                }
            }
        }
        stage('Send Password Email'){
            def status = powershell(returnStatus: true, script: "& '.\\23Send-NewUserPasswordNotification.ps1'")
            if (status == 0) {
                println 'Password Email sent successfully'
            }
            else{
                println 'Failed to Send Password Email'
                error 'Failing build'
            }
        }
    }
}
catch(Exception e){
    currentBuild.result = 'FAILURE'
}
finally{
    //TODO
    node('NODE'){
        stage('Git clone'){
            git credentialsId: 'CREDENTIAL', url: 'https://tfs.domain.com/DEPARTMENT/Automation/_git/Joiner%20Pipeline'
        }
        stage('ServiceNow Update'){
            def servicenow = powershell(returnStatus: true, script: "& '.\\24Update-ServiceNow.ps1'")
            if (servicenow == 0) {
                println 'ServiceNow Updated'
            }
            else{
                println 'Failed to update ServiceNow'
            }
        }
        stage("cleanup") {
            deleteDir()
            dir("${workspace}@tmp") {
                deleteDir()
            }
        }
    }
    println (currentBuild.result)
}