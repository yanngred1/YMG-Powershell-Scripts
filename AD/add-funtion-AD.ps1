# Import the Server Manager module
Import-Module ServerManager

# Check if the Active Directory feature is already installed
$ad = Get-WindowsFeature | Where-Object { $_.Name -eq "AD-Domain-Services" }

# If Active Directory is not installed, install it
if ($ad.Installed -ne "True") {
  Write-Host "Installing Active Directory feature..."
  Install-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools
  Write-Host "Active Directory feature installed."
} else {
  Write-Host "Active Directory feature is already installed."
}

# Check if the DHCP feature is already installed
$dhcp = Get-WindowsFeature | Where-Object { $_.Name -eq "DHCP" }

# If DHCP is not installed, install it
if ($dhcp.Installed -ne "True") {
  Write-Host "Installing DHCP feature..."
  Install-WindowsFeature -Name "DHCP" -IncludeAllSubFeature -IncludeManagementTools
  Write-Host "DHCP feature installed."
} else {
  Write-Host "DHCP feature is already installed."
}

# Check if the DNS feature is already installed
$dns = Get-WindowsFeature | Where-Object { $_.Name -eq "DNS" }

# If DNS is not installed, install it
if ($dns.Installed -ne "True") {
  Write-Host "Installing DNS feature..."
  Install-WindowsFeature -Name "DNS" -IncludeAllSubFeature -IncludeManagementTools
  Write-Host "DNS feature installed."
} else {
  Write-Host "DNS feature is already installed."
}

# Ask for desired domain name
$domainName = Read-Host "Enter the desired domain name"

# Ask for location of logs
$logPath = Read-Host "Enter the location of logs (e.g. C:\Windows\NTDS)"

# Ask for location of sysvol
$sysvolPath = Read-Host "Enter the location of sysvol (e.g. C:\Windows\SYSVOL)"

# Promote the server to a domain controller
Write-Host "Promoting server to a domain controller..."
Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath $logPath `
                  -DomainMode "Win2012R2" -DomainName $domainName -ForestMode "Win2012R2" `
                  -InstallDns:$true -LogPath $logPath -NoRebootOnCompletion:$false `
                  -SysvolPath $sysvolPath -Force:$true
Write-Host "Server promoted to a domain controller."
