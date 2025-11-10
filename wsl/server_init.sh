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
  p7zip

sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible
sudo ansible-galaxy collection install community.general
sudo ansible-galaxy collection install community.docker

echo "  -> Utilities installed."
