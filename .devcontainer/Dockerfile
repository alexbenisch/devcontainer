FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install base dependencies required for dotfiles setup
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Configure locales
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Create non-root user with sudo access
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER testuser
WORKDIR /home/testuser

# Set up basic shell environment
RUN echo 'export LANG=en_US.UTF-8' >> ~/.bashrc && \
    echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc

# Display welcome message
RUN echo '#!/bin/bash' > /home/testuser/.welcome.sh && \
    echo 'echo ""' >> /home/testuser/.welcome.sh && \
    echo 'echo "=========================================="' >> /home/testuser/.welcome.sh && \
    echo 'echo "  Dotfiles Testing Environment"' >> /home/testuser/.welcome.sh && \
    echo 'echo "=========================================="' >> /home/testuser/.welcome.sh && \
    echo 'echo ""' >> /home/testuser/.welcome.sh && \
    echo 'echo "Quick start:"' >> /home/testuser/.welcome.sh && \
    echo 'echo "  1. git clone https://github.com/alexbenisch/dotfiles.git ~/.local/share/dotfiles"' >> /home/testuser/.welcome.sh && \
    echo 'echo "  2. cd ~/.local/share/dotfiles"' >> /home/testuser/.welcome.sh && \
    echo 'echo "  3. ./setup"' >> /home/testuser/.welcome.sh && \
    echo 'echo "  4. chezmoi apply"' >> /home/testuser/.welcome.sh && \
    echo 'echo "  5. exec zsh"' >> /home/testuser/.welcome.sh && \
    echo 'echo ""' >> /home/testuser/.welcome.sh && \
    chmod +x /home/testuser/.welcome.sh && \
    echo 'bash ~/.welcome.sh' >> /home/testuser/.bashrc

# Default command
CMD ["/bin/bash"]
