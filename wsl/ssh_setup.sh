#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONFIG_FILE="$DIR/ssh_config.env"

# Load config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file '$CONFIG_FILE' not found at expected path: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

PRIVATE_KEY_PATH="$HOME/.ssh/$KEY_NAME"
PUBLIC_KEY_PATH="$HOME/.ssh/${KEY_NAME}.pub"
SSH_CONFIG_FILE="$HOME/.ssh/config"

echo "--- SSH SETUP START ---"
echo "Host: ${SSH_HOST} (${SERVER_IP})"

# 1. Check/Generate SSH Key
echo "1. Key check/gen..."
if [ -f "$PRIVATE_KEY_PATH" ]; then
    echo "  -> Key exists. Using existing key."
else
    # SSH Key Generation (assuming you want to skip if key exists)
    ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY_PATH" -N ""
    if [ $? -ne 0 ]; then
        echo "  -> ERROR: Key generation failed."
        exit 1
    fi
    echo "  -> New key generated."
fi

# 2. Copy Public Key to Target
echo "2. Copying public key to ${SERVER_USER}@${SERVER_IP}..."
ssh-copy-id -i "$PUBLIC_KEY_PATH" "${SERVER_USER}@${SERVER_IP}"
if [ $? -ne 0 ]; then
    echo "  -> ERROR: ssh-copy-id failed. Check password/connection."
    exit 1
fi
echo "  -> Key copied."

# 3. Update ~/.ssh/config
echo "3. Updating ~/.ssh/config..."
CONFIG_BLOCK=$(cat <<EOF
Host $SSH_HOST
  HostName $SERVER_IP
  User $SERVER_USER
  IdentityFile $PRIVATE_KEY_PATH
EOF
)

# Create config file if not exists
if [ ! -f "$SSH_CONFIG_FILE" ]; then
    mkdir -p "$HOME/.ssh"
    touch "$SSH_CONFIG_FILE"
    chmod 700 "$HOME/.ssh"
fi

# Remove old config block if exists
if grep -q "Host $SSH_HOST" "$SSH_CONFIG_FILE" 2>/dev/null; then
    sed -i "/Host $SSH_HOST/,+3 d" "$SSH_CONFIG_FILE"
fi

# Append new config
echo "$CONFIG_BLOCK" >> "$SSH_CONFIG_FILE"
chmod 600 "$SSH_CONFIG_FILE"

echo "  -> Config updated. Test with 'ssh ${SSH_HOST}'"
echo "--- SSH SETUP COMPLETE ---"