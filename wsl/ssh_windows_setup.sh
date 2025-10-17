#!/bin/bash

# --- Find the directory this script is in
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONFIG_FILE="$DIR/ssh_config.env"

# --- Load config file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file '$CONFIG_FILE' not found at expected path: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# --- Define paths
PRIVATE_KEY_PATH="$HOME/.ssh/$KEY_NAME"
PUBLIC_KEY_PATH="$HOME/.ssh/${KEY_NAME}.pub"
SSH_CONFIG_FILE="$HOME/.ssh/config"
REMOTE_PUB_KEY_PATH="C:\\Users\\${SERVER_USER}\\${KEY_NAME}.pub" # Windows style path for scp

echo "--- WINDOWS SSH SETUP START ---"
echo "Host: ${SSH_HOST} (${SERVER_IP})"

# --- Step 1: Check/Generate SSH Key on Client ---
echo "1. Checking/Generating SSH key on client..."
if [ -f "$PRIVATE_KEY_PATH" ]; then
    echo "  -> Key already exists. Using existing key."
else
    ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY_PATH" -N ""
    if [ $? -ne 0 ]; then
        echo "  -> ERROR: SSH key generation failed."
        exit 1
    fi
    echo "  -> New key generated successfully."
fi

# --- Step 2: Copy Key and Set Permissions on Windows Server ---
echo "2. Copying public key and setting permissions on ${SERVER_USER}@${SERVER_IP}..."

# 2a. Copy the public key file to the user's home directory on Windows
scp "$PUBLIC_KEY_PATH" "${SERVER_USER}@${SERVER_IP}:${REMOTE_PUB_KEY_PATH}"
if [ $? -ne 0 ]; then
    echo "  -> ERROR: scp failed. Please check your password and network connection."
    exit 1
fi
echo "  -> Public key file copied to Windows server."

# 2b. Define remote PowerShell commands to be executed on the Windows server
REMOTE_COMMANDS=$(cat <<'EOF'
$userHome = $env:USERPROFILE
$sshDir = Join-Path -Path $userHome -ChildPath ".ssh"
$authKeysFile = Join-Path -Path $sshDir -ChildPath "authorized_keys"
$pubKeyFile = Join-Path -Path $userHome -ChildPath "KEY_NAME.pub"
$ErrorActionPreference = "Stop"
try {
    if (-not (Test-Path -Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir }
    Get-Content -Path $pubKeyFile | Add-Content -Path $authKeysFile
    icacls.exe $authKeysFile /inheritance:r
    icacls.exe $authKeysFile /grant "$($env:USERNAME):(F)"
    icacls.exe $authKeysFile /grant "SYSTEM:(F)"
    Remove-Item -Path $pubKeyFile
    Restart-Service sshd
    Write-Host "SUCCESS: SSH key registered and sshd service restarted."
} catch {
    Write-Host "ERROR: An error occurred during remote execution."
    Write-Host $_.Exception.Message
    exit 1
}
EOF
)

# Replace the placeholder KEY_NAME.pub with the actual key name from the .env file
REMOTE_COMMANDS=${REMOTE_COMMANDS//KEY_NAME.pub/${KEY_NAME}.pub}

# 2c. Execute the PowerShell commands on the remote Windows server
ssh "${SERVER_USER}@${SERVER_IP}" "powershell -Command \"${REMOTE_COMMANDS}\""
if [ $? -ne 0 ]; then
    echo "  -> ERROR: Remote PowerShell commands failed."
    exit 1
fi
echo "  -> Key registered and permissions set correctly."

# --- Step 3: Update Client's ~/.ssh/config ---
echo "3. Updating client's ~/.ssh/config file..."

# Define the new configuration block to be added
CONFIG_BLOCK=$(cat <<EOF

Host $SSH_HOST
  HostName $SERVER_IP
  User $SERVER_USER
  IdentityFile $PRIVATE_KEY_PATH
EOF
)

# Ensure .ssh directory and config file exist with correct permissions
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$SSH_CONFIG_FILE"
chmod 600 "$SSH_CONFIG_FILE"

# Create a temporary file to build the new config
TEMP_CONFIG=$(mktemp)

# A flag to check if the host block was found and skipped
BLOCK_SKIPPED=false

# Read the original config file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    # When we find the start of the block we want to replace...
    if [[ "$line" == "Host $SSH_HOST" ]]; then
        # ...set the flag to true, indicating we found the block.
        BLOCK_SKIPPED=true
        # Now we skip the Host line and the next 3 lines of the old block.
        for i in {1..3}; do
            read -r line_to_skip <&0
        done
    else
        # If not in the block to be skipped, write the line to the temp file
        echo "$line" >> "$TEMP_CONFIG"
    fi
done < "$SSH_CONFIG_FILE"

# Replace the original config file with the filtered temporary file
mv "$TEMP_CONFIG" "$SSH_CONFIG_FILE"

# Append the new configuration block to the end of the file
echo "$CONFIG_BLOCK" >> "$SSH_CONFIG_FILE"

echo "  -> Config file updated. You can now test the connection with: ssh ${SSH_HOST}"
echo "--- SSH SETUP COMPLETE ---"