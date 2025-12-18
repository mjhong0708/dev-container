#!/bin/bash -i
set -e

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
echo "Installing lazygit version $LAZYGIT_VERSION"

if [[ $(uname -m) == "x86_64" ]]; then
    echo "Downloading lazygit for x86_64"
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
    echo "Downloading lazygit for arm64"
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
else
    echo "Unsupported architecture"
    exit 1
fi

tar -xzf lazygit.tar.gz lazygit
rm lazygit.tar.gz
sudo mv lazygit /usr/local/bin/lazygit
sudo chmod +x /usr/local/bin/lazygit
sudo ln -s /usr/local/bin/lazygit /usr/local/bin/lg
echo "lazygit version $LAZYGIT_VERSION installed successfully"