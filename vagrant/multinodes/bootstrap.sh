#!/bin/bash
# Basics stuff when creating a new host

apt-get update -qq
apt-get upgrade -qq --yes --no-show-upgraded
apt-get autoremove -qq --purge --yes
apt-get clean -qq

# Disable SWAP
swapoff -a
sed -i.bkp '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab

# Remove swap-file if it exist
SWAPFILE=$(ls -1 / | grep 'swap.img')
if [ -f "/$SWAPFILE" ]; then
  rm -f "/$SWAPFILE"
fi

# Install SR CA trust certificates
mkdir -p /usr/local/share/ca-certificates/corp
curl -SsfLk -o /usr/local/share/ca-certificates/corp-cert/CA_Root.crt 'https://-url-'
curl -SsfLk -o /usr/local/share/ca-certificates/corp-cert/CA_Issuing.crt 'https://-url-'
update-ca-certificates
