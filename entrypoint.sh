#!/bin/bash
set -e

# /var/run/sshd may not survive across container restarts if /var/run is tmpfs
mkdir -p /var/run/sshd

# Persist SSH host keys so clients don't get "host key changed" warnings
# across container recreates. Keys are stored in /root/.ssh/host_keys/
# which survives if /root is mounted as a volume.
HOST_KEY_STORE=/root/.ssh/host_keys
mkdir -p "$HOST_KEY_STORE"

if [ -z "$(ls -A "$HOST_KEY_STORE" 2>/dev/null)" ]; then
    # First run: generate keys and save to persistent store
    ssh-keygen -A
    cp /etc/ssh/ssh_host_* "$HOST_KEY_STORE/"
    echo "Generated new SSH host keys (stored in $HOST_KEY_STORE)"
else
    # Subsequent runs: restore saved keys so clients see the same fingerprint
    cp "$HOST_KEY_STORE"/ssh_host_* /etc/ssh/
    chmod 600 /etc/ssh/ssh_host_*_key
    echo "Restored SSH host keys from $HOST_KEY_STORE"
fi

# Ensure correct ownership and permissions on /root (critical when mounted as a volume —
# sshd refuses key auth if the home directory is group- or world-writable)
chown root:root /root
chmod 750 /root

# Ensure .ssh dir exists (important when /root is a mounted volume)
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Check if a GitHub user is provided to set up SSH access
if [ -n "$GITHUB_USER" ]; then
    echo "GitHub user '$GITHUB_USER' provided. Fetching SSH public keys..."
    
    # Download public keys directly from GitHub
    if ! curl -sSLf "https://github.com/${GITHUB_USER}.keys" > /root/.ssh/authorized_keys; then
        echo "ERROR: Failed to fetch SSH keys for GitHub user '${GITHUB_USER}'"
        exit 1
    fi

    KEY_COUNT=$(wc -l < /root/.ssh/authorized_keys)
    echo "Installed ${KEY_COUNT} SSH public key(s) for '${GITHUB_USER}'"

    # Ensure correct permissions, otherwise SSH daemon will reject the keys
    chmod 600 /root/.ssh/authorized_keys

    echo "Starting OpenSSH server..."
    # Start SSH daemon, log to stderr so 'docker logs' captures it
    /usr/sbin/sshd -E /proc/1/fd/2
else
    echo "No GITHUB_USER environment variable provided. SSH server will NOT be started."
fi

echo "====================================================="
echo " AMD ROCm Playground is up and running!"
echo " Debug tools available: rocm-smi, vainfo, radeontop"
echo "====================================================="

# "Null entry" to prevent the container from immediately exiting
exec tail -f /dev/null