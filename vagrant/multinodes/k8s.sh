#!/bin/bash
# Prepare host for Kubernetes deployment

echo "vm.swappiness=0" | tee /etc/sysctl.d/10-swapiness.conf &>/dev/null
/sbin/sysctl --quiet --system  &>/dev/null

# Prerequesites
apt-get install -qq --yes apt-transport-https ca-certificates curl gpg

# Install my public ssh key
echo 'XXXXXXXXXXXXXXXXXX' | tee -a /home/vagrant/.ssh/authorized_keys &>/dev/null

# Load needed modules for containerd on boot
cat <<EOF> /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

# Load modules
modprobe overlay
modprobe br_netfilter

# Configure some network settings needed by Kubernetes
cat <<EOF> /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Load the new settings
sysctl --system &>/dev/null

### Install CRI-O
export OS="xUbuntu_20.04"
export VERSION=1.24

curl -sSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/cri-o.$VERSION-$OS.gpg
curl -sSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/cri-o.$OS.gpg

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel-kubic-libcontainers-stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel-kubic-libcontainers-stable-crio-$VERSION.list

apt-get update -qq
apt-get install -qq --yes cri-o cri-o-runc

mkdir /etc/systemd/system/crio.service.d

cat <<EOF> /etc/systemd/system/crio.service.d/http-proxy.conf
[Service]
Environment="HTTPS_PROXY=http://proxy.corp.tld:8080"
Environment="HTTP_PROXY=http://proxy.corp.tld:8080"
Environment="NO_PROXY=localhost,127.0.0.1,::1,192.168.56.0/24,10.0.2.15/24,10.96.0.0/12,10.244.0.0/16,.corp.tld"
EOF

systemctl daemon-reload
systemctl enable crio
systemctl restart crio

# Install kubeadm, kubelet, kubectl & cri-tools
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update -qq

#apt install -qq --yes kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00 cri-tools=1.24.0-00
#apt-mark hold kubelet kubeadm kubectl cri-tools

# Initialize Kubernetes
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=1.24.0 --apiserver-advertise-address 192.168.56.21 --cri-socket /var/run/crio/crio.sock | sudo tee /root/kubeadmin-init.output

#sudo tail -n21 /root/kubeadmin-init.output

# Setup kube configuration
#mkdir -p $HOME/.kube
#cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#chown $(id -u):$(id -g) $HOME/.kube/config

# List control-plane
#kubectl get nodes --output=wide

# Install CNI (Container Network Interface)
#kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# Install docker
apt-get install -y docker.io

# Install kubectl
curl -LO https://cdn.dl.k8s.io/release/v1.25.11/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install KinD
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install Helm
mkdir /tmp/helm-install
cd /tmp/helm-install
curl -LO https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz
tar -zxf helm-v3.12.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
cd
rm -fr /tmp/helm-install
