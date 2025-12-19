#!/bin/bash
set -euo pipefail

API_URL="https://api.github.com/repos/neovim/neovim/releases/latest"
CURL_OPTS=(-fsSL --retry 3 --retry-delay 2)

VERSION=$(curl "${CURL_OPTS[@]}" "$API_URL" | grep -Po '"tag_name": "v\K[^"]*') || {
    echo "Failed to fetch latest neovim version from $API_URL"
    exit 1
}
echo "Installing neovim version $VERSION"

if [[ $(uname -m) == "x86_64" ]]; then
    echo "Downloading neovim for x86_64"
    curl "${CURL_OPTS[@]}" -o neovim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
    echo "Downloading neovim for arm64"
    curl "${CURL_OPTS[@]}" -o neovim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
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
echo "neovim version $VERSION installed successfully"
rm -rf nvim-linux-*
