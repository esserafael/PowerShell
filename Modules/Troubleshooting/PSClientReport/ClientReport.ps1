<#
	.SYNOPSIS
		Gets Active Directory Replication status and results.

	.DESCRIPTION
		Gets Active Directory Replication status and results.
#>

[CmdletBinding()]
Param
(
    [String]$Path = "C:\Users\Feustel\Documents\HtmlResult.html",
    [Switch]$NoHtml
)

# Log file.
$Log = "$Env:USERPROFILE\PSClientReport.log"

try
{
	Import-Module C:\Users\Feustel\Documents\GitHub\PowerShell\Modules\VeryMuchFunctions\VeryMuchFunctions.psd1 -ErrorAction Stop
	Import-Module (Split-Path -Path $MyInvocation.MyCommand.Path | Join-Path -ChildPath "PSClientReport.psd1")
}
catch
{
	Write-Error -Message "Could not import required modules: $($_.Exception.Message)"
	Exit
}

Write-Log "-> Client report started." -Path $Log
Write-Log "Required modules imported." -Path $Log

$ClientInfo = Get-ClientInfo

Set-Content -Path "$Env:USERPROFILE\HtmlResult.html" -Value (ConvertTo-HtmlReport)
