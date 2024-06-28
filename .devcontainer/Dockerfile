# Use the official image as a parent image
FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    python3 \
    python3-pip \
    neovim \
    nodejs \
    npm \
    lua5.4 \
    golang \
    docker.io \
    kubectl \
    k9s \
    tmux \
    gnupg \
    openjdk-17-jdk \
    fzf \
    bat \
    ripgrep \
    && apt-get clean

# Install 1Password CLI
RUN curl -sS https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb -o 1password-latest.deb && \
    apt install ./1password-latest.deb && \
    rm 1password-latest.deb

# Install pip packages
RUN pip3 install virtualenvwrapper

# Create a non-root user and switch to it
RUN useradd -ms /bin/bash devuser
USER devuser
WORKDIR /home/devuser

# Clone the dotfiles repository
RUN git clone https://github.com/dolfolife/dotfiles.git

# Run the installation script
RUN cd dotfiles && make install

# Set the shell to zsh
CMD ["/bin/bash"]

