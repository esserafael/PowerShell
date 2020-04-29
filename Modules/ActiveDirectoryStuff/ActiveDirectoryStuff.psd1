@{
	RootModule = 'ActiveDirectoryStuff.psm1'
	ModuleVersion = '1.0.1'
	GUID = 'fd25259e-9717-4a76-ad10-fb4ed108db05'
	Author = 'Rafael Alexandre Feustel Gustmann'
	CompanyName = ''
	Copyright = ''
	Description = 'A bunch of functions to help do Active Directory stuff.'
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
	NestedModules = @()
	FunctionsToExport = @(
		'Test-ADCredential'
	)
	CmdletsToExport = '*' 
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
