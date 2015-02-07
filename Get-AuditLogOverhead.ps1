<#
.SYNOPSIS
Get-AuditLogOverhead.ps1

.DESCRIPTION 
PowerShell script to report on the size of the mailbox audit logs stored in mailboxes in an Exchange Server organization.

.OUTPUTS
Results are output to CSV file.

.LINK
http://exchangeserverpro.com/much-database-storage-mailbox-audit-logging-consume/

.NOTES
Written by: Paul Cunningham

Find me on:

* My Blog:	http://paulcunningham.me
* Twitter:	https://twitter.com/paulcunningham
* LinkedIn:	http://au.linkedin.com/in/cunninghamp/
* Github:	https://github.com/cunninghamp

For more Exchange Server tips, tricks and news
check out Exchange Server Pro.

* Website:	http://exchangeserverpro.com
* Twitter:	http://twitter.com/exchservpro

Change Log
V1.00, 30/01/2015 - Initial version
#>

#requires -version 2

#...................................
# Static Variables
#...................................

$report = @()


#...................................
# Script
#...................................

Write-Host "Retrieving mailboxes"
$mailboxes = @(Get-Mailbox -Resultsize Unlimited)

foreach ($mailbox in $mailboxes)
{
    $name = $mailbox.Name

    Write-Host "Checking $name"

    $auditsfolder = "$($mailbox.Identity)\Audits"

    $foldersize = ($mailbox | Get-MailboxFolderStatistics -FolderScope RecoverableItems | Where {$_.Name -eq "Audits"}).FolderSize
    if ($foldersize)
    {
        $foldersize = "{0:N2}" -f $foldersize.ToMB()
    }
    else
    {
        $foldersize = 0
    }

    $mailboxsize = (Get-MailboxStatistics $mailbox).TotalItemSize.Value.ToMB()

    $reportObj = New-Object PSObject
	$reportObj | Add-Member NoteProperty -Name "Name" -Value $name
    $reportObj | Add-Member NoteProperty -Name "Mailbox Size (MB)" -Value $mailboxsize
    $reportObj | Add-Member NoteProperty -Name "Audits Size (MB)" -Value $foldersize

    $report += $reportObj

    Write-Host "$name, $mailboxsize, $foldersize"
}

Write-Host "Writing output to AuditLogOverhead.csv"

$report | Export-CSV AuditLogOverhead.csv -NoTypeInformation