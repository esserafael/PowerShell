<#
	.SYNOPSIS
		Configures an Outlook signature in the default profile, based on AD info.

	.DESCRIPTION
		Configures an Outlook signature in the default Outlook profile, using
		AD User properties to set signature info. It's meant to be used as a
		GPO Logon Script.

	.NOTES
		Author: Rafael Alexandre Feustel Gustmann (https://github.com/esserafael)
		GitHub PowerShell Repository: https://github.com/esserafael/PowerShell
#>

function Write-LocalLog
{
	Param(
		[Parameter()]
		[String]$Text
	)

	Add-Content $Log -Value "$(Get-Date) - $($Text)" -Encoding UTF8
}

# Log file.
$Log = "$Env:USERPROFILE\SignatureConfiguration.log"

# Default Signature directories for Outlook.
$LocalFilePaths = @("$Env:APPDATA\Microsoft\Assinaturas", "$Env:APPDATA\Microsoft\Signatures")

# Signature HTML template path
$SourceFilesPath = Join-Path -Path (Split-Path -Path $Script:MyInvocation.MyCommand.Path) -ChildPath "SignatureTemplate\*"

# Max COM Object creation retries
$MaxCOMRetries = 5

Write-LocalLog -Text "-> Started Outlook Signature Configuration."

try
{
	$OutlookCOMObject = New-Object -ComObject "Outlook.Application" -ErrorAction Stop
	Write-LocalLog -Text "Outlook COM Object created."
}
catch
{
	# In some workstations, when creating the COM object we get 0x80080005 (CO_E_SERVER_EXEC_FAILURE) exception,
	# which can be caused by a variety of reasons, like high CPU load, COM server is currently stopping etc.
	# So we can retry a few times again.

	Write-LocalLog -Text "Error: Can't create Outlook COM Object: $($_.Exception.Message)."
	Write-LocalLog -Text "Retrying $($MaxCOMRetries) times."

	for ($i = 0; $i -lt $MaxCOMRetries; $i++)
	{
		$OutlookCOMObject = New-Object -ComObject "Outlook.Application"

		if ($OutlookCOMObject)
		{
			Write-LocalLog -Text "Outlook COM Object created."
			break
		}
		elseif ($i -eq $MaxCOMRetries-1) { Exit }
	}	
}

# Get Outlook default profile.
$Profile = $OutlookCOMObject.DefaultProfileName

if (-not $Profile)
{
	Write-LocalLog -Text "Can't get default Outlook profile, probably no account configured, aborting."
	Exit
}

Write-LocalLog -Text "Outlook default profile: '$($Profile)'."
Write-LocalLog -Text "Outlook version: $($OutlookCOMObject.Version)"

try
{
	# Get AD User info.
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$Domain = [ADSI]"LDAP://$((New-Object System.DirectoryServices.DirectoryEntry).distinguishedName)"
	$Searcher = [DirectoryServices.DirectorySearcher]$Domain
	$Searcher.Filter = "(&(objectClass=User)(samaccountname=$Env:USERNAME))"
	$User = $Searcher.FindOne()
}
catch
{
	Write-LocalLog -Text "Error connecting to domain or getting user info in AD: $($_.Exception.Message)."
	Exit
}

if($User)
{
	$UserProperties = $User.Properties
	$Depart = $UserProperties.department

	if ($null -eq $Depart)
	{
		# If department is null, it will get the description value from the OU the user resides in.
		$Searcher.Filter = "(&(objectClass=organizationalunit)(distinguishedname=$(($UserProperties.distinguishedname -split ",")[1..$UserProperties.distinguishedname.Length] -join ",")))"
		$Depart = $Searcher.FindOne().Properties.description
	}

	$LocalFilesCopied = @()

	foreach ($LocalPath in $LocalFilePaths)
	{
		if (!(Get-Item -Path $LocalPath -ErrorAction SilentlyContinue))
		{
			try
			{
				$null = New-Item -Path $LocalPath -Type Directory -ErrorAction Stop
				Write-LocalLog -Text "Created directory '$($LocalPath)'."
			}		
			catch
			{
				Write-LocalLog -Text "Error creating Outlook signature default directories: $($_.Exception.Message)"
				Exit
			}
		}
		
		try
		{
			$LocalFilesCopied += Copy-Item -Path $SourceFilesPath -Destination $LocalPath -Recurse -Force -PassThru -ErrorAction Stop
			Write-LocalLog -Text "Template files copied to '$($LocalPath)'."
		}
		catch
		{
			Write-LocalLog -Text "Error copying template files: $($_.Exception.Message)"
			Exit
		}
	}

	# Formatting the template files with user info.
	foreach ($LocalFile in $LocalFilesCopied)
	{
		[String]$SigContent = Get-Content -Path $LocalFile -Encoding UTF8
		$SigContent = $SigContent.Replace("USERFULLNAME", $UserProperties.displayname)
		$SigContent = $SigContent.Replace("USERDEPARTMENT", $Depart)
		$SigContent = $SigContent.Replace("USERPHONE", $UserProperties.telephonenumber)

		try
		{
			Set-Content -Path $LocalFile -Value $SigContent -Force -Encoding UTF8 -ErrorAction Stop
			Write-LocalLog -Text "Content set with user info in file '$($LocalFile.FullName)'."
		}
		catch
		{
			Remove-Item -Path "$($LocalFile)*" -Force -Recurse
			Write-LocalLog -Text "Error setting up signature content: $($_.Exception.Message)"
			Write-LocalLog -Text "Copied files removed."
		}	
	}
	
	switch -Wildcard ($OutlookCOMObject.Version)
	{
		# Outlook 2010.
		"14*" {
			$RegPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\$($Profile)\9375CFF0413111d3B88A00104B2A6676\"
		}
		# Outlook 2013.
		"15*" {
			$RegPath = "HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles\$($Profile)\9375CFF0413111d3B88A00104B2A6676\"
		}
		# Outlook 2016 (or Microsoft 365).
		"16*"{
			$RegPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\$($Profile)\9375CFF0413111d3B88A00104B2A6676\"
		}
	}

	# Update Windows registry.	
	try
	{
		Get-ChildItem -Path $RegPath | ForEach-Object {
			$null = New-ItemProperty -Path ($RegPath + $_.PSChildName) -Name "New Signature" -Value $LocalFilesCopied[0].BaseName -PropertyType String -Force -ErrorAction Stop
			$null = New-ItemProperty -Path ($RegPath + $_.PSChildName) -Name "Reply-Forward Signature" -Value $LocalFilesCopied[0].BaseName -PropertyType String -Force -ErrorAction Stop
		}
		
		Write-LocalLog -Text "Windows Registry updated."
	}
	catch
	{
		Write-LocalLog -Text "Error updating Windows Registry: $($_.Exception.Message)"
	}
	
	$OutlookCOMObject.Quit()
	Remove-Variable -Name "OutlookCOMObject"
}

Write-LocalLog -Text "-> Finished Outlook Signature Configuration."
