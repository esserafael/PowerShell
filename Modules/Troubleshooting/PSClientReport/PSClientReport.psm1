
function ConvertTo-HtmlReport
{
	<#
	.SYNOPSIS
		Gets Active Directory Replication status and results.

	.DESCRIPTION
		Gets Active Directory Replication status and results.
	#>

	[CmdletBinding()]
	[OutputType([String])]
	Param
	(
		[String]$Path = "C:\Users\Feustel\Documents\HtmlResult.html"
	)

	begin
	{

	}

	process
	{
		[String]$HtmlText = Get-Content -Path (Split-Path -Path $MyInvocation.ScriptName | Join-Path -ChildPath "Templates\ReportTemplateWrapper.html")
		
		# Insert PS_INCLUDEs
		[Regex]$Regex = "{{PS_INCLUDE:(.*?\.html)}}"
				if($HtmlText -match $Regex)
				{
					($HtmlText | Select-String -Pattern $Regex -AllMatches).Matches | ForEach-Object {
						$HtmlText = $HtmlText -replace $_.Value, (Get-Content -Path (Split-Path -Path $MyInvocation.ScriptName | Join-Path -ChildPath "Templates\$($_.Groups[1].Value)"))
					}
				}
		
		#Set-Content -Path $Path -Value $HtmlText
		Return $HtmlText
	}

	end
	{

	}
}

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
		$EnclosureInfo = Get-CimInstance -ClassName Win32_SystemEnclosure
		$ComputerSystemInfo = Get-CimInstance -ClassName CIM_ComputerSystem
		$ProcessorInfo = Get-CimInstance -ClassName Win32_Processor
		$PhysicalMemInfo = Get-CimInstance -class Win32_PhysicalMemory

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

		foreach ($Address in $DefaultConfig.InternetAddressesToTest)
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
