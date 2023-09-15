#!/bin/bash
# Part Three
# Setup basic Ubuntu environmen in WSL2

echo 'Update sudoers'
sudo tee <<EOF /etc/sudoers.d/custom &>/dev/null
${USER}    ALL=(ALL) NOPASSWD:ALL
EOF
sudo chmod 0440 /etc/sudoers.d/custom
echo ''

echo "Add user ${USER} to group docker"
sudo usermod -a -G docker ${USER}
echo ''

echo 'Create /etc/wsl.conf'
sudo tee <<EOF /etc/wsl.conf &>/dev/null
[boot]
systemd=true

[network]
generateResolvConf=false
EOF
echo ''

echo 'Create & enable WSL-VPNKIT service'
sudo tee <<EOF /etc/systemd/system/wsl-vpnkit.service &>/dev/null
[Unit]
Description=wsl-vpnkit
Documentation=https://github.com/sakai135/wsl-vpnkit#readme
After=network.target

[Service]
ExecStart=/mnt/c/Windows/system32/wsl.exe -d wsl-vpnkit -- /app/wsl-vpnkit
Restart=always
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
sudo ln -s /etc/systemd/system/wsl-vpnkit.service /etc/systemd/system/multi-user.target.wants/wsl-vpnkit.service
echo ''

sudo cp /etc/resolv.conf /etc/resolv.conf.bkp &>/dev/null
sudo unlink /etc/resolv.conf &>/dev/null
echo ''

echo 'APT Proxy Setting'
sudo tee <<EOF /etc/apt/apt.conf.d/90-proxy &>/dev/null
Acquire::http::Proxy "http://proxy.sr.se:8080";
Acquire::https::Proxy "http://proxy.sr.se:8080";
Acquire::ftp::Proxy "http://proxy.sr.se:8080";
EOF
echo ''

echo 'Update Ubuntu'
# Setup Resolve conf
RESOLVE_DIR=$(mktemp -d)
RESOLVE_SR=$(mktemp -p "$RESOLVE_DIR")
RESOLVE_CITY=$(mktemp -p "$RESOLVE_DIR")
RESOLVE_CONF=$(mktemp -p "$RESOLVE_DIR")
for X in $(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-DnsClientServerAddress -AddressFamily ipv4 | Select-Object -ExpandProperty ServerAddresses" | grep '^134.25' | sort | uniq | tr -d '\r')
  do echo "nameserver $X" >> "$RESOLVE_SR"
done
for Z in $(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-DnsClientServerAddress -AddressFamily ipv4 | Select-Object -ExpandProperty ServerAddresses" | grep -v '^134.25' | sort | uniq | tr -d '\r')
  do echo "nameserver $Z" >> "$RESOLVE_CITY"
  done
cat "$RESOLVE_SR" "$RESOLVE_CITY" > "$RESOLVE_CONF"
echo 'search sr.se'>> "$RESOLVE_CONF"
sudo cp "$RESOLVE_CONF" /etc/resolv.conf
sudo chmod 0644 /etc/resolv.conf
sudo chown root:root /etc/resolv.conf
rm -rf "$RESOLVE_DIR"

# APT Update & Upgrade
sudo apt update --quiet
sudo apt full-upgrade --quiet --yes
sudo apt autoremove --quiet --yes
sudo apt clean
echo ''

echo 'Setup SSL Trust for Sveries Radio'
sudo mkdir -p /usr/local/share/ca-certificates/sverigesradio
echo ' Sveriges Radio CA Root'
echo ' > /usr/local/share/ca-certificates/sverigesradio/Sveriges_Radio_CA_Root.crt'
sudo tee <<EOF /usr/local/share/ca-certificates/sverigesradio/Sveriges_Radio_CA_Root.crt &>/dev/null
-----BEGIN CERTIFICATE-----
MIIHADCCBOigAwIBAgIULGXN2mI4r03XicMcB5nt59irz80wDQYJKoZIhvcNAQEL
BQAwSjELMAkGA1UEBhMCU0UxGjAYBgNVBAoMEVN2ZXJpZ2VzIFJhZGlvIEFCMR8w
HQYDVQQDDBZTdmVyaWdlcyBSYWRpbyBDQSBSb290MB4XDTIwMTIxODEwNDYxN1oX
DTMwMTIxODEwNDYxNlowUzELMAkGA1UEBhMCU0UxGjAYBgNVBAoMEVN2ZXJpZ2Vz
IFJhZGlvIEFCMSgwJgYDVQQDDB9TdmVyaWdlcyBSYWRpbyBDQSBJc3N1aW5nIDEg
djAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxwyViExQ6DCOXf6O
jPzHTosHHNvtzVwdDv7c+Eyo4cX6eiZHywcVZH0TPzAVETeqow9/FDwBCA6XZmES
FjepMYp87WP36HSSheKQFMSTANrMrtXfOLloJrajmmCYuEwrKLGqVLoLwklsu+Qa
uTJ0fhdlsbTZ5rMMicBYZ/WWR0Ml1EWGLPssEYwFFrGCwZ69y4LMxrZvitVQEwxT
f3g3bYwyken97E45yfiTAUZrH43s70Hpw+Y7uy6upYMhaXdS0LwTsWv1xacFOlHS
URw3DGc9QOT2BqFutUM14s/sBilYpBHdik3/agnKDqpKPZbq5fwp8vlUsxsIXFf1
33rp7Yz22WK91K+6u3pLFhXRYpn8sP8qRd/Y5WetyMaKFwYGu1clabhV2wqnwB9/
7K9349c8ClOO0osK4FYrfIQ3ApqLP/mYz5GDtq8jyYvSCewmVlg6CFSdiT2TcubK
+tI760MWV578gko4PoqMZnDRJP20aWNWF3j5VDZGvGeuxin1pdBDZGIJhNFK8JI0
pDa7vJkJ0D7diPSKOrjwBCLs8Po+2roFZRYF4ML6EqiJwDob7LQXaxkuQJqJ6O0P
SJQ3s6MBzrDY2r6pYEtSs7SurT/+Ni/pFAJR1eebYdjDte3KlghCZyX/0sChv4Di
wydXQbck5v5xX39rfNRqP61Gu8cCAwEAAaOCAdMwggHPMBIGA1UdEwEB/wQIMAYB
Af8CAQAwHwYDVR0jBBgwFoAU43rdQbeZlT7ccaEECbHR0DP+d+EwgYUGCCsGAQUF
BwEBBHkwdzA0BggrBgEFBQcwAoYoaHR0cDovL3BraS5zci5zZS9TdmVyaWdlc1Jh
ZGlvQ0FSb290LmNlcjA/BggrBgEFBQcwAoYzaHR0cDovL3N2ZXJpZ2VzcmFkaW8u
c2UvcGtpL1N2ZXJpZ2VzUmFkaW9DQVJvb3QuY2VyMGsGA1UdIARkMGIwYAYIKwYB
BAGCpQ0wVDAsBggrBgEFBQcCAjAgHh4AUwBSACAAbABlAGcAYQBsACAAcABvAGwA
aQBjAHkwJAYIKwYBBQUHAgEWGGh0dHA6Ly9wa2kuc3Iuc2UvY3BzLnBkZjB0BgNV
HR8EbTBrMC6gLKAqhihodHRwOi8vcGtpLnNyLnNlL1N2ZXJpZ2VzUmFkaW9DQVJv
b3QuY3JsMDmgN6A1hjNodHRwOi8vc3ZlcmlnZXNyYWRpby5zZS9wa2kvU3Zlcmln
ZXNSYWRpb0NBUm9vdC5jcmwwHQYDVR0OBBYEFF3Gh1Vi4vtuKoXmPBGCBfYt/YTF
MA4GA1UdDwEB/wQEAwIBhjANBgkqhkiG9w0BAQsFAAOCAgEAfhCsljW7mkC82DHC
CW9fznVJn2kJejY8FUThmVLWC71evyPMuti3xc/yt94uDJ1cYQ6s73w77I5QALVs
4CTfFi51k6d/O3bN64hQWwqTgCgHS2JobgX5kQyKRnIU3QVN5EI5N1DHuGwGJpXa
FkTG8C7pT162z5cn3iSMNR8fZCf/hkfkFoA51VLGeu1lzGFVbQyd99sjBaowyW15
KAQWEAAqyrA30uJJfaWPdCbOIevMBCsPlMLViNeA+p7xOG/TRn5QPQ8wRg56/aE2
7T1pQsF87KjN2D5WMpGTXM05g6EIyxQZ3+79j0mp7KwOBD3+YhhIed8LAH1SnulE
6d3WSjXA+3AY0a0x0gd1LG8mZUuyubbO40N0ShunZg+wgsAVKxYWKuCr3JLuk/kL
ugMMehmFSHLcXNehx5gRe/K5/4LDi7Ih+9HW24A1Q0LjCLNKkCxZ1nYoEb5gt6j4
PrtNdc2hn86r2j2uzeXq1oU3ySBIbL4Q1Ozau6JA1wy6GrZiHRMRHRnz575FAH5f
pz6F9K6Jhu4fH7QGDOb6b+RIQM3vyDxrdFaf2cyZlr9Q8Ix9bdRhlnqIAtPEOqXe
6kPp5c2KdmsUymkDH6C0AUCMwL/G6Do9BKmzh52XVGXGRpUF9BjE8f/z45YUf4QH
ntNlpOOzjrCgsav1pG0BBzcUcqM=
-----END CERTIFICATE-----
EOF
echo ''

echo ' Sveriges Radio CA Issuing 1 version 01'
echo ' > /usr/local/share/ca-certificates/sverigesradio/Sveriges_Radio_CA_Issuing_1_v01.crt'
sudo tee <<EOF /usr/local/share/ca-certificates/sverigesradio/Sveriges_Radio_CA_Issuing_1_v01.crt &>/dev/null
-----BEGIN CERTIFICATE-----
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
bpmkHOmiC90f4Cf7SlSxx2Y=
-----END CERTIFICATE-----
EOF
echo ''

echo 'Install SSL certificates system wide'
sudo update-ca-certificates
echo ''

echo 'Setup Personal Proxy Configuration'
mkdir ~/.environment.d &>/dev/null
cat <<EOF> ~/.environment.d/set-proxy
echo '  - bash'
export http_proxy="http://proxy.sr.se:8080" &>/dev/null
export https_proxy="http://proxy.sr.se:8080" &>/dev/null
export ftp_proxy="http://proxy.sr.se:8080" &>/dev/null
export no_proxy="localhost,127.0.0.1,::1,.sr.se" &>/dev/null
#
echo '  - git'
# Global proxy settings
git config --global http.proxy http://proxy.sr.se:8080 &>/dev/null
git config --global https.proxy http://proxy.sr.se:8080 &>/dev/null
#
# Disable proxy for GitLab on-prem and ignore SSL certifcate verification
git config --global http.https://gitlab.sr.se.sslVerify false &>/dev/null
git config --global http.https://gitlab.sr.se.proxy '' &>/dev/null
git config --global https.https://gitlab.sr.se.sslVerify false &>/dev/null
git config --global https.https://gitlab.sr.se.proxy '' &>/dev/null
#
# Disable proxy for GitHub on-prem
git config --global http.https://github.sr.se.proxy '' &>/dev/null
git config --global https.https://github.sr.se.proxy '' &>/dev/null
#
echo '  - npm'
npm config set proxy http://proxy.sr.se:8080 &>/dev/null
npm config set https-proxy http://proxy.sr.se:8080 &>/dev/null
#
echo '  - yarn'
yarn config set proxy http://proxy.sr.se:8080 &>/dev/null
yarn config set https-proxy http://proxy.sr.se:8080 &>/dev/null
EOF

cat <<EOF> ~/.environment.d/unset-proxy
echo '  - bash'
unset http_proxy &>/dev/null
unset https_proxy &>/dev/null
unset ftp_proxy &>/dev/null
unset no_proxy &>/dev/null
#
echo '  - git'
git config --global --unset http.proxy &>/dev/null
git config --global --unset https.proxy &>/dev/null
#
echo '  - npm'
npm config delete proxy &>/dev/null
npm config delete https-proxy &>/dev/null
#
echo '  - yarn'
yarn config delete proxy &>/dev/null
yarn config delete https-proxy &>/dev/null
EOF

cat <<EOF> ~/.wgetrc
use_proxy   = yes
https_proxy = http://proxy.sr.se:8080
http_proxy  = http://proxy.sr.se:8080
ftp_proxy   = http://proxy.sr.se:8080
no_proxy    = localhost,127.0.0.1,::1,.sr.se
EOF

echo 'Update ~/.bashrc'
cat <<EOF>> ~/.bashrc

# Setup PROXY
# Function for updating /etc/resolv.conf
RESOLVE_DIR=\$(mktemp -d)
RESOLVE_SR=\$(mktemp -p "\$RESOLVE_DIR")
RESOLVE_CITY=\$(mktemp -p "\$RESOLVE_DIR")
RESOLVE_CONF=\$(mktemp -p "\$RESOLVE_DIR")
resolve_conf() {
  for X in \$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-DnsClientServerAddress -AddressFamily ipv4 | Select-Object -ExpandProperty ServerAddresses" | grep '^134.25' | sort | uniq | tr -d '\r')
    do echo "nameserver \$X" >> "\$RESOLVE_SR"
  done
  for Z in \$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-DnsClientServerAddress -AddressFamily ipv4 | Select-Object -ExpandProperty ServerAddresses" | grep -v '^134.25' | sort | uniq | tr -d '\r')
    do echo "nameserver \$Z" >> "\$RESOLVE_CITY"
   done
  cat "\$RESOLVE_SR" "\$RESOLVE_CITY" > "\$RESOLVE_CONF"
  echo 'search sr.se'>> "\$RESOLVE_CONF"
  sudo cp "\$RESOLVE_CONF" /etc/resolv.conf
  sudo chmod 0644 /etc/resolv.conf
  sudo chown root:root /etc/resolv.conf
  rm -rf "\$RESOLVE_DIR"
}

echo 'Setting up Proxy environment'
echo '  - apt'
sudo sed -i 's/#//g' /etc/apt/apt.conf.d/90-proxy
source "\$HOME"/.environment.d/set-proxy
sed -i '/^use_proxy/ s/no/yes/' ~/.wgetrc
echo '  - resolve.conf'
resolve_conf

EOF
echo ''

echo 'Update PATH environment variable'
export PATH=${HOME}/bin:${PATH}
echo ''

echo 'Disable terminal bell'
sudo sed -i 's/^# set bell-style none/set bell-style none/g' /etc/inputrc
echo ''

echo '*** Ubuntu installation and configuration done!'
echo ''
