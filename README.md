# User-Onboarding
This repo will be a sanitized version of our onboarding process for new users.

# Description

This process is mostly posted for ideas for others and not to directly try to copy in to your environment.

The general flow of the process is as follows.

 - HR Gets a new hire in their Software (Peoplesoft)
 - Peoplesoft syncs a shell account for the user over to a new-users AD OU.
 - An external servicenow process calls a Jenkins pipeline the day before the user starts and fires off this Jenkinsfile.
 - The jenskins file calls each of these PowerShell scripts (and more i couldn't effectively sanitize) one by one, keeps a running log of steps and updates a service now ticket at the end.

# Using this Code

I put a bunch of "TODO" markers in the scripts for places you would want to put in custom values for things