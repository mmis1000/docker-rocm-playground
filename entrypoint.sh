#!/bin/bash
set -e

# Generate SSH host keys if they are missing
ssh-keygen -A

# Ensure .ssh dir exists (important when /root is a mounted volume)
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Check if a GitHub user is provided to set up SSH access
if [ -n "$GITHUB_USER" ]; then
    echo "GitHub user '$GITHUB_USER' provided. Fetching SSH public keys..."
    
    # Download public keys directly from GitHub
    curl -sSLf "https://github.com/${GITHUB_USER}.keys" > /root/.ssh/authorized_keys
    
    # Ensure correct permissions, otherwise SSH daemon will reject the keys
    chmod 600 /root/.ssh/authorized_keys
    
    echo "Starting OpenSSH server..."
    # Start SSH daemon in the background
    /usr/sbin/sshd
else
    echo "No GITHUB_USER environment variable provided. SSH server will NOT be started."
fi

echo "====================================================="
echo " AMD ROCm Playground is up and running!"
echo " Debug tools available: rocm-smi, vainfo, radeontop"
echo "====================================================="

# "Null entry" to prevent the container from immediately exiting
exec tail -f /dev/null