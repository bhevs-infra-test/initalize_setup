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
  ansible \
  telnet \
  python3 \
  python3-venv \
  python3-pip \
  cmake \
  p7zip


echo "  -> Utilities installed."
