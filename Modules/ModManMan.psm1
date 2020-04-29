
function Update-ModuleManifestVersioning
{
    [CmdletBinding(SupportsShouldProcess=$true)]
	[OutputType([PSCustomObject])]
	Param
	(
		[Parameter(
				   Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true
				   )]
		[String[]]$Path
    )
    
    begin 
    {
    
    }

    process 
    {
        foreach ($SinglePath in $Path) 
        {
            if (!(Test-Path -LiteralPath $SinglePath)) 
            {
                $Exception = New-Object System.Management.Automation.ItemNotFoundException "Cannot find path '$($SinglePath)' because it does not exist."
                $Category = [System.Management.Automation.ErrorCategory]::ObjectNotFound
                $ErrRecord = New-Object System.Management.Automation.ErrorRecord $Exception,'PathNotFound',$Category,$SinglePath
                $PSCmdlet.WriteError($ErrRecord)
                continue
            }
        
            # Resolve any relative paths
            $SinglePath = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($SinglePath)

            if ($PSCmdlet.ShouldProcess($SinglePath, "Update Manifest File"))
            {
                $Manifest = Import-PowerShellDataFile $SinglePath
                [Version]$NewVersion = "$(([Version]$Manifest.ModuleVersion).Major).$(([Version]$Manifest.ModuleVersion).Minor).$(([Version]$Manifest.ModuleVersion).Build +1)"
                Update-ModuleManifest -Path $SinglePath -ModuleVersion $NewVersion
            }
        }
    }    

    end 
    {

    }
    
}