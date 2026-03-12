FROM rocm/dev-ubuntu-24.04:7.2-complete

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for signal handling, SSH, FFmpeg, and HW debugging
RUN apt-get update && apt-get install -y --no-install-recommends \
    dumb-init \
    openssh-server \
    curl \
    tmux \
    nano \
    ffmpeg \
    vainfo \
    radeontop \
    mesa-va-drivers \
    libva-drm2 \
    pciutils \
    wget \
    less \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# Setup SSH directory privileges
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Configure sshd explicitly — do not rely on distro defaults
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose SSH port
EXPOSE 22

# Use dumb-init to properly handle signal forwarding (crucial for tmux/ssh)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]