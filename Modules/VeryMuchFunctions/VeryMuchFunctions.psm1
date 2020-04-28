<#	
	===========================================================================
	 Created on:   	29/10/2019 09:48
	 Created by:   	Rafael Alexandre Feustel Gustmann - esserafael@gmail.com
	 Filename:     	VeryMuchFunctions.psm1
	-------------------------------------------------------------------------
	 Module Name: VeryMuchFunctions
	===========================================================================
#>


function Format-StringToTitleCase
{
	<#
    .SYNOPSIS
        Formats a String to Title Case.
	
	.DESCRIPTION
		Formats a String to Title Case.
		Sample: "fulano de tal" will be converted to "Fulano De Tal".

    .PARAMETER String
        String which will be converted.

    .INPUTS
        System.String
			You can pipe a String to be converted.

    .OUTPUTS
        System.String
			This function returns a converted String.

    .EXAMPLE
        Format-StringToTitleCase -String "VeRy mESSY text THAT WILL Be formatted"

    #>
	
	[CmdletBinding()]
	[Alias("CapitalizeStuff")]
	[OutputType([System.String])]
	Param (
		[Alias("Str")]
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true
				   )]
		[System.String]$String
	)
	
	begin
	{
		$CultureTextInfo = (Get-Culture).TextInfo
	}
	
	process
	{
		Write-Verbose -Message "Input String: '$($String)'"
		
		Return [System.String]$CultureTextInfo.ToTitleCase($String.ToLower())
	}
	
	end
	{
		
	}
}


function Get-RandomPassword
{
	<#
    .SYNOPSIS
        Generates a random string of characters, useful for generating passwords.
	
	.DESCRIPTION
		Generates a random string of characters,
		Useful for generating passwords.
		Ensures that the string will contain at least one:
		- Upper case character;
		- Lower case character;
		- Digit;

    .PARAMETER Size
        The length of the character string to be generated. The default is 8 characters.

    .INPUTS
        System.Int32
			You can specify the exact size (length) of the String to be generated.

    .OUTPUTS
		System.String
			This function returns a random generated String, with the default or specified size.

    .EXAMPLE
		Get-RandomPassword
		
	.EXAMPLE
		Get-RandomPassword -Size 16
			Generates a String with exact 16 characters.
			
    #>
	
	[CmdletBinding()]
	[Alias("Gera-Senha")]
	[OutputType([System.String])]
	Param (
		[Alias("Tamanho")]
		[Parameter(
				   Position = 0
				   )]
		[ValidateRange(4, 100)]
		[System.Int32]$Size = 8
	)
	
	while ($Password.Length -ne $Size)
	{
		# Generates a single character by iteration,
		# Can be a upper case char, lower case char or a digit
		# Then adds to the Password String.
		
		if (Get-Random($true, $false))
		{
			$GeneratedChar = [Char](Get-Random -Minimum 97 -Maximum 122)
			
			if (Get-Random($true, $false))
			{
				$GeneratedChar = ([System.String]$GeneratedChar).ToUpper()
			}
		}
		else
		{
			$GeneratedChar = Get-Random -Maximum 9
		}
		
		[System.String]$Password += $GeneratedChar
		
		# Verifies that Password has all three categories of character;
		# If not, empties the variable and starts again.
		
		if (
			$Password.Length -eq $Size -and
			$Password -notmatch [Regex]"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{4,100}$"
		)
		{
			$Password = $null
		}
	}
	
	Return $Password
}


function Remove-StringBlankSpace
{
	<#
    .SYNOPSIS
        Removes unnecessary blank spaces from a String.
	
	.DESCRIPTION
		Removes unnecessary blank spaces from a String.
		Useful to ensure that some data doesn't have empty spaces
		at the beginning, at the end, or more than one in the middle of it.

    .PARAMETER String
        String to be formatted.
	
	.PARAMETER UseRegex
        Boolean which specify (or not) to use regular expressions to remove the blank spaces.

    .INPUTS
        System.String
			You can pipe a String to be converted.

    .OUTPUTS
        System.String
			This function returns a formatted String.

    .EXAMPLE
        Remove-StringBlankSpace -String "    text  with many     useless spaces   "

    #>
	
	[CmdletBinding()]	
	[Alias("RemSpaces")]
	[OutputType([System.String])]
	Param (
		[Alias("Str")]
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true
				   )]
		[System.String]$String,
		[Parameter(
				   Position = 1,
				   Mandatory = $false
				   )]
		[Switch]$UseRegex = $false
	)
	
	begin
	{
		
	}
	
	process
	{
		if ($UseRegex)
		{
			$String = $String -replace "\s{2,}", [Char]32
			$String = $String -replace "^\s{1,}", ""
			$String = $String -replace "\s{1,}$", ""
		}
		else
		{
			# Special char (non-breaking space).
			
			$String = $String -replace "\xA0", [Char]32
			$String = $String -replace [Char]160, [Char]32
			
			# Remove spaces between words. Ex: "Rafael   Alexandre" to "Rafael Alexandre".
			
			$ExtraSpaceIndexes = @()
			
			for ($i = 0; $i -le ($String.Length - 1); $i++)
			{
				if ($String[$i] -eq [Char]32 -and $String[$i - 1] -eq [Char]32)
				{
					$ExtraSpaceIndexes += $i
				}
			}
			
			$RemovedIndexes = 0
			
			foreach ($ExtraSpaceIndex in $ExtraSpaceIndexes)
			{
				$String = $String.Remove($ExtraSpaceIndex - $RemovedIndexes, 1)
				$RemovedIndexes++
			}
			
			# Remove blank spaces at the beginning and at the end of the String. Ex: "  Rafael  Alexandre   " to "Rafael Alexandre"
			
			while ($String[0] -eq [Char]32)
			{
				$String = $String.Substring(1, $String.Length - 1)
			}
			while ($String[-1] -eq [Char]32)
			{
				$String = $String.Substring(0, $String.Length - 1)
			}
		}
		
		Return [System.String]$String
	}
	
	end
	{
		
	}
}


function Remove-StringDiacritic
{
	<#
    .SYNOPSIS
        Removes boring accents and signs from characters in a String.
	
	.DESCRIPTION
		Removes boring accents and signs from characters in a String.
		Useful in the process of automatic creation of email addresses based on full names, for example.

    .PARAMETER String
        String that will be formatted.

    .INPUTS
        System.String
			You can pipe a String to this function.

    .OUTPUTS
        System.String
			This function returns a converted String.

    .EXAMPLE
        Remove-StringDiacritic -String "textão com vários sinais de acentuação"

    #>
	
	[CmdletBinding()]
	[Alias("Remove-Diacritics")]
	[OutputType([System.String])]
	Param (
		[Alias("Str")]
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true
				   )]
		[System.String]$String
	)
	
	begin
	{
		
	}
	
	process
	{
		$StringBuilder = New-Object Text.StringBuilder
		
		($String.Normalize([Text.NormalizationForm]::FormD)).ToCharArray() | ForEach-Object {
			
			if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark)
			{
				[void]$StringBuilder.Append($_)
			}
		}
		
		Return [System.String]$StringBuilder.ToString()
	}
	
	end
	{
		
	}
}


function Write-Log
{
	<#
    .SYNOPSIS
		Writes events to a text file or the Windows Event Logs (Application).
	
	.DESCRIPTION
		Writes events to a text file or the Windows Event Logs (Application).
		For practical log writing, this function can be used only with the Object parameter,
		the remaining parameters have predefined default values.

    .PARAMETER Object
		The Object that will be written to the log.
	
	.PARAMETER Path
        The text file path.
		If no path is provided, this function will write the event to a text file with
		the same name in the same directory as the script which called this function, with a .log extension.
	
	.PARAMETER EntryType
		The type of entry to be written: "Information", "Warning" or "Error".
	
	.PARAMETER EventId
		An event ID number. Default is 0.
	
	.PARAMETER UseEventLog
		Writes to the Windows Event Log instead of a text file.
	
	.PARAMETER Separator
		Used with a text file, defines a character to be used as separator or delimiter.
	
	.PARAMETER NoNewLine
		Specifies that this function will append only the Object value, without a new line.
		Useful to continuing writing the same event log in different instances.
	
	.PARAMETER Encoding	
		Defines the type of Encoding to be used when writing the event in a text file.
	
	.PARAMETER DateTimeFormat
        Used to specify a String to format datetimes written in a text file with each event.

    .INPUTS
        System.Object
			You can pipe a Object to this function.

    .OUTPUTS
        None
			None.

    .EXAMPLE
		Write-Log "Some text to log."
			Writes a simple event to a text file in the calling script's directory.
			The file then would have a new line like: 2020/03/23 17:04:01.992;0;Information;Some text to log.
	
	.EXAMPLE
		Write-Log -Object "Some more text to log." -UseEventLog -EventId 42 -EntryType "Warning"
			Writes an event to the Windows Event Log of type 'Warning' and with event ID '42'.
			
    #>
	
	[CmdletBinding(DefaultParameterSetName = "TextFile")]
	Param (
		[Parameter(
				   Position = 0,
				   ValueFromPipeline = $true,
				   ParameterSetName = "TextFile"
				   )]
		[Parameter(
				   Position = 0,
				   ValueFromPipeline = $true,
				   ParameterSetName = "EventLog"
				   )]
		[Object]$Object,
		[Parameter(
				   Position = 1,
				   ParameterSetName = "TextFile"
				   )]
		[System.String]$Path,
		[ValidateSet("Information", "Warning", "Error")]
		[Parameter(
				   Position = 2,
				   ParameterSetName = "TextFile"
				   )]
		[Parameter(
				   Position = 1,
				   ParameterSetName = "EventLog"
				   )]
		[System.Diagnostics.EventLogEntryType]$EntryType = "Information",
		[Parameter(
				   Position = 3,
				   ParameterSetName = "TextFile"
				   )]
		[Parameter(
				   Position = 2,
				   ParameterSetName = "EventLog"
				   )]
		[Int32]$EventId = 0,
		[Parameter(
				   Position = 3,
				   ParameterSetName = "EventLog"
				   )]
		[Switch]$UseEventLog = $false,
		[Parameter(
				   Position = 4,
				   ParameterSetName = "TextFile"
				   )]
		[System.String]$Separator = ";",
		[Parameter(
				   Position = 5,
				   ParameterSetName = "TextFile"
				   )]
		[Switch]$NoNewLine = $false,
		[ValidateSet("Unicode", "UTF8", "ASCII", "Default")]
		[Parameter(
				   Position = 6,
				   ParameterSetName = "TextFile"
				   )]
		[System.String]$Encoding = "UTF8",
		[Parameter(
				   Position = 7,
				   ParameterSetName = "TextFile"
				   )]
		[System.String]$DateTimeFormat = "yyyy/MM/dd HH:mm:ss.fff"
	)
	
	begin
	{
		
		# If Path is not defined,
		# will assign a default path in the directory where the calling script is.
		
		if ([System.String]::IsNullOrEmpty($Path))
		{
			# Gets the name and path of the script.
			
			if ($Host.Name -ne "ConsoleHost")
			{
				if ($null -ne $HostInvocation)
				{
					$ScriptPath = Split-Path $HostInvocation.MyCommand.Path
					$ScriptName = (($HostInvocation.MyCommand.Name).Split("."))[0]
				}
				else
				{
					$ScriptPath = Split-Path ($MyInvocation.MyCommand.Path)
					$ScriptName = (($MyInvocation.MyCommand.Name).Split("."))[0]
				}
			}
			
			$Path = "{0}\{1}.log" -f $ScriptPath, $ScriptName
		}
		
		
		# Encoding
		
		[System.Text.Encoding]$Encoding = [System.Text.Encoding]::$Encoding
	}
	
	process
	{
		if ($UseEventLog)
		{
			Write-EventLog `
						   -LogName Application `
						   -Source $ScriptName `
						   -EventId $EventId `
						   -EntryType $EntryType `
						   -Message $Object
		}
		else
		{
			
			$DateTimeNow = Get-Date -f $DateTimeFormat
			
			if ($NoNewLine)
			{
				$Content = [Char]32 + `
				$Object
			}
			else
			{
				$Content = ([Environment]::NewLine) + `
				$DateTimeNow + `
				$Separator + `
				$EventId + `
				$Separator + `
				
				$EntryType + `
				$Separator + `
				$Object
			}
			
			[System.IO.File]::AppendAllText($Path, $Content, $Encoding)
		}
	}
	
	end
	{
		
	}
}