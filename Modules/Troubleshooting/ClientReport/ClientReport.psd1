@{
	RootModule = 'ClientReport.psm1'
	ModuleVersion = '0.0.1'
	GUID = '9f9aa31b-3fbb-48c5-9f74-8283d3b15cee'
	Author = 'Rafael Alexandre Feustel Gustmann'
	CompanyName = ''
	Copyright = ''
	Description = 'A bunch of functions to help troubleshoot basic Windows configurations.'
	PowerShellVersion = '5.0'
	PowerShellHostName = ''
	PowerShellHostVersion = ''
	DotNetFrameworkVersion = '4.5'
	CLRVersion = '4.0.0'
	ProcessorArchitecture = 'None'
	RequiredModules = @()
	RequiredAssemblies = @()
	ScriptsToProcess = @()
	TypesToProcess = @()
	FormatsToProcess = @()
	NestedModules = @(
		"ClientReport-Config.ps1"
	)
	FunctionsToExport = @(
		'Test-InternetConnection'
	)
	CmdletsToExport = @() 
	VariablesToExport = '*'
	AliasesToExport = @()
	ModuleList = @()
	FileList = @()
	PrivateData = @{
		PSData = @{
			# URL to the license for this module.
			LicenseUri = 'https://github.com/esserafael/PowerShell/blob/master/LICENSE'
			
			# URL to the main website for this project.
			ProjectUri = 'https://github.com/esserafael/PowerShell'			
		}		
	}
}
