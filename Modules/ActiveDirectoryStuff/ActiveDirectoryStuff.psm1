
function Get-ADReplication
{
	<#
	.SYNOPSIS
		Gets Active Directory Replication status and results.

	.DESCRIPTION
		Gets Active Directory Replication status and results.

	.PARAMETER Target
		The target or target Domain Controller which the function will get the statuses and results.

	.PARAMETER All
		Defines to get All Domain Controllers replication results.

	.INPUTS
		Object[]
			You can pipe Objects (Domain Controllers) to the function.

	.OUTPUTS
		Microsoft.ActiveDirectory.Management.ADReplicationPartnerMetadata
			This function returns ADReplicationPartnerMetadata objects with results.

	.EXAMPLE
		Get-ADReplication -Target "DC01"
	The function will get the replication results from server 'DC01'.
		
	.EXAMPLE
		Get-ADReplication -All
	The function will get replication results from all domain controllers in the domain.

	.EXAMPLE
		Get-ADReplication -Target "DC01", "DC03", "SERVER04"
	The function will get the replication results from multiple domain controllers.

	#>

	[CmdletBinding(DefaultParameterSetName = "Single")]
	[OutputType([Microsoft.ActiveDirectory.Management.ADReplicationPartnerMetadata])]
	Param
	(
		[Parameter(
					Position = 0,
					Mandatory = $true,
					ValueFromPipeline = $true,
					ParameterSetName = "Single"
					)]
		[Object[]]$Target,
		[Parameter(
					ParameterSetName = "All"
					)]
		[Switch]$All
	)

	begin
	{
		if ($All.IsPresent)
		{
			$Target = (Get-ADDomainController -Filter * | Sort-Object HostName).HostName
		}
	}

	process
	{
		foreach ($SingleTarget in $Target)
		{
			if (Test-NetConnection -ComputerName $SingleTarget -InformationLevel Quiet)
			{
				try
				{
					Get-ADReplicationPartnerMetadata -Target $SingleTarget -ErrorAction Stop | 
					Select-Object `
						Server,
						@{
							N="PartnerName"
							E={
								$PInvID = $_. PartnerInvocationId
								(Get-ADDomainController -Filter {InvocationId -eq $PInvID}).HostName
							}
						},
						PartnerAddress,
						PartnerType,
						IntersiteTransportType,
						Writable,
						LastReplicationAttempt,
						LastReplicationSuccess,
						LastReplicationResult
				}
				catch [Microsoft.ActiveDirectory.Management.ADServerDownException]
				{
					Write-Error -Exception $_
				}
			}
			else
			{				
				Write-Error -Exception (New-Object Microsoft.ActiveDirectory.Management.ADServerDownException -ArgumentList @(
					"It is not possible to contact the server $($SingleTarget).", 
					$SingleTarget
				))
			}
		}
	}

	end
	{

	}
}

function Test-ADCredential
{
	<#
	.SYNOPSIS
		Tests an Active Directory Domain or SAM credential.

	.DESCRIPTION
		Tests an Active Directory Domain Services or Security Account Manager (SAM) credential, 
		returning True or False if the connection and validation is successful.

	.PARAMETER Credential
		Credential to be tested.
		
	.PARAMETER Context
		Specifies the type of store the principal belongs: 'ApplicationDirectory', 'Domain' or 'Machine'
		
	.PARAMETER ComputerName
		The name of the domain or server.

	.PARAMETER UseSSL
		Uses Secure Socket Layer (SSL) to encrypt the channel.

	.INPUTS
		System.Management.Automation.PSCredential
			You can pipe PSCredentials to be tested.

	.OUTPUTS
		PSCustomObject
			This function returns PSCustomObjects with results.

	.EXAMPLE
		Test-ADCredential -Credential $SomeCred
	The function will test the credential '$SomeCred'.
		
	.EXAMPLE
		Test-ADCredential
	Prompt for the credentials before the test.

	.EXAMPLE
		Test-ADCredential -ComputerName dc01.example.com -UseSSL
	Will prompt for the credentials and connect to the server 'dc01.example.com' using SSL (port 636).

	#>
	
	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	Param
	(
		[Parameter(
					Position = 0,
					Mandatory = $true,
					ValueFromPipeline = $true
					)]
		[System.Management.Automation.PSCredential]$Credential,
		[ValidateSet("ApplicationDirectory", "Domain", "Machine")]
		[Parameter(
					Position = 1
					)]
		[System.String]$Context = "Machine",
		[Parameter(
					Position = 2
					)]
		[System.String]$ComputerName = $null,
		[Parameter(
					Position = 3
					)]
		[Switch]$UseSSL
	)
	
	begin
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement -ErrorAction SilentlyContinue

		if((Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain)
		{
			$Context = "Domain"
			$ContextOption = @("Negotiate", "Signing", "Sealing")
			if($UseSSL.IsPresent)
			{
				$ContextOption += "SecureSocketLayer"
			}

			try
			{
				Write-Verbose -Message "Connecting to Context '$($Context)' with ContextOptions: '$($ContextOption)'."	
				$DirectoryServices = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($Context, $ComputerName, $null, ($ContextOption -join ","), $null, $null)
			}
			catch { $PSCmdlet.ThrowTerminatingError($_) }
		}
		else
		{
			try
			{
				Write-Verbose -Message "Connecting to Context '$($Context)'."	
				$DirectoryServices = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($Context)
			}
			catch { $PSCmdlet.ThrowTerminatingError($_) }
		}
	}
	
	process
	{
		foreach($SingleCredential in $Credential)
		{
			Return [PSCustomObject]([ordered]@{
				ContextType = $DirectoryServices.ContextType
				ConnectedServer = $DirectoryServices.ConnectedServer
				AuthMethod = ($DirectoryServices.Options -split (", "))[0]
				KerberosEncryption = $DirectoryServices.Options -match "Sealing"
				SSLEnabled = $DirectoryServices.Options -match "SecureSocketLayer"
				DataVerified = $DirectoryServices.Options -match "Signing"
				Succeeded = $DirectoryServices.ValidateCredentials($SingleCredential.UserName, $SingleCredential.GetNetworkCredential().Password)
			})	
		}
	}
	
	end
	{
		$DirectoryServices.Dispose()
	}
}
