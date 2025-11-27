#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y \
  vim \
  tree \
  curl \
  net-tools \
  unzip \
  zip \
  iproute2 \
  tmux \
  wget \
  xclip \
  software-properties-common \
  telnet \
  python3 \
  python3-venv \
  python3-pip \
  cmake \
  openjdk-17-jre-headless \
  jq \
  p7zip

# Ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible
sudo ansible-galaxy collection install community.general
sudo ansible-galaxy collection install community.docker

# Terraform
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
tfenv install v1.14.0
tfenv use v1.14.0

echo "  -> Utilities installed."
