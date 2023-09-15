# Dockerfile for Ansible container
FROM ubuntu:20.04

ENV TZ=Europe/Stockholm
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ARG MYUSR=ansible
ARG UID=1000
ARG GID=1000

# Copy needed configuration files
COPY Files/ /

# APT update & upgrade
RUN apt-get -qq update && \
    apt-get -qq -y --no-show-upgraded --no-install-recommends upgrade && \
## Install some packages
    apt-get -qq -y --no-install-recommends install sudo openssl openssh-client curl wget less tree apt-utils ca-certificates && \
## Install packages needed by Ansible
    apt-get --quiet --yes --no-install-recommends install sshpass python3 python3-pip python3-winrm python3-hvac python3-botocore python3-boto3 jq git && \
## Install Ansible Core
    pip3 install --no-cache-dir --proxy ${HTTP_PROXY} ansible-core && \
## Create ansible user
    useradd -s /bin/bash -G sudo,adm -p $(openssl passwd ${MYUSR}) -c "Ansible User" ${MYUSR} && \
    chown -R ${MYUSR}:${MYUSR} /home/${MYUSR} && \
## Clean up
    rm -rf /var/lib/apt/lists/* /tmp/*

# Run as user ansible
USER ${MYUSR}

# Start in the ansible directory
WORKDIR /${MYUSR}
