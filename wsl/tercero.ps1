# Part Two
# run PowerShell as Administrator

$WarningPreference = "SilentlyContinue"

Set-ExecutionPolicy Bypass -Scope Process -Force

###############################################

Write-Host ''
Write-Host '*** Customize Ubuntu ***'
Write-Host ''

wsl --distribution Ubuntu bash -c "/mnt/c/Temp-WSL-Install/wsl_3_ubuntu.sh"

###############################################

Write-Host ''
read -t 5 -s -p '*** Shutting down WSL and all running distributions ***'
wsl.exe --shutdown

###############################################

Write-Host ''
Write-Host '*** Cleaning up Temorary files ***'
Remove-Item -Path 'C:\Temp-WSL-Install' -Force -Recurse > $null

###############################################

Write-Host ''
Write-Host '*** Done! ***'
