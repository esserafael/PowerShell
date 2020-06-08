function Get-ClientInfo
{
	<#
	.SYNOPSIS
		Gets Active Directory Replication status and results.

	.DESCRIPTION
		Gets Active Directory Replication status and results.
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	Param
	(

	)

	begin
	{
		
	}

	process
	{
		$ComputerSystemInfo = Get-CimInstance -ClassName CIM_ComputerSystem

		#Return [PSCustomObject]([ordered]@{}
	}

	end
	{

	}
}


function Test-InternetConnection
{
	<#
	.SYNOPSIS
		Gets Active Directory Replication status and results.

	.DESCRIPTION
		Gets Active Directory Replication status and results.
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	Param
	(

	)

	begin
	{
		
	}

	process
	{
		$InternetConnTestResult = @()
		$InternetConnTestResult += Test-NetConnection

		foreach ($Address in $Global:DefaultConfig.InternetAddressesToTest)
		{
			$InternetConnTestResult += Test-NetConnection -ComputerName $Address
		}

		$InternetConnTestResult

		#Return [PSCustomObject]([ordered]@{}
	}

	end
	{

	}
}
