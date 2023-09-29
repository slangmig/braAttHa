#!/usr/bin/env bash

apt-get update --quiet --quiet
apt-get upgrade --no-show-upgraded --no-install-recommends --quiet --quiet --yes
apt-get install --no-install-recommends --quiet --quiet --yes curl
#
mkdir -p /usr/local/share/ca-certificates/<org>
curl -SsLk -o /usr/local/share/ca-certificates/<org>/Org_CA_Root.crt 'https://<url-to-certificate>'
update-ca-certificates
#
echo "vm.swappiness=0" | tee /etc/sysctl.d/10-swapiness.conf &>/dev/null
/sbin/sysctl --quiet --system  &>/dev/null
#
echo 'Configure MultiPath'
tee -a <<EOF /etc/multipath.conf &>/dev/null
blacklist {
    devnode "^sd[a-z]"
    device {
      vendor "VBOX"
      product "HARDDISK"
   }
}
EOF
#
echo 'Install personal public ssh key'
echo 'ssh-rsa xxxxxxxxxxxx linux-key' | tee -a /home/vagrant/.ssh/authorized_keys &>/dev/null
echo 'ssh-rsa zzzzzzzzzzzz windows-key' | tee -a /home/vagrant/.ssh/authorized_keys &>/dev/null
#
echo 'Install docker'
apt-get install --no-install-recommends --quiet --yes docker.io
sleep 2
usermod -a -G docker vagrant
#
echo 'Install kubectl'
curl -SsLkO https://cdn.dl.k8s.io/release/v1.25.11/bin/linux/amd64/kubectl
sleep 2
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl completion bash | tee /etc/bash_completion.d/kubectl &>/dev/null
chmod a+r /etc/bash_completion.d/kubectl
#
echo 'Install KinD'
curl -SsLko ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
sleep 2
chmod +x ./kind
sleep 1
mv ./kind /usr/local/bin/kind
#
echo 'Install Helm'
mkdir /tmp/helm-install
cd /tmp/helm-install
curl -SsLkO https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz
sleep 2
tar -zxf helm-v3.12.3-linux-amd64.tar.gz
sleep 1
chown root:root linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm
cd
rm -fr /tmp/helm-install
#
sudo -u vagrant helm repo add kyverno https://kyverno.github.io/kyverno/
sudo -u vagrant helm repo add bitnami https://charts.bitnami.com/bitnami/
sudo -u vagrant helm repo add eugenmayer https://eugenmayer.github.io/helm-charts/
#
echo 'Install kind-cluster'
curl -SsLko ./kind-cluster https://<PAT>@raw.githubusercontent.com/<path-to-repository>/main/kind/kind-cluster
chmod +x ./kind-cluster
mv ./kind-cluster /usr/local/bin/kind-cluster
#
sync
sync
sync
sleep 30
systemctl reboot
