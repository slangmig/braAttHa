# Part Two
# run PowerShell as Administrator

$WarningPreference = "SilentlyContinue"

Set-ExecutionPolicy Bypass -Scope Process -Force

###############################################

Write-Host ''
Write-Host '*** Install applications stage ***'
Write-Host ''

Write-Host 'Install Chocolatey'
iex 'C:\Temp-WSL-Install\chocolatey_install.ps1'
Write-Host 'Done!'
Write-Host ''

Write-Host 'Install Applications with Chocolatey [choco]'
choco install --no-progress --limit-output --yes curl 7zip paint.net notepadplusplus keepassxc microsoft-windows-terminal vscode mremoteng docker-desktop
Write-Host 'Done!'
Write-Host ''

###############################################

Write-Host ''
Write-Host '*** Install Ubuntu stage ***'
Write-Host ''

Start-Sleep -Seconds 2
Write-Host 'Install WSL Linux Kernel Update'
msiexec.exe /i 'C:\Temp-WSL-Install\wsl_update_x64.msi' /qn /quiet
Write-Host ''

Write-Host 'Install WSL configuration'
Copy-Item -Path "C:\Temp-WSL-Install\wslconfig" -Destination "$env:USERPROFILE\.wslconfig" -Force
Write-Host ''

Write-Host 'Install WSL-VPNKIT'
wsl --import wsl-vpnkit --version 2 $env:USERPROFILE\wsl-vpnkit C:\Temp-WSL-Install\wsl-vpnkit.tar.gz
Write-Host ''

Start-Sleep -Seconds 2
Write-Host 'Restart WSL'
Restart-Service wsl --shutdown
Write-Host ''

Start-Sleep -Seconds 2
Write-Host '***************  IMPORTANT INFORMATION   ********************************************************'
Write-Host 'Install WSL Ubuntu [22.04 LTS] Distribution '
Write-Host 'A new window with the Ubuntu installation will be opened'
Write-Host 'Enter your Windows-AD username and password, the password is "invisible" and to be entered twice'
Write-Host 'When done execute > exit < in the Ubuntu window to continue the installation'
Write-Host '*************************************************************************************************'
timeout /t -1
Start-Process -FilePath 'wsl' -ArgumentList '--install --distribution Ubuntu' -Wait
timeout /t -1
Write-Host ''

Start-Sleep -Seconds 2
Write-Host 'Set Ubuntu as the Default WSL Distribution'
wsl --set-default Ubuntu
Write-Host ''

Write-Host 'List Installed WLS Distributions'
wsl --list --verbose
timeout /t -1
Write-Host ''

###############################################

Start-Sleep -Seconds 2
Write-Host '*** Restarting Computer ***'
timeout /t -1
Restart-Computer
