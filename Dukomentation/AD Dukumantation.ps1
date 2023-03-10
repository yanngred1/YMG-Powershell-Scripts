#This is giting the time and date for where you are and makes it a varibul
$dato = get-date -Format yyyy-MM-dd__hh-mm-ss

#This is where the fil wil be crate to
$UdFil = "(File Location)$env:COMPUTERNAME-$dato.txt"

"*"*60 | Out-File $UdFil
"Dokumentation for server: $env:COMPUTERNAME" | Out-File $UdFil -Append
"Dato: $dato" | Out-File $UdFil -Append
"*"*60 | Out-File $UdFil -Append

#This part Findes User in the AD
"*"*60 | Out-File $UdFil -Append
"Brugerer" | Out-File $UdFil -Append
Get-ADUser -Filter 'Surname -like "1"' | Select-Object name, DistinguishedName | Out-File $UdFil -Append

#This part finder groups
"*"*60 | Out-File $UdFil -Append
"Grupper" | Out-File $UdFil -Append
Get-ADGroup -Filter 'Name -like "GR-*"' | Select-Object name, DistinguishedName | Out-File $UdFil -append

# Finder grupper og medlemmer
$grupper = Get-ADGroup -Filter 'Name -like "GR-*"' 
#$grupper | ForEach-Object {Get-ADGroupMember -Identity ($_.name) | select $_.name, name}
$grupper | ForEach-Object {
    $gr=$_.name
    #$gr + "///"
    $g1=Get-ADGroupMember -Identity $_.name | Select-Object name
    Write-Host "======================" | Out-File $UdFil -Append
    write-host $gr  | Out-File $UdFil -Append
    Write-Host $g1.name  | Out-File $UdFil -Append
}


$rr=(Get-DhcpServerv4Scope | Select-Object scopeid) # finder ip på scopet
Get-DhcpServerv4Scope | Out-File $UdFil -append
Get-DhcpServerv4OptionValue -ComputerName $env:COMPUTERNAME -ScopeId $rr.ScopeId.ToString() -all | Sort-Object OptionId | Out-File $UdFil -append

"*"*60 | Out-File $UdFil -Append
"Installed Feature" | Out-File $UdFil -Append
Get-WindowsFeature | Where-Object installed | Out-file $UdFil -Append
"*"*60 | Out-File $UdFil -Append
"Acative Directory" | Out-File $UdFil -Append
Get-ADDomain | Select-Object Distinguishedname,DNSRoot,Name,NetBIOSName | format-list | Out-File $UdFil -Append
"*"*60 | Out-File $UdFil -Append
"Organizational Units" | Out-File $UdFil -Append
Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Select-Object Name,DistinguishedName | Format-Table Name,DistinguishedName | Out-File $UdFil -Append
"*"*60 | Out-File $UdFil -Append
"Share And Perms" | Out-File $UdFil -Append
Get-SmbShare | Get-SmbShareAccess | Format-Table | Out-File $UdFil -Append
Get-ChildItem C:\Share-s1 -Recurse | get-acl |  format-list | Out-File $UdFil -Append
"*"*60 | Out-File $UdFil -Append
"DNS server" | Out-File $UdFil -Append
Get-DnsServer | Out-File $UdFil -Append
"*"*60 | Out-File $UdFil -Append
"DFS Information" | Out-File $UdFil -Append
Get-DfsnRoot | Select-Object Path,Type,State | Format-Table Path,Type,State | Out-File $UdFil -Append
Get-DfsReplicationGroup | Out-File $UdFil -Append
Get-GPOReport -All -ReportType html -Domain BY.Yannick.local -Path '\\172.16.108.244\Delt mappe\GPOReport.html'
