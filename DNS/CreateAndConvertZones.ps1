Get-ChildItem C:\Zonas\ | ForEach-Object {
	$ZoneName = $_.Name
	Add-DnsServerSecondaryZone -MasterServers <IP> -Name $ZoneName -ZoneFile "$($ZoneName).dns"
}

Get-ChildItem C:\Zonas\ | ForEach-Object {
	$ZoneName = $_.Name
	ConvertTo-DnsServerPrimaryZone $ZoneName -PassThru -Verbose -ZoneFile "$($ZoneName).dns" -Force
	ConvertTo-DnsServerPrimaryZone $ZoneName -PassThru -Verbose -ReplicationScope Domain -Force
	Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType NS | Where-Object {$_.RecordData.NameServer -like "ns*"} | Remove-DnsServerResourceRecord -ZoneName $ZoneName -Force
}
