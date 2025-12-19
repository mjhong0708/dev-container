#!/bin/bash
set -euo pipefail

API_URL="https://api.github.com/repos/sharkdp/bat/releases/latest"
CURL_OPTS=(-fsSL --retry 3 --retry-delay 2)

VERSION=$(curl "${CURL_OPTS[@]}" "$API_URL" | grep -Po '"tag_name": "v\K[^"]*') || {
    echo "Failed to fetch latest bat version from $API_URL"
    exit 1
}
echo "Installing bat version $VERSION"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/latest/download/bat-v${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
        ;;
    aarch64)
        DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/latest/download/bat-v${VERSION}-aarch64-unknown-linux-gnu.tar.gz"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Downloading bat from $DOWNLOAD_URL"
curl "${CURL_OPTS[@]}" -o bat.tar.gz "$DOWNLOAD_URL" || {
    echo "Failed to download bat archive"
    exit 1
}

tar -xzf bat.tar.gz
rm bat.tar.gz
sudo mv bat-*/bat /usr/local/bin
sudo chmod +x /usr/local/bin/bat
rm -rf bat-*
echo "bat version $VERSION installed successfully"
