#!/bin/bash -i
set -e

NEOVIM_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
echo "Installing neovim version $NEOVIM_VERSION"

if [[ $(uname -m) == "x86_64" ]]; then
    echo "Downloading neovim for x86_64"
    curl -Lo neovim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
    echo "Downloading neovim for arm64"
    curl -Lo neovim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-arm64.tar.gz"
else
    echo "Unsupported architecture"
    exit 1
fi

tar -xzf neovim.tar.gz
rm neovim.tar.gz
sudo mv nvim-linux-*/bin/nvim /usr/local/bin/nvim
sudo mv nvim-linux-*/lib/* /usr/local/lib/
sudo mv nvim-linux-*/share/* /usr/local/share/
sudo chmod +x /usr/local/bin/nvim
echo "neovim version $NEOVIM_VERSION installed successfully"
rm -rf nvim-linux-*