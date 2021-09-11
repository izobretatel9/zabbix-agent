#
# THIS SCRIPT IS READY TO USE
#

# Install Zabbix agent on Windows
# Tested on Windows Server 2012, 2012R2, 2016, 2019
# Version 2.0
# Created by Vadim_Izobretatel
# Last updated 30/07/2020
# Installs Zabbix Agent optionals version


# Download links for different versions 
# 
#$version446 = "https://www.zabbix.com/downloads/4.4.6/zabbix_agent-4.4.6-windows-amd64.zip"
#$version446ssl = "https://www.zabbix.com/downloads/4.4.6/zabbix_agent-4.4.6-windows-amd64-openssl.zip"
$version500ssl = "https://www.zabbix.com/downloads/5.0.2/zabbix_agent-5.0.2-windows-amd64-openssl.zip"



#Gets the server host name
$serverHostname =  Invoke-Command -ScriptBlock {hostname}


# Asks the user for the IP address of their Zabbix server
$ServerIP = "111.111.11.11" # Сюда вписываем свой Zabbix server


# Creates Zabbix DIR
mkdir c:\zabbix


# Downloads the version you want. Links are up. This script currently as standard downloads version 5.0.0 with SSL option
Invoke-WebRequest "$version500ssl" -outfile c:\zabbix\zabbix.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Unzipping file to c:\zabbix
Unzip "c:\Zabbix\zabbix.zip" "c:\zabbix"      

# Sorts files in c:\zabbix
Move-Item c:\zabbix\bin\zabbix_agentd.exe -Destination c:\zabbix

# Sorts files in c:\zabbix
Move-Item c:\zabbix\conf\zabbix_agentd.conf -Destination c:\zabbix

# Replaces 127.0.0.1 with your Zabbix server IP in the config file
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Replaces hostname in the config file
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Attempts to install the agent with the config in c:\zabbix
c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install

# Attempts to start the agent
c:\zabbix\zabbix_agentd.exe --start

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow
