function GetRolesInfo{
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n################################################[Roles]################################################"
    
    #Gets all roles installed on server
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[Installed Roles]---------"
    Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
}
 
function GetDHCPInfo{
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n################################################[DHCP]################################################"
    
    #Gets DHCP-Scope
    Get-DhcpServerv4Scope |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
 
    #Gets all leased IP-addresses
    Get-DhcpServerv4Lease -ComputerName "ad-dc-01.gaarslev-gartneriet.local" -ScopeId 10.0.0.0 |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
}
 
function GetDNSInfo{
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n################################################[DNS]################################################"
    
    #Gets DNS forwarder IP
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[DNS Forwarder]---------"
    Get-DnsServerForwarder |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
 
    #Gets DNS Records, and filters out "@", "DomainDnsZones" and "ForestDnsZones"
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[DNS Records]---------"
    Get-DnsServerResourceRecord -ZoneName "gaarslev-gartneriet.local" -RRType A | Where-Object {$_.HostName -ne "@" -and $_.HostName -ne "DomainDnsZones" -and $_.HostName -ne "ForestDnsZones"} |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
}
 
function GetDFSInfo{
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n################################################[DFS]################################################"
    
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[Main DFS-NameSpace]---------"
    Get-DfsnRoot | Out-String | Add-Content -Path $HOME\Desktop\ServerLog.txt
 
    #Gets all shares and adds it to $shares, and outputs it to ServerLog file
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[DFS-NameSpaces]---------"
    $shares = @()
    $DFSshares = Get-DfsnFolder -path '\\gaarslev-gartneriet.local\Gaarslev-gartneriet\*' 
    foreach($dfsshare in $DFSshares){
        $shares += Get-DfsnFolderTarget -path $dfsshare.path | Select-Object targetpath | Out-String
    }
    Add-Content -Path $HOME\Desktop\ServerLog.txt -Value $shares
}
 
function GetShareInfo{
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n################################################[SMB-Share]################################################"
 
    #Gets all SMB-Shares, and filters out default shares
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[All SMB-Shares]---------"
    Get-WmiObject Win32_Share | Where-Object {$_.Name -ne "ADMIN$" -and $_.Name -ne "C$" -and $_.Name -ne "E$" -and $_.Name -ne "IPC$" -and $_.Name -ne "NETLOGON" -and $_.Name -ne "REMINST" -and $_.Name -ne "SYSVOL"} |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
    
    #Gets all SMB-Shares and whos has permissions
    Add-Content -Path $HOME\Desktop\ServerLog.txt "`n---------[SMB-Shares Permissions]---------"
    $output = @();
    $SMBShare = Get-WmiObject Win32_Share | Where-Object {$_.Name -ne "ADMIN$" -and $_.Name -ne "C$" -and $_.Name -ne "E$" -and $_.Name -ne "IPC$" -and $_.Name -ne "NETLOGON" -and $_.Name -ne "REMINST" -and $_.Name -ne "SYSVOL"}
    foreach($i in $SMBShare){
        $output += Get-SmbShareAccess -Name $i.Name | 
        Format-list |
        Out-String
    }
    Add-Content -Path $HOME\Desktop\ServerLog.txt -Value $output
}
 
Function GetGPOInfo{
    Get-GPO -All -Domain "gaarslev-gartneriet.local" | 
        Select-Object DisplayName, DomainName, Owner, ID | 
        Where-Object {$_.DisplayName -ne "Default Domain Policy" -and $_.DisplayName -ne "Default Domain Controllers Policy"} |
        Out-String | 
        Add-Content -Path $HOME\Desktop\ServerLog.txt
}
GetRolesInfo
GetDHCPInfo
GetDNSInfo
GetDFSInfo
GetShareInfo
GetGPOInfo
 
#Clear up the whole output file for empty spaces
(Get-Content $HOME\Desktop\ServerLog.txt) | Where-Object {$_.trim() -ne "" } | Set-Content $HOME\Desktop\ServerLog.txt
