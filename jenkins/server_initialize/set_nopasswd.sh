#!/bin/bash

if [ -f server.env ]; then
    source server.env
else
    echo "❌ FAILED: server.env file not found."
    exit 1
fi

SUDOERS_LINE="${TARGET_USER} ALL=(ALL) NOPASSWD: ALL"

ssh -t ${TARGET_HOST} "echo '${SUDOERS_LINE}' | sudo tee -a /etc/sudoers > /dev/null"

if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: NOPASSWD is configured for ${TARGET_USER}."
else
    echo "❌ FAILED: Check SSH access or existing Sudo rights for ${TARGET_USER}."
fi
