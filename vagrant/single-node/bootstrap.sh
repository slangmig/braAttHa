    apt-get update --quiet
    apt-get upgrade --yes --quiet --no-show-upgraded
    mkdir -p /usr/local/share/ca-certificates/sverigesradio
    curl -SsfLk -o /usr/local/share/ca-certificates/corp/CA_Root.crt 'https://url'
    curl -SsfLk -o /usr/local/share/ca-certificates/corp/CA_Issuing.crt 'https://url'
    update-ca-certificates
    echo "vm.swappiness=5" | tee /etc/sysctl.d/10-swapiness.conf
    /sbin/sysctl --quiet --system
    
