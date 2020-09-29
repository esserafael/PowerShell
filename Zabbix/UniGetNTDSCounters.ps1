<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.145
	 Created on:   	02/10/2018 14:02
	 Created by:   	Rafael Feustel
	 Filename:     	UniGetNTDSCounters.ps1
	===========================================================================
	.DESCRIPTION
		Gets NTDS Counters and send them to Zabbix.
#>

function New-RunSpace
{
	Param (
		[String]$Id,
		[Int32]$IntervalTime
	)
	
	$RunSpaceScriptBlock = {
		Param (
			[String]$CounterName,
			[Int32]$IntervalTime
		)
		
		$TotalCounter = 0
		
		$Counters = Get-Counter -Counter $CounterName -SampleInterval 1 -MaxSamples $IntervalTime
		
		$Counters.CounterSamples.CookedValue | ForEach-Object {
			$TotalCounter += [Math]::Round($_, 0)
		}
		
		return $TotalCounter
	}
	
	$RunSpace = [PowerShell]::Create()
	$null = $RunSpace.AddScript($RunSpaceScriptBlock)
	$null = $RunSpace.AddArgument($Id)
	$null = $RunSpace.AddArgument($IntervalTime)
	
	$RunSpace.RunspacePool = $Pool
	
	$RunSpaceObj = [PSCustomObject]@{ Pipe = $RunSpace; Status = $RunSpace.BeginInvoke(); Id = $Id }
	
	return $RunSpaceObj
}

function Send-ZabbixValue
{
	Param (
		[String]$Id,
		[String]$Value
	)
	
	$Key = ($CountersKeys | Where-Object { $_.Counter -eq $Id }).Key
	
	$ZabbixSenderResult = & $ZabbixSenderPath -z $ZabbixServer -s $HostName -k $Key -o $Value
	
	AdicionaLog $LogName "Value for key $($Key) sent: $($ZabbixSenderResult)" "ACT" $script:ScriptPath -Graylog
}


if ($null -ne $HostInvocation)
{
	$script:ScriptPath = Split-Path $HostInvocation.MyCommand.Path
	$script:ScriptName = (($HostInvocation.MyCommand.Name).Split("."))[0]
}
else
{
	$script:ScriptPath = Split-Path ($MyInvocation.MyCommand.Path)
	$script:ScriptName = (($MyInvocation.MyCommand.Name).Split("."))[0]
}

$LogName = $script:ScriptName

# Módulo
try
{
	Import-Module \\domain.com\netlogon\powershell\Uniasselvi.psm1 -ErrorAction Stop
	AdicionaLog $LogName "Script initialized." "INI" $script:ScriptPath -Graylog
}
catch [System.IO.FileNotFoundException]
{
	AdicionaLog $LogName "Can't load module Uniasselvi.psm1: $($_.Exception.Message)" "ERR" $script:ScriptPath -Graylog
}

# Busca arquivo de config.
try
{
	$script:ConfPath = $script:ScriptPath + "\" + $script:ScriptName + ".conf"
	
	Get-Content -Path $script:ConfPath -ErrorAction Stop | ForEach-Object {
		if (($_[0] -ne "#") -and ($_[0] -ne $Null))
		{
			$Var = $_.Split("=")
			$Var[0] = (RemSpaces $Var[0])
			$Var[1] = (RemSpaces $Var[1])
			if ($Var[1] -match ",")
			{
				New-Variable -Name $Var[0] -Value $Var[1].Split(",") -Scope Script -Force
			}
			else
			{
				New-Variable -Name $Var[0] -Value $Var[1] -Scope Script -Force
			}
		}
	}
	AdicionaLog $LogName "Configs loaded from config file $($script:ConfPath)" "INI" $script:ScriptPath -Graylog
}
catch [System.Management.Automation.ItemNotFoundException]{
	AdicionaLog $LogName "Can't load configs from file. Error: $($_.Exception.Message)" "ERR" $script:ScriptPath -Graylog
}

# Testa caminho do Zabbix Sender.
$ZabbixSenderPath = "C:\zabbix\zabbix_sender.exe"

if (-not (Test-Path -Path $ZabbixSenderPath))
{
	AdicionaLog $LogName "Zabbix Sender not found on path: $($ZabbixSenderPath), will send no shit, exiting." "ERR" $script:ScriptPath -Graylog
	Exit
}

# Busca hostname baseado no arquivo conf do Zabbix.
$ZabbixConf = Get-ChildItem -Path "C:\zabbix" | Where-Object { $_.Extension -eq ".conf" -and $_.Name -notlike "*.userparams.conf" } | Get-Content

$ZabbixConf | ForEach-Object {
	if ($_ -like "Hostname*")
	{
		$HostName = RemSpaces ($_ -split "=")[-1]
	}
}

# Define coleções.
$CountersKeys = @()
$CountersKeys += [PSCustomObject]@{ Counter = "\Security System-Wide Statistics\Kerberos Authentications"; Key = "windowsad.kerberosauth" }
$CountersKeys += [PSCustomObject]@{ Counter = "\Security System-Wide Statistics\NTLM Authentications"; Key = "windowsad.ntlmauth" }
$CountersKeys += [PSCustomObject]@{ Counter = "\Security System-Wide Statistics\KDC TGS Requests"; Key = "windowsad.tgsrequests" }

[System.Collections.ArrayList]$RunSpaces = @()

# Cria Pool de Runspaces.
$Pool = [RunspaceFactory]::CreateRunspacePool(1, [int]$env:NUMBER_OF_PROCESSORS + 1)
$Pool.ApartmentState = "MTA"
$Pool.Open()

# Inicia RunSpaces iniciais.
$CountersKeys | ForEach-Object {
	$RunSpaces += New-RunSpace -Id $_.Counter -IntervalTime $IntervalTime
}

# Gerencia e mantém os runspaces executando.
while ($RunSpaces.Status -ne $null)
{
	$CompletedRunSpaces = $RunSpaces | Where-Object { $_.Status.IsCompleted -eq $true }
	foreach ($RunSpace in $CompletedRunSpaces)
	{
		Send-ZabbixValue -Id $RunSpace.Id -Value $RunSpace.Pipe.EndInvoke($RunSpace.Status)
		$RunSpaces.Remove($RunSpace)
		#$RunSpace.Status = $null
		$RunSpaces += New-RunSpace -Id $RunSpace.Id -IntervalTime $IntervalTime
	}
	
	Start-Sleep -Milliseconds 100
}

$Pool.Close()
$Pool.Dispose()