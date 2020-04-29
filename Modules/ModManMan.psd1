@{
	RootModule = 'ModManMan.psm1'
	ModuleVersion = '1.0.0'
	GUID = 'faf2a84e-7593-4f79-83e6-9e0f2a285d3b'
	Author = 'Rafael Alexandre Feustel Gustmann'
	CompanyName = ''
	Copyright = ''
	Description = 'ModManMan (Module Manifest Manager) helps me a little in doing boring module manifests management.'
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
		'Update-ModuleManifestVersioning'
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
