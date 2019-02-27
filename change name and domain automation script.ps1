#-------------------Set Network Settings, Rename network interface--------------------------------------

$ipaddress = “10.1.22.XX”
$ipif = “LAN”
$ipprefix = “23”
$ipgw = “10.1.23.254”
$ipdns = “10.1.22.21,10.1.22.22”
$domainname = “sta.com”
$credential= “sta\ahareth”
Rename-NetAdapter -Name “Ethernet 2” -NewName $ipif
Set-DnsClientServerAddress $ipif -ServerAddresses $ipdns
New-NetIPAddress -InterfaceAlias $ipif -IPAddress $ipaddress -PrefixLength $ipprefix -DefaultGateway $ipgw


#---------------------Rename the Server Netbios name--------------------------------------------------------

$cred = get-credential
$Computer = Get-WmiObject Win32_ComputerSystem
$r = $Computer.Rename("EGY-???-??", $cred.GetNetworkCredential().Password, $cred.Username)
Restart-Computer -force






#------------------Join the member server to the STA Domain and move the computer in the right OU container--------------------

$cred = get-credential
Add-Computer -DomainName STA -Credential $cred -OUPath "OU=Egypt Servers,OU=04Servers,DC=STA,DC=com"
Restart-Computer

