FROM rocm/dev-ubuntu-24.04:7.2

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup SSH directory privileges
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose SSH port
EXPOSE 22

# Use dumb-init to properly handle signal forwarding (crucial for tmux/ssh)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]