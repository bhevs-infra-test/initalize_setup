#!/bin/bash

# Load environment variables from nopasswd.env file
if [ -f nopasswd.env ]; then
    source nopasswd.env
else
    echo "❌ FAILED: nopasswd.env file not found."
    exit 1
fi

# Define the line to be added to /etc/sudoers
SUDOERS_LINE="${TARGET_USER} ALL=(ALL) NOPASSWD: ALL"

echo "--- START: Setting up NOPASSWD on ${TARGET_HOST} ---"
echo "⚠️ Sudo password may be required for ${TARGET_HOST}."

# Add NOPASSWD line to the remote server's sudoers file
ssh -t ${TARGET_HOST} "echo '${SUDOERS_LINE}' | sudo tee -a /etc/sudoers > /dev/null"

if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: NOPASSWD is configured for ${TARGET_USER}."
else
    echo "❌ FAILED: Check SSH access or existing Sudo rights for ${TARGET_USER}."
fi
