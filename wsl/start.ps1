# Part One
# run PowerShell as Administrator

Write-Host 'Enable Script Execution'
Set-ExecutionPolicy Bypass -Scope Process -Force

###############################################

Write-Host 'Create Temporary Installation directroy'
mkdir C:\Temp-WSL-Install > $null

###############################################

Write-Host ''
Write-Host '*** Download stage ***'
Write-Host ''

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

Write-Host 'Download wsl_2_installation.ps1'
$File="C:\Temp-WSL-Install\wsl_2_installation.ps1"
$Url="https://raw.github.sr.se/sverigesradio/wsl_installation/main/scripts/wsl_2_installation.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

Write-Host 'Download wsl_3_ubuntu.ps1'
$File="C:\Temp-WSL-Install\wsl_3_ubuntu.ps1"
$Url="https://raw.github.sr.se/sverigesradio/wsl_installation/main/scripts/wsl_3_ubuntu.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

Write-Host 'Download wsl_3_ubuntu.sh'
$File="C:\Temp-WSL-Install\wsl_3_ubuntu.sh"
$Url="https://raw.github.sr.se/sverigesradio/wsl_installation/main/scripts/wsl_3_ubuntu.sh"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

Write-Host 'Download wslconfig'
$File="C:\Temp-WSL-Install\wslconfig"
$Url="https://raw.github.sr.se/sverigesradio/wsl_installation/main/scripts/wslconfig"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

Write-Host 'Download WSL Linux Kernel Update'
$File="C:\Temp-WSL-Install\wsl_update_x64.msi"
$Url="https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

Write-Host 'Download Chocolatey'
$File="C:\Temp-WSL-Install\chocolatey_install.ps1"
$Url="https://community.chocolatey.org/install.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

Write-Host 'Download WSL-VPNKIT'
$Url="https://github.com/sakai135/wsl-vpnkit/releases/download/v0.4.1/wsl-vpnkit.tar.gz"
$File="C:\Temp-WSL-Install\wsl-vpnkit.tar.gz"
(New-Object -TypeName System.Net.WebClient).DownloadFile($Url, $File)

###############################################

Write-Host ''
Write-Host '*** Hyper-V stage ***'
Write-Host ''

Write-Host 'Disable Hyper-V Feature'
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -norestart

Write-Host 'Disable HypervisorPlatform Feature'
Disable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -norestart

Write-Host 'Disable Hyper-V Launch'
bcdedit /set hypervisorlaunchtype off

###############################################

Write-Host ''
Write-Host '*** WSL stage ***'
Write-Host ''

Write-Host 'Enable WSL2'
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -all -norestart

Write-Host 'Enable VirtualMachinePlatform'
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -all -norestart

###############################################

Write-Host ''
Write-Host '*** Restarting Computer Now ***'
timeout /t -1
Restart-Computer
