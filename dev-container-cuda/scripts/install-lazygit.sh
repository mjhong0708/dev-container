#!/bin/bash
set -euo pipefail

API_URL="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
CURL_OPTS=(-fsSL --retry 3 --retry-delay 2)

VERSION=$(curl "${CURL_OPTS[@]}" "$API_URL" | grep -Po '"tag_name": "v\K[^"]*') || {
    echo "Failed to fetch latest lazygit version from $API_URL"
    exit 1
}
echo "Installing lazygit version $VERSION"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION}_Linux_x86_64.tar.gz"
        ;;
    aarch64)
        DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION}_Linux_arm64.tar.gz"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Downloading lazygit from $DOWNLOAD_URL"
curl "${CURL_OPTS[@]}" -o lazygit.tar.gz "$DOWNLOAD_URL" || {
    echo "Failed to download lazygit archive"
    exit 1
}

tar -xzf lazygit.tar.gz lazygit
rm lazygit.tar.gz
sudo mv lazygit /usr/local/bin/lazygit
sudo chmod +x /usr/local/bin/lazygit
sudo ln -s /usr/local/bin/lazygit /usr/local/bin/lg
echo "lazygit version $VERSION installed successfully"
