#!/bin/bash

echo "ubuntu setup..."

# Append extra OS specific gitconfig
cat ~/dotfiles/ubuntu/.gitconfig >> ~/.gitconfig

# Update and install packages
sudo apt update
xargs sudo apt install -y < ~/dotfiles/ubuntu/apt-packages.txt
xargs sudo snap install --classic < ~/dotfiles/ubuntu/snap-classic-packages.txt
xargs sudo snap install < ~/dotfiles/ubuntu/snap-packages.txt

source ~/dotfiles/ubuntu/install-golang.sh
source ~/dotfiles/ubuntu/install-neovim.sh

# Symlink dotfiles
ln -sf ~/dotfiles/ubuntu/.bashrc ~/.bashrc
ln -sf ~/dotfiles/ubuntu/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/ubuntu/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/common/nvim "${HOME}/.config/nvim"

clone_if_not_exist https://github.com/wbthomason/packer.nvim "${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
clone_if_not_exist https://github.com/github/copilot.vim.git "${HOME}/.config/nvim/pack/github/start/copilot.vim"

# Check if GPG setup is included
if [ "$INCLUDE_GPG" = true ]; then
    echo "Including GPG and 1Password setup..."
    # Source 1Password setup script
    source ~/dotfiles/1password-setup.sh
fi

# Install Python development environment tools
pip install virtualenvwrapper
